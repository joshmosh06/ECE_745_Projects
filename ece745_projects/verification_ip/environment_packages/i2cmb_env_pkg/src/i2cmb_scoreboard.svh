//------------------------------------------------------------------------------
//
//  Description: I2cmb scoreboard class compares results from predictor and output montior
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------

class i2cmb_scoreboard extends ncsu_component#(.T(ncsu_transaction));
  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  i2c_transaction trans_in;
  i2c_transaction trans_out;

  i2c_transaction temp;
  virtual function void nb_transport(input T input_trans, output T output_trans);
    $cast(this.trans_in,input_trans);
    $display({get_full_name()," nb_transport: expected transaction ",this.trans_in.convert2string()});

    $cast(output_trans,trans_out);
  endfunction

  function bit compare(i2c_transaction trans1, i2c_transaction trans2);
    bit equal_data = 1;
    int i = 0;

    if(trans1.num_bytes == trans2.num_bytes) begin
      for(i = 0; i < trans2.num_bytes; i++) begin
        equal_data = equal_data & (trans1.data[i] == trans2.data[i]);
      end
    end
    else return 0;
    return  equal_data & ((trans1.address == trans2.address) & (trans1.rw == trans2.rw) & (trans1.num_bytes == trans2.num_bytes) & (trans1.bus_num == trans2.bus_num));
  endfunction

  virtual function void nb_put(T trans);
    
    $cast(temp,trans);
    $display({get_full_name()," nb_put: actual transaction ",temp.convert2string()});
    if (compare(trans_in,temp)) $display({get_full_name()," wb_transaction MATCH!"});
    else                                $display({get_full_name()," wb_transaction MISMATCH!"});
  endfunction

endclass : i2cmb_scoreboard