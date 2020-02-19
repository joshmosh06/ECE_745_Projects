//------------------------------------------------------------------------------
//
//  Description: Defines Struct for i2c operations
//
//
//  Joshua Hofmann
//  North Carolina State University
//  2/10/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
package i2c_op;
  parameter int I2C_SLAVE_ADDR_SIZE = 7;
  parameter int I2C_BYTE_SIZE = 8;
  //i2_op_t definition
  typedef struct {
    bit [I2C_SLAVE_ADDR_SIZE-1:0] address;
    bit rw; // low for write High for read
  } i2c_op_t;
endpackage
