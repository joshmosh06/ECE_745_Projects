//------------------------------------------------------------------------------
//
//  Description: Directed test that alternates i2c reads and writes on i2c bus
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class i2cmb_test2 extends i2cmb_test;
	i2c_transaction t [];
	i2c_transaction st [];
	int bus_num = 0;
	int i = 0;
	function new(string name = "", ncsu_component_base parent = null);
		super.new(name,parent);
	endfunction : new
	virtual task run();
		bit [WB_BYTE_SIZE-1:0] test_data []; 
  		$display("Test 2 Read 32 values 100 to 131 from i2c bus");
		//Setup Transcations to be completed
		//Wishbone Transcations
		t = new[1];
		t[0] = new("32-Byte-Read",SLAVE_ADDRESS,READ,32,bus_num);
		super.gen.set_master_transactions(t);
		//Slave Transcations
		test_data = new[32];
		for(i = 0; i < 32; i++) begin
			test_data[i] = i;
		end
		st = new[1];
		st[0] = new("32-Byte-Read",SLAVE_ADDRESS,READ,32,bus_num);
		st[0].data = test_data;
		super.gen.set_slave_transactions(st);
		fork super.run(); join_any
			disable fork;
		$display("Test 2 Complete");
	endtask : run
endclass : i2cmb_test2	