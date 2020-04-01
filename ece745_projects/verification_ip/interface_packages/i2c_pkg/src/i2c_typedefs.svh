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
  parameter int I2C_SLAVE_ADDR_SIZE = 7;
  parameter int I2C_BYTE_SIZE = 8;
  //i2_op_t definition
  enum bit {READ = 1'b1, WRITE = 1'b0} i2c_op_t;
