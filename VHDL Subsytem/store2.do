onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cameracollectortransmitter/i_clk
add wave -noupdate /tb_cameracollectortransmitter/i_en
add wave -noupdate /tb_cameracollectortransmitter/DUT/pstate
add wave -noupdate /tb_cameracollectortransmitter/i_pixel_data
add wave -noupdate /tb_cameracollectortransmitter/i_lval
add wave -noupdate /tb_cameracollectortransmitter/i_fval
add wave -noupdate /tb_cameracollectortransmitter/i_pixel_read
add wave -noupdate /tb_cameracollectortransmitter/o_pixel_data
add wave -noupdate /tb_cameracollectortransmitter/o_valid_frame
add wave -noupdate /tb_cameracollectortransmitter/o_valid_pixel
add wave -noupdate /tb_cameracollectortransmitter/o_sobel_en
add wave -noupdate /tb_cameracollectortransmitter/o_finished
add wave -noupdate /tb_cameracollectortransmitter/pixel_gen_switch
add wave -noupdate /tb_cameracollectortransmitter/pixel_gen
add wave -noupdate /tb_cameracollectortransmitter/lval_gen
add wave -noupdate /tb_cameracollectortransmitter/total_sent
add wave -noupdate /tb_cameracollectortransmitter/read_gen_switch
add wave -noupdate /tb_cameracollectortransmitter/read_gen_delay
add wave -noupdate /tb_cameracollectortransmitter/DUT/write_en_wire
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/write_select_wire
add wave -noupdate /tb_cameracollectortransmitter/DUT/buffers/i_write_data
add wave -noupdate /tb_cameracollectortransmitter/DUT/i_swapped_wire
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/out_regA_wire
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/out_regB_wire
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/out_regC_wire
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/out_regD_wire
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/store/i_selectSram
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/store/o_sram
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/pstate
add wave -noupdate -radix unsigned /tb_cameracollectortransmitter/DUT/store/greyscaleTemp
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/rowDone
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/sramIndex
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(0)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(1)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(2)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(3)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(4)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(5)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(318)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(319)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(320)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(321)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(638)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(639)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(640)
add wave -noupdate /tb_cameracollectortransmitter/DUT/store/regFile(641)
add wave -noupdate /tb_cameracollectortransmitter/DUT/buffers/RAM_A/regFile(0)
add wave -noupdate /tb_cameracollectortransmitter/DUT/buffers/RAM_A/regFile(1)
add wave -noupdate /tb_cameracollectortransmitter/DUT/buffers/RAM_A/regFile(2)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {33749027 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 358
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
WaveRestoreZoom {33647863 ps} {33882535 ps}
