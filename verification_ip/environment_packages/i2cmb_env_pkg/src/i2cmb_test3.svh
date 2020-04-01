//------------------------------------------------------------------------------
//
//  Description: Directed test that reads 32 bytes from the I2c Bus
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class i2cmb_test3 extends i2cmb_test;
	i2c_transaction t [];
	i2c_transaction st [];
	int bus_num = 0;
	int i = 0;
	function new(string name = "", ncsu_component_base parent = null);
		super.new(name,parent);
	endfunction : new
	virtual task run();
		bit [WB_BYTE_SIZE-1:0] test_data []; 
  		$display("Test 3 Read and Write 64 values 100 to 131 from i2c bus");
		//Setup Transcations to be completed
		//Wishbone Transcations
		t = new[128];
		test_data = new[1];
		for (i = 0; i < 128; i = i+2) begin
			test_data[0] = i+64;
			t[i] = new("Byte-Read",SLAVE_ADDRESS,READ,1,bus_num);
			t[i+1] = new("Byte-Write",SLAVE_ADDRESS,WRITE,1,bus_num);
			t[i+1].data	= test_data;
		end
		super.gen.set_master_transactions(t);
		//Slave Transcations
		st = new[64];
		for (i = 0; i < 64; i++) begin
			st[i] = new("Byte-Read",SLAVE_ADDRESS,READ,1,bus_num);
			test_data[0] = 63-i;
			st[i].data = test_data;
		end
		super.gen.set_slave_transactions(st);
		fork super.run(); join_any
			disable fork;
		$display("Test 3 Complete");
	endtask : run
endclass : i2cmb_test3	