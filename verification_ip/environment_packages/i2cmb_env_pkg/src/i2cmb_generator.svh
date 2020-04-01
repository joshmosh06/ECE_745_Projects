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
class i2cmb_generator extends ncsu_component#(.T(ncsu_transaction));
  i2c_transaction slave_transactions [];
  i2c_transaction master_transactions [];
  i2c_agent i2c_agent_p0;
  wb_agent wb_agent_p1;
  string trans_name;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    // if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
    //   $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
    //   $fatal;
    // end
    // $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
  endfunction

  virtual task run_wb();
	foreach(master_transactions[i]) begin
    //$cast(transaction[i],ncsu_object_factory::create(trans_name));
		wb_agent_p1.bl_put(master_transactions[i]);
	    $display({get_full_name()," ",master_transactions[i].convert2string()});
	end
  endtask

  task wait_for_read_request(); 
    //wait for read event to occur in montior 
    wait(i2c_agent_p0.bus.provide_read_data_event);
  endtask

  virtual task run_i2c();
  	foreach(slave_transactions[i]) begin
	  	//Wait for i2c_agent to request Read data from generator
	  	wait_for_read_request();
	  	//tell the agent to infrom the drive to drive the bus with the following read data
	  	i2c_agent_p0.bl_put(slave_transactions[i]);
	  	$display({get_full_name()," ",slave_transactions[i].convert2string()});
  	end
   // $cast(transaction[i],ncsu_object_factory::create(trans_name));
  endtask

  function void set_agent(i2c_agent i2c_agent_1, wb_agent	wb_agent_2);
    this.i2c_agent_p0 = i2c_agent_1;
    this.wb_agent_p1 = wb_agent_2;
  endfunction

  function void set_master_transactions(i2c_transaction t []);
    this.master_transactions = t;
  endfunction : set_master_transactions

  function void set_slave_transactions(i2c_transaction t []);
    this.slave_transactions = t;
  endfunction : set_slave_transactions



endclass : i2cmb_generator