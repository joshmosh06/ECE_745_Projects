onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider I2C_MB
add wave -noupdate -divider {WB Signals}
add wave -noupdate /top/DUT/clk_i
add wave -noupdate /top/DUT/rst_i
add wave -noupdate /top/DUT/cyc_i
add wave -noupdate /top/DUT/stb_i
add wave -noupdate /top/DUT/ack_o
add wave -noupdate /top/DUT/adr_i
add wave -noupdate /top/DUT/we_i
add wave -noupdate /top/DUT/dat_i
add wave -noupdate /top/DUT/dat_o
add wave -noupdate /top/DUT/irq
add wave -noupdate -divider {I2C Signals}
add wave -noupdate -expand /top/DUT/scl_i
add wave -noupdate -expand /top/DUT/sda_i
add wave -noupdate /top/DUT/scl_o
add wave -noupdate /top/DUT/sda_o
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate /top/i2c_if_bus/rst_i
add wave -noupdate /top/i2c_if_bus/scl
add wave -noupdate /top/i2c_if_bus/sda
add wave -noupdate /top/i2c_if_bus/setSDA
add wave -noupdate /top/i2c_if_bus/sda_val
add wave -noupdate /top/i2c_if_bus/sda_o
add wave -noupdate /top/i2c_if_bus/rst_i
add wave -noupdate /top/i2c_if_bus/repeated_start
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {359620000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 346
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {453018580 ps}
