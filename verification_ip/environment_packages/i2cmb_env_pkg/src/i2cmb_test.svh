//------------------------------------------------------------------------------
//
//  Description: Test_base class
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class i2cmb_test extends ncsu_component;
  i2cmb_env_configuration  cfg;
  i2cmb_environment        env;
  i2cmb_generator          gen;


  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);
    cfg = new("cfg");
    cfg.sample_coverage();
    env = new("env",this);
    env.set_configuration(cfg);
    env.build();
    gen = new("gen",this);
    gen.set_agent(env.get_i2c_agent(),env.get_wb_agent());
  endfunction

  virtual task run();
     env.run();
     fork gen.run_i2c(); join_none
     gen.run_wb(); 
  endtask

endclass : i2cmb_test