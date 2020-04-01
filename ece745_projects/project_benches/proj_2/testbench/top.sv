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
`timescale 1ns / 10ps
//`define MASTER_MONITOR
`define I2C_MONITOR
`define TEST1
`define TEST2
`define TEST3
//`define TEST4
module top();
import ncsu_pkg::*;
import i2c_pkg::*;
import wb_pkg::*;
import i2cmb_env_pkg::*;

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

//i2c bus
bit [I2C_SLAVE_ADDR_SIZE-1:0]   addr;
bit [I2C_BYTE_SIZE-1:0] data [];
bit [WB_DATA_WIDTH-1:0] data_slave [];

i2cmb_test1 test1;
i2cmb_test2 test2;
i2cmb_test3 test3;
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
  .irq_i(irq),
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
// Define the flow of the simulation
initial test_flow_mast : begin
  
  `ifdef TEST1
  ncsu_config_db#(virtual i2c_if)::set("test1.env.i2c_agent", i2c_if_bus);
  ncsu_config_db#(virtual wb_if)::set("test1.env.wb_agent", wb_bus);
  test1 = new("test1",null);
  wb_bus.wait_for_reset();
  test1.run();
  `endif
  
  `ifdef TEST2
  ncsu_config_db#(virtual i2c_if)::set("test2.env.i2c_agent", i2c_if_bus);
  ncsu_config_db#(virtual wb_if)::set("test2.env.wb_agent", wb_bus);
  test2 = new("test2",null);
  wb_bus.wait_for_reset();
  test2.run();
  `endif

  `ifdef TEST3
  ncsu_config_db#(virtual i2c_if)::set("test3.env.i2c_agent", i2c_if_bus);
  ncsu_config_db#(virtual wb_if)::set("test3.env.wb_agent", wb_bus);
  test3 = new("test3",null);
  wb_bus.wait_for_reset();
  test3.run();

  `endif

  $finish();
end

endmodule
