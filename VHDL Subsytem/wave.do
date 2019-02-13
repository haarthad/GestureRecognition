onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cameracollectortransmitter/i_clk
add wave -noupdate /tb_cameracollectortransmitter/i_en
add wave -noupdate /tb_cameracollectortransmitter/i_pixel_data
add wave -noupdate /tb_cameracollectortransmitter/i_lval
add wave -noupdate /tb_cameracollectortransmitter/i_fval
add wave -noupdate /tb_cameracollectortransmitter/i_pixel_read
add wave -noupdate /tb_cameracollectortransmitter/o_pixel_data
add wave -noupdate /tb_cameracollectortransmitter/o_valid_frame
add wave -noupdate /tb_cameracollectortransmitter/o_valid_pixel
add wave -noupdate /tb_cameracollectortransmitter/pixel_gen_switch
add wave -noupdate /tb_cameracollectortransmitter/pixel_gen
add wave -noupdate /tb_cameracollectortransmitter/lval_gen
add wave -noupdate /tb_cameracollectortransmitter/total_sent
add wave -noupdate /tb_cameracollectortransmitter/read_gen_switch
add wave -noupdate /tb_cameracollectortransmitter/read_gen_delay
add wave -noupdate /tb_cameracollectortransmitter/DUT/i_read_edge
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6286251311 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 284
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
WaveRestoreZoom {6286074459 ps} {6286402807 ps}
