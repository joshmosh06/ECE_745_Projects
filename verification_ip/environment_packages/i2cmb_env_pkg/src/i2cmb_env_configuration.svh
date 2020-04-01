//------------------------------------------------------------------------------
//
//  Description: i2cmb_env configuration class
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class i2cmb_env_configuration extends ncsu_configuration;
  bit       loopback;
  bit       invert;
  bit [3:0] port_delay;
  i2c_configuration i2c_agent_config;
  wb_configuration wb_agent_config;

  covergroup env_configuration_cg;
  	option.per_instance = 1;
    option.name = name;
  	coverpoint loopback;
  	coverpoint invert;
  	coverpoint port_delay;
  endgroup

  function new(string name=""); 
    super.new(name);
    env_configuration_cg = new;
    i2c_agent_config = new("i2c_agent_config");
    wb_agent_config = new("wb_agent_config");
    wb_agent_config.collect_coverage=0;
    i2c_agent_config.sample_coverage();
    wb_agent_config.sample_coverage();
  endfunction

  function void sample_coverage();
  	env_configuration_cg.sample();
  endfunction


endclass : i2cmb_env_configuration