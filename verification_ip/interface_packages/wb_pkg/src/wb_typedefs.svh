//------------------------------------------------------------------------------
//
//  Description: Wb typedefs
//
//
//  Joshua Hofmann
//  North Carolina State University
//  2/10/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int WB_SLAVE_ADDR_SIZE = 7;
parameter int WB_BYTE_SIZE = 8;
parameter int NUM_I2C_SLAVES = 2;
parameter bit [WB_ADDR_WIDTH-1:0] CSR = 2'b00;
parameter bit [WB_ADDR_WIDTH-1:0] DPR = 2'b01;
parameter bit [WB_ADDR_WIDTH-1:0] CMDR = 2'b10;
parameter bit [WB_ADDR_WIDTH-1:0] FSMR = 2'b11;

parameter bit [WB_DATA_WIDTH-1:0] SLAVE_ADDRESS = 8'h20;
parameter bit [WB_DATA_WIDTH-1:0] MEMORY_ADDRESS = 8'h20;
parameter int BUS_NUM = 0;

enum bit [WB_DATA_WIDTH-1:0] {
SET_BUS_CMD 	= 8'b00000110,
START_CMD		= 8'b00000100,
STOP_CMD		= 8'b00000101,
WRITE_CMD		= 8'b00000001,
READ_ACK_CMD 	= 8'b00000010,
READ_NAK_CMD	= 8'b00000011
} wb_cmd_t;

typedef enum int {
	START_STATE,
	ADDRESS_STATE,
	DATA_STATE
} wb_state_t;