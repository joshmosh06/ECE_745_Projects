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
class i2c_driver extends ncsu_component#(.T(ncsu_transaction));

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual i2c_if bus;
  i2c_configuration configuration;
  i2c_transaction i2c_trans;

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    $cast(i2c_trans,trans);
    $display({get_full_name()," ",i2c_trans.convert2string()});
    bus.provide_read_data(i2c_trans.data);
  endtask

endclass : i2c_driver