//------------------------------------------------------------------------------
//
//  Description: wb monitor class
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class wb_monitor extends ncsu_component#(.T(ncsu_transaction));
  wb_configuration  configuration;
  virtual wb_if bus;
  wb_transaction temp_trans;
  T monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction
  
  virtual task run ();
  bit [WB_BYTE_SIZE-1:0] temp;
    bus.wait_for_reset();
      forever begin
        temp_trans = new("monitored_trans");
        if ( enable_transaction_viewing) begin
           temp_trans.start_time = $time;
        end
        bus.master_monitor(temp_trans.address,
                    temp_trans.data,
                    temp_trans.rw
                    );

        //$display({temp_trans.convert2string()," wb_monitor::run()"});
        monitored_trans = temp_trans;
        agent.nb_put(monitored_trans);
        if ( enable_transaction_viewing) begin
           temp_trans.end_time = $time;
           temp_trans.add_to_wave(transaction_viewing_stream);
        end

    end
  endtask
endclass : wb_monitor