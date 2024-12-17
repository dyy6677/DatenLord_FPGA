onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_stream_header_insert_tb/u_axi_stream_header_insert/clk
add wave -noupdate /axi_stream_header_insert_tb/u_axi_stream_header_insert/rst_n
add wave -noupdate -expand -group data_in -color Salmon /axi_stream_header_insert_tb/u_axi_stream_header_insert/valid_in
add wave -noupdate -expand -group data_in -color Salmon /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_in
add wave -noupdate -expand -group data_in -color Salmon -radix binary /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_in
add wave -noupdate -expand -group data_in -color Salmon -format Literal /axi_stream_header_insert_tb/u_axi_stream_header_insert/last_in
add wave -noupdate -expand -group data_in -color Salmon /axi_stream_header_insert_tb/u_axi_stream_header_insert/ready_in
add wave -noupdate -expand -group data_out -color {Dark Orchid} /axi_stream_header_insert_tb/u_axi_stream_header_insert/valid_out
add wave -noupdate -expand -group data_out -color {Dark Orchid} /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_out
add wave -noupdate -expand -group data_out -color {Dark Orchid} -radix binary /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_out
add wave -noupdate -expand -group data_out -color {Dark Orchid} -format Literal /axi_stream_header_insert_tb/u_axi_stream_header_insert/last_out
add wave -noupdate -expand -group data_out -color {Dark Orchid} /axi_stream_header_insert_tb/u_axi_stream_header_insert/ready_out
add wave -noupdate -expand -group data_insert -color Gold /axi_stream_header_insert_tb/u_axi_stream_header_insert/valid_insert
add wave -noupdate -expand -group data_insert -color Gold /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_insert
add wave -noupdate -expand -group data_insert -color Gold -radix binary /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_insert
add wave -noupdate -expand -group data_insert -color Gold /axi_stream_header_insert_tb/u_axi_stream_header_insert/byte_insert_cnt
add wave -noupdate -expand -group data_insert -color Gold /axi_stream_header_insert_tb/u_axi_stream_header_insert/ready_insert
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_out_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_out_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_insert_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_insert_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/byte_insert_cnt_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_insert_r_full
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_in_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_in_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/last_in_r
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_in_r_full
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_in_first
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_out_temp
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_out_temp
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/handshake_insert
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/handshake_in
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_out_start
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/data_insert_shift
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/keep_insert_shift
add wave -noupdate -group other /axi_stream_header_insert_tb/u_axi_stream_header_insert/valid_out_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {704 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 442
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
WaveRestoreZoom {665 ns} {946 ns}
