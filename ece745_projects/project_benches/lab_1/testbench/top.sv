`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 6;
parameter bit [WB_ADDR_WIDTH-1:0] CSR = 2'b00;
parameter bit [WB_ADDR_WIDTH-1:0] DPR = 2'b01;
parameter bit [WB_ADDR_WIDTH-1:0] CMDR = 2'b10;
parameter bit [WB_ADDR_WIDTH-1:0] FSMR = 2'b11;

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
tri  [NUM_I2C_SLAVES-1:0] sda;
//Montior signals
bit [WB_ADDR_WIDTH-1:0] addr_mon;
bit [WB_DATA_WIDTH-1:0] data_mon;
bit we_mon;
bit [WB_DATA_WIDTH-1:0] cmdr;


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
    if(we_mon)
      $display("WRITE Address: 0x%2h Data: 0x%2h (%d)",addr_mon, data_mon, data_mon);
    else
      $display("READ  Address: 0x%2h Data: 0x%2h (%d)",addr_mon, data_mon, data_mon);
end

// ****************************************************************************
// Define the flow of the simulation
initial test_flow : begin
#120
//Example 1
//Enable I2CMB / Enable Interrupt
wb_bus.master_write(CSR,8'b11000000);
$display("Example 3 Start \n");
//Example 3 - Write byte 0x78 to a slave with address 0x22 resding on I2C bus #5
//Write 0x05 to DPR ID of i2c bus
wb_bus.master_write(DPR,8'h05);
//Write byte “xxxxx110” to the CMDR. This is Set Bus command.
wb_bus.master_write(CMDR,8'b00000110);
//Wait for interrupt or until DON bit of CMDR reads '1'.
operation_done();
//Write byte “xxxxx100” to the CMDR. This is Start command.
wb_bus.master_write(CMDR, 8'b00000100);
//Wait for interrupt or until DON bit of CMDR reads '1'.
operation_done();
//Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
//rightmost bit = '0', which means writing.
wb_bus.master_write(DPR, 8'h44);
//Write byte “xxxxx001” to the CMDR. This is Write command.
wb_bus.master_write(CMDR, 8'b00000001);
//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
//is '1', then slave doesn't respond.
operation_done();
//Write byte 0x78 to the DPR. This is the byte to be written.
wb_bus.master_write(DPR, 8'h78);
//Write byte “xxxxx001” to the CMDR. This is Write command.
wb_bus.master_write(CMDR, 8'b00000001);
//Wait for interrupt or until DON bit of CMDR reads '1'.
operation_done();
//Write byte “xxxxx101” to the CMDR. This is Stop command.
wb_bus.master_write(CMDR, 8'b00000101);
//Wait for interrupt or until DON bit of CMDR reads '1'.
operation_done();

$display("Example 3 End \n");
$finish();
end

// ****************************************************************************
//task that determines if DON bit of CMDR is set or if irq is high
task operation_done();
  cmdr = 8'h00;
  while(!irq) @(posedge clk);
  wb_bus.master_read(CMDR, cmdr);
   @(posedge clk)
  casex(cmdr)
    8'b1xxxxxxx : $display("Operation Complete");
    8'bx1xxxxxx : $display("Data Not Acknowledged NAK");
    8'bxx1xxxxx : $display("Arbitation Lost");
    8'bxxx1xxxx : $display("ERROR ");
    default : $display("Error Reading CMDR 0x%2h",cmdr);
  endcase
endtask

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
