//------------------------------------------------------------------------------
//
//  Description: Directed test that writes 32 bytes to the I2c Bus
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class i2cmb_test1 extends i2cmb_test;
	i2c_transaction t [];
	int bus_num = 0;
	int i = 0;
	function new(string name = "", ncsu_component_base parent = null);
		super.new(name,parent);
	endfunction : new
	virtual task run();
		bit [WB_BYTE_SIZE-1:0] test_data []; 
		$display("Test 1 Write 32 values 0 to 32 to i2c bus  \n");
		//Setup Transcations to be completed
		//Wishbone Transcations
  		test_data = new[32];
		for(i = 0; i < 32; i++) begin
			test_data[i] = i;
		end
		t = new[1];
		t[0] = new("32-Byte-Write",SLAVE_ADDRESS,WRITE,32,bus_num);
		t[0].data = test_data;
		//Slave Transcations
		//none
		super.gen.set_master_transactions(t);
		fork super.run(); join_any
			disable fork;
		$display("Test 1 Complete");
	endtask : run
endclass