//------------------------------------------------------------------------------
//
//  Description: I2c Package file that includes all files for the i2c package
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
package wb_pkg;
	import ncsu_pkg::*;
	import i2c_pkg::*;
  `include "src/wb_typedefs.svh"
  `include "src/wb_configuration.svh"
  `include "src/wb_transaction.svh"
  `include "src/wb_driver.svh"
  `include "src/wb_monitor.svh"
  `include "src/wb_agent.svh"
endpackage
