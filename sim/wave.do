onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/Clk
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/RST
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/H_CNT
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/V_CNT
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/IMAGE_ENA
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/NEXT_IMAGE
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/ANIMATION_DIR
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/SRAM_D
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/DATA_ENA
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/SRAM_A
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/R_DATA
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/G_DATA
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/B_DATA
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/red
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/green
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/blue
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/adrres_pointer
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/min_adrres_pointer
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/max_adrres_pointer
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/flag
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/red_pixel
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/green_pixel
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/blue_pixel
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/picture_display
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/temp
add wave -noupdate -group data_generator /video_generator_tb/uut/U5/data_cerator
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/clk
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/RST
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/INC_SPEED
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/DEC_SPEED
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/hsync
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/vsync
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/next_image
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/H_CNT
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/V_CNT
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/hcount
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/vcount
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/timings
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/timer_imege
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/counter_rate
add wave -noupdate -group timing_generator /video_generator_tb/uut/U4/counter_time
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9685116746 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 136
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {43237432308 ps} {43366886790 ps}
