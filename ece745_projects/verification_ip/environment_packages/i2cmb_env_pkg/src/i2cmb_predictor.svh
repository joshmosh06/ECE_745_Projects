//------------------------------------------------------------------------------
//
//  Description: I2c configuration class
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class i2cmb_predictor extends ncsu_component#(.T(ncsu_transaction));
  ncsu_component#(T) scoreboard;
  T transport_trans;
  i2cmb_env_configuration configuration;
  i2c_transaction predicted;
  wb_state_t state = START_STATE;

  
  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction : new

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction : set_configuration

  virtual function void set_scoreboard(ncsu_component #(T) scoreboard);
      this.scoreboard = scoreboard;
  endfunction : set_scoreboard

  function bit predict(wb_transaction wb_trans);
    case(state) 
      START_STATE : begin
        if(wb_trans.address == CMDR && wb_trans.data == START_CMD) state = ADDRESS_STATE;
      end
      ADDRESS_STATE : begin
        if(wb_trans.address != CMDR && wb_trans.data != START_CMD) begin
        predicted = new("Predicted I2c Trans");
        predicted.address = wb_trans.data >> 1;
        predicted.rw = wb_trans.data & 8'b00000001;
        predicted.bus_num = wb_trans.bus_num;
        predicted.num_bytes = 0;
        state = DATA_STATE;
      end
      end
      DATA_STATE : begin
        if(wb_trans.address == CMDR && wb_trans.data == STOP_CMD) begin
          state = START_STATE;
          return 1;
        end 
        else begin
          if(wb_trans.address != CMDR) begin
            predicted.num_bytes++;
            predicted.data = new[predicted.num_bytes](predicted.data);
            predicted.data[predicted.num_bytes-1] = wb_trans.data;
          end
        end
      end
    endcase
      return 0;
  endfunction : predict

  virtual function void nb_put(T trans);
   // $display({get_full_name()," ",trans.convert2string()});
    if(predict(trans)) begin
      scoreboard.nb_transport(predicted, transport_trans);
    end
    
  endfunction : nb_put



endclass : i2cmb_predictor