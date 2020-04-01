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
class i2c_monitor extends ncsu_component#(.T(ncsu_transaction));
  i2c_configuration  configuration;
  virtual i2c_if bus;

  i2c_transaction monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction
  
  virtual task run ();
      forever begin
        monitored_trans = new("monitored_trans");
        if ( enable_transaction_viewing) begin
           monitored_trans.start_time = $time;
        end
        bus.monitor(monitored_trans.address,
                    monitored_trans.rw,
                    monitored_trans.data
                    );
       monitored_trans.num_bytes = monitored_trans.data.size();
        $display({monitored_trans.convert2string(), " i2c_monitor::run()"});
        agent.nb_put(monitored_trans);
        if ( enable_transaction_viewing) begin
           monitored_trans.end_time = $time;
           monitored_trans.add_to_wave(transaction_viewing_stream);
        end
    end
  endtask
endclass : i2c_monitor