//------------------------------------------------------------------------------
//
//  Description: wb driver class
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
class wb_driver extends ncsu_component#(.T(ncsu_transaction));

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual wb_if bus;
  wb_configuration configuration;
  i2c_transaction wb_trans;

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  task configure_driver();
    //Enable I2CMB / Enable Interrupt
  	bus.master_write(CSR,8'b11000000);
  endtask

  virtual task bl_put(T trans);
  $cast(wb_trans,trans);
    $display({get_full_name()," ",wb_trans.convert2string()});
    //call master_write for 
    if(~wb_trans.rw) write_data(wb_trans.address, wb_trans.data, wb_trans.bus_num);
    else read_data(wb_trans.address, wb_trans.bus_num, wb_trans.num_bytes, wb_trans.data);

  endtask

//******************************************************************************
//
//  write_data()
//  Description: writes data to the prvoided i2c bus
//
//******************************************************************************
task write_data(
  bit [WB_DATA_WIDTH-1:0] address,
  bit [WB_DATA_WIDTH-1:0] write_data [],
  int bus_num
  );
  int i;
  //Example 3 - Write byte 0x78 to a slave with address 0x22 resding on I2C bus #5
  //Write 0x05 to DPR ID of i2c bus
  bus.master_write(DPR,bus_num);
  //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
  bus.master_write(CMDR,SET_BUS_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Write byte “xxxxx100” to the CMDR. This is Start command.
  bus.master_write(CMDR, START_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '0', which means writing.
  bus.master_write(DPR, address << 1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  bus.master_write(CMDR, WRITE_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();

  for(i = 0; i < write_data.size(); i++) begin
    //Write byte 0x78 to the DPR. This is the byte to be written.
    bus.master_write(DPR, write_data[i]);
    //Write byte “xxxxx001” to the CMDR. This is Write command.
    bus.master_write(CMDR, WRITE_CMD);
    //Wait for interrupt or until DON bit of CMDR reads '1'.
    operation_done();
  end
  //Write byte “xxxxx101” to the CMDR. This is Stop command.
  bus.master_write(CMDR, STOP_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
endtask

//******************************************************************************
//
//  read_data()
//  Description: Read data from the prvoided i2c bus
//
//******************************************************************************
task read_data(
  bit [WB_DATA_WIDTH-1:0] address,
  int bus_num,
  int read_num,
  output bit [WB_DATA_WIDTH-1:0] read_data []
  );
  int i;
  //Write busnum to DPR ID of i2c bus
  bus.master_write(DPR,bus_num);
  //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
  bus.master_write(CMDR,SET_BUS_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
   //Write byte “xxxxx100” to the CMDR. This is Start command.
  bus.master_write(CMDR, START_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '1', which means reading.
  bus.master_write(DPR, (address << 1) | 8'd1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  bus.master_write(CMDR, WRITE_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();

  for(i = 0; i < read_num-1; i++) begin
    //Write byte “xxxxx010” to the CMDR. This is Read command with ACK
    bus.master_write(CMDR, READ_ACK_CMD);
    //Wait for interrupt or until DON bit of CMDR reads '1'.
    operation_done();
    //Store value from DPR
    bus.master_read(DPR, read_data[i]);
  end
  //Read last byte with NACK telling SLAVE to stop and release the bus back to the master
  //Write byte “xxxxx011” to the CMDR. This is Read command with NACK
  bus.master_write(CMDR, READ_NAK_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Store value from DPR
  bus.master_read(DPR, read_data[read_num-1]);
  //Write byte “xxxxx101” to the CMDR. This is Stop command.
  bus.master_write(CMDR, STOP_CMD);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();

  endtask

//******************************************************************************
//
//  read_data_from_memory_address()
//  Description: Read data from the prvoided i2c bus at a specified memory address
//
//******************************************************************************
task read_data_from_memory_address(
  bit [WB_DATA_WIDTH-1:0] address,
  bit [WB_DATA_WIDTH-1:0] memory_address,
  int bus_num,
  int read_num,
  output bit [WB_DATA_WIDTH-1:0] read_data []
  );
  int i;
  //Write busnum to DPR ID of i2c bus
  bus.master_write(DPR,bus_num);
  //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
  bus.master_write(CMDR,8'b00000110);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Write byte “xxxxx100” to the CMDR. This is Start command.
  bus.master_write(CMDR, 8'b00000100);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '0', which means writing.
  bus.master_write(DPR, address << 1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();
  //Write Memory address for reading
  bus.master_write(DPR, memory_address);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();
  //
  //Write byte “xxxxx100” to the CMDR. This is Start command.
  bus.master_write(CMDR, 8'b00000100);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '1', which means reading.
  bus.master_write(DPR, (address << 1) | 8'd1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();

  for(i = 0; i < read_num-1; i++) begin
    //Write byte “xxxxx010” to the CMDR. This is Read command with ACK
    bus.master_write(CMDR, 8'b00000010);
    //Wait for interrupt or until DON bit of CMDR reads '1'.
    operation_done();
    //Store value from DPR
    bus.master_read(DPR, read_data[i]);
  end
  //Read last byte with NACK telling SLAVE to stop and release the bus back to the master
  //Write byte “xxxxx011” to the CMDR. This is Read command with NACK
  bus.master_write(CMDR, 8'b00000011);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Store value from DPR
  bus.master_read(DPR, read_data[read_num-1]);
  //Write byte “xxxxx101” to the CMDR. This is Stop command.
  bus.master_write(CMDR, 8'b00000101);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();

  endtask

//******************************************************************************
//
//  operation_done()
//  Description: Returns when the irq signal is sent and prints
//               the outcome of the intended operation.
//
//******************************************************************************
task operation_done();
  bit [WB_DATA_WIDTH-1:0] cmdr = 8'h00;
  bus.wait_for_interrupt();
  bus.master_read(CMDR, cmdr);
  `ifdef MASTER_MONITOR
   @(posedge clk)
  casex(cmdr)
    8'b1xxxxxxx : $display("Operation Complete");
    8'bx1xxxxxx : $display("Data Not Acknowledged NAK");
    8'bxx1xxxxx : $display("Arbitation Lost");
    8'bxxx1xxxx : $display("ERROR ");
    default : $display("Error Reading CMDR 0x%2h",cmdr);
  endcase
  `endif
endtask
endclass : wb_driver