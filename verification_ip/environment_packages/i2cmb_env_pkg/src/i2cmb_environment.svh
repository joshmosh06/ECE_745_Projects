//------------------------------------------------------------------------------
//
//  Description: I2cmb environment class
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class i2cmb_environment extends ncsu_component#(.T(ncsu_transaction));
  i2cmb_env_configuration   configuration;
  i2c_agent                 i2c_agent_p0;
  wb_agent			            wb_agent_p1;
  i2cmb_predictor           pred;
  i2cmb_scoreboard          scbd;
  i2cmb_coverage            coverage;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction 

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    i2c_agent_p0 = new("i2c_agent",this);
    i2c_agent_p0.set_configuration(configuration.i2c_agent_config);
    i2c_agent_p0.build();
    wb_agent_p1 = new("wb_agent",this);
    wb_agent_p1.set_configuration(configuration.wb_agent_config);
    wb_agent_p1.build();
    pred  = new("pred", this);
    pred.set_configuration(configuration);
    pred.build();
    scbd  = new("scbd", this);
    scbd.build();
    coverage = new("coverage", this);
    coverage.set_configuration(configuration);
    coverage.build();
    wb_agent_p1.connect_subscriber(coverage);
    wb_agent_p1.connect_subscriber(pred);
    pred.set_scoreboard(scbd);
    i2c_agent_p0.connect_subscriber(scbd);
  endfunction

  function i2c_agent get_i2c_agent();
    return i2c_agent_p0;
  endfunction

  function wb_agent get_wb_agent();
    return wb_agent_p1;
  endfunction

  virtual task run();
      wb_agent_p1.run();
      i2c_agent_p0.run();
  endtask
  
endclass : i2cmb_environment