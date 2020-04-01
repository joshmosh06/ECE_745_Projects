//------------------------------------------------------------------------------
//
//  Description: i2cmb Package file that includes all files for the i2cmb package
//
//
//  Joshua Hofmann
//  North Carolina State University
//  3/9/2020
//  Built with ModelSim 10.6c
//------------------------------------------------------------------------------
package i2cmb_env_pkg;
	import ncsu_pkg::*;
	import i2c_pkg::*;
	import wb_pkg::*;
  `include "src/i2cmb_env_configuration.svh"
  `include "src/i2cmb_generator.svh"
  `include "src/i2cmb_predictor.svh"
  `include "src/i2cmb_scoreboard.svh"
  `include "src/i2cmb_coverage.svh"
  `include "src/i2cmb_environment.svh"
  `include "src/i2cmb_test.svh"
  `include "src/i2cmb_test1.svh"
  `include "src/i2cmb_test2.svh"
  `include "src/i2cmb_test3.svh"
endpackage
