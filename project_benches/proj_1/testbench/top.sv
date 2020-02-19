//------------------------------------------------------------------------------
//
//  Description: TestBench to Implement Project 1
//
//
//  Joshua Hofmann
//  North Carolina State University
//  1/30/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
import i2c_op::*;
`timescale 1ns / 10ps
//`define MASTER_MONITOR
`define I2C_MONITOR
`define TEST1
`define TEST2
`define TEST3
`define TEST4
module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 2;
parameter bit [WB_ADDR_WIDTH-1:0] CSR = 2'b00;
parameter bit [WB_ADDR_WIDTH-1:0] DPR = 2'b01;
parameter bit [WB_ADDR_WIDTH-1:0] CMDR = 2'b10;
parameter bit [WB_ADDR_WIDTH-1:0] FSMR = 2'b11;

parameter bit [WB_DATA_WIDTH-1:0] SLAVE_ADDRESS = 8'h20;
parameter bit [WB_DATA_WIDTH-1:0] MEMORY_ADDRESS = 8'h20;
parameter int BUS_NUM = 0;
bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_SLAVES-1:0] scl;
triand  [NUM_I2C_SLAVES-1:0] sda;
//Montior signals
//Wishbone
bit [WB_ADDR_WIDTH-1:0] addr_mon;
bit [WB_DATA_WIDTH-1:0] data_mon;
bit we_mon;
bit [WB_DATA_WIDTH-1:0] cmdr;
//i2c bus
bit	[I2C_SLAVE_ADDR_SIZE-1:0]		addr;
i2c_op_t	              op_mon;
bit	[I2C_BYTE_SIZE-1:0]	data [];
bit [WB_DATA_WIDTH-1:0] data_slave [];

// ****************************************************************************
// Clock generator
initial clk_gen : begin
      clk = 1'b1;
  forever begin
      #10 clk = ~clk;
    end
end

// ****************************************************************************
// Reset generator
initial rst_gen : begin
  rst = 1'b1;
  #113
  rst = 1'b0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
always  @(posedge clk) wb_monitoring : begin
    wb_bus.master_monitor(addr_mon, data_mon, we_mon);
    `ifdef MASTER_MONITOR
    if(we_mon)
      $display("WRITE Address: 0x%2h Data: 0x%2h (%d)",addr_mon, data_mon, data_mon);
    else
      $display("READ  Address: 0x%2h Data: 0x%2h (%d)",addr_mon, data_mon, data_mon);
    `endif
end

// ****************************************************************************
// I2C data montior
always @ (posedge clk) monitor_i2c_bus : begin
  op_mon.rw = 0;
  op_mon.address = 0;
  i2c_if_bus.monitor(addr,op_mon,data);
  `ifdef I2C_MONITOR
  if(op_mon.rw == 1'b1)
    $display("I2C_BUS READ  Transfer: Address: 0x%2h Data: 0x%2h (%d)",addr, data, data);
  else
    $display("I2C_BUS WRITE Transfer: Address: 0x%2h Data: 0x%2h (%d)",addr, data, data);
  `endif
end

// ****************************************************************************
// Define the flow of the simulation
initial test_flow_mast : begin
  bit [WB_DATA_WIDTH-1:0] data [];
  bit [WB_DATA_WIDTH-1:0] read_data_test3 [];
  bit [WB_DATA_WIDTH-1:0] write_data_test3 [];
  int i;

  #120
  //Enable I2CMB / Enable Interrupt
  wb_bus.master_write(CSR,8'b11000000);

  `ifdef TEST1
  $display("Test 1 Write 32 values 0 to 32 to i2c bus  \n");
  data = new[32];
  for(i = 0; i < data.size(); i++) begin
    data[i] = i;
  end
  write_data(SLAVE_ADDRESS,data,BUS_NUM);

  $display("Test 1 Complete");
  `endif

  `ifdef TEST2
  $display("Test 2 Read 32 values 100 to 131 from i2c bus");
  data = new[32];
  read_data(SLAVE_ADDRESS,BUS_NUM,32,data);

  $display("Test 2 Complete");
  `endif

  `ifdef TEST3
  $display("Test 3 read/write 128 values to i2c bus write vales : 64 - 127 Read values 63 - 0");
  read_data_test3 = new[1];
  write_data_test3 = new[1];
  for(i = 0; i < 64; i++) begin
  write_data_test3[0] = i+64;
    //read 1 byte
    read_data(SLAVE_ADDRESS,BUS_NUM,1,read_data_test3);
    //write 1 byte
    write_data(SLAVE_ADDRESS,write_data_test3,BUS_NUM);
  end
  $display("Test 3 Complete");
  `endif
  `ifdef TEST4
  $display("Test 4 read 32 values 100 - 131 from Specified Memory Address 0x%2h (Repeated Start)", MEMORY_ADDRESS);
  data = new[32];
  read_data_from_memory_address(SLAVE_ADDRESS,MEMORY_ADDRESS,BUS_NUM,32,data);
  $display("Test 4 Complete");
  `endif
  #1000
  $finish();
end

// ****************************************************************************
// Define the flow of the simulation
initial test_flow_Slave :  begin
  bit [WB_DATA_WIDTH-1:0] write_data_slave [];
  i2c_op_t op_slave;
  int i;
  int j;
  op_slave.rw = 0;
  op_slave.address = 0;
  `ifdef TEST1
  //Test 1
  i2c_if_bus.wait_for_i2c_transfer(op_slave,write_data_slave);
  `endif

  `ifdef TEST2
  //Test 2
  data_slave = new[32];
  for(i = 0; i < 32; i++) begin
    data_slave[i] = i + 100;
  end
  //wait untill bus is in correct state to send data
  while(op_slave.rw == 1'b0) i2c_if_bus.wait_for_i2c_transfer(op_slave,write_data_slave);

  i2c_if_bus.provide_read_data(data_slave);
  `endif

  `ifdef TEST3
   data_slave = new[1];
   j=0;
    for(i = 0; i < 128; i++) begin

      op_slave.rw = 0;
      i2c_if_bus.wait_for_i2c_transfer(op_slave,write_data_slave);
      if(op_slave.rw == 1'b1) begin
        data_slave[0] = 63-j;
        j++;
        i2c_if_bus.provide_read_data(data_slave);
      end
    end
  `endif

  `ifdef TEST4
    //Test 4
    data_slave = new[32];
    for(i = 0; i < 32; i++) begin
      data_slave[i] = i + 100;
    end
    //wait untill bus is in correct state to send data
    while(op_slave.rw == 1'b0) @(posedge clk) i2c_if_bus.wait_for_i2c_transfer(op_slave,write_data_slave);
    i2c_if_bus.provide_read_data(data_slave);
  `endif
end

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
  wb_bus.master_write(DPR,bus_num);
  //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
  wb_bus.master_write(CMDR,8'b00000110);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Write byte “xxxxx100” to the CMDR. This is Start command.
  wb_bus.master_write(CMDR, 8'b00000100);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '0', which means writing.
  wb_bus.master_write(DPR, address << 1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  wb_bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();

  for(i = 0; i < write_data.size(); i++) begin
    //Write byte 0x78 to the DPR. This is the byte to be written.
    wb_bus.master_write(DPR, write_data[i]);
    //Write byte “xxxxx001” to the CMDR. This is Write command.
    wb_bus.master_write(CMDR, 8'b00000001);
    //Wait for interrupt or until DON bit of CMDR reads '1'.
    operation_done();
  end
  //Write byte “xxxxx101” to the CMDR. This is Stop command.
  wb_bus.master_write(CMDR, 8'b00000101);
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
  wb_bus.master_write(DPR,bus_num);
  //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
  wb_bus.master_write(CMDR,8'b00000110);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
   //Write byte “xxxxx100” to the CMDR. This is Start command.
  wb_bus.master_write(CMDR, 8'b00000100);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '1', which means reading.
  wb_bus.master_write(DPR, (address << 1) | 8'd1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  wb_bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();

  for(i = 0; i < read_num-1; i++) begin
    //Write byte “xxxxx010” to the CMDR. This is Read command with ACK
    wb_bus.master_write(CMDR, 8'b00000010);
    //Wait for interrupt or until DON bit of CMDR reads '1'.
    operation_done();
    //Store value from DPR
    wb_bus.master_read(DPR, read_data[i]);
  end
  //Read last byte with NACK telling SLAVE to stop and release the bus back to the master
  //Write byte “xxxxx011” to the CMDR. This is Read command with NACK
  wb_bus.master_write(CMDR, 8'b00000011);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Store value from DPR
  wb_bus.master_read(DPR, read_data[read_num-1]);
  //Write byte “xxxxx101” to the CMDR. This is Stop command.
  wb_bus.master_write(CMDR, 8'b00000101);
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
  wb_bus.master_write(DPR,bus_num);
  //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
  wb_bus.master_write(CMDR,8'b00000110);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Write byte “xxxxx100” to the CMDR. This is Start command.
  wb_bus.master_write(CMDR, 8'b00000100);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '0', which means writing.
  wb_bus.master_write(DPR, address << 1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  wb_bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();
  //Write Memory address for reading
  wb_bus.master_write(DPR, memory_address);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  wb_bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();
  //
  //Write byte “xxxxx100” to the CMDR. This is Start command.
  wb_bus.master_write(CMDR, 8'b00000100);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  // The slave address is shifted 1 bit to the left +
  // rightmost bit = '1', which means reading.
  wb_bus.master_write(DPR, (address << 1) | 8'd1);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  wb_bus.master_write(CMDR, 8'b00000001);
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  //is '1', then slave doesn't respond.
  operation_done();

  for(i = 0; i < read_num-1; i++) begin
    //Write byte “xxxxx010” to the CMDR. This is Read command with ACK
    wb_bus.master_write(CMDR, 8'b00000010);
    //Wait for interrupt or until DON bit of CMDR reads '1'.
    operation_done();
    //Store value from DPR
    wb_bus.master_read(DPR, read_data[i]);
  end
  //Read last byte with NACK telling SLAVE to stop and release the bus back to the master
  //Write byte “xxxxx011” to the CMDR. This is Read command with NACK
  wb_bus.master_write(CMDR, 8'b00000011);
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  operation_done();
  //Store value from DPR
  wb_bus.master_read(DPR, read_data[read_num-1]);
  //Write byte “xxxxx101” to the CMDR. This is Stop command.
  wb_bus.master_write(CMDR, 8'b00000101);
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
  cmdr = 8'h00;
  while(!irq) @(posedge clk);
  wb_bus.master_read(CMDR, cmdr);
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

// ****************************************************************************
// Instantiate Slave interface
i2c_if i2c_if_bus (
  //System Signals
  .rst_i(rst),
  //Slave Signals
  .scl(scl[1]),
  .sda(sda[1]),
  .sda_o(sda[1])
  );

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule
