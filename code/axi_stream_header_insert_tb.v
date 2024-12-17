`timescale 		1ns/1ns

module axi_stream_header_insert_tb();

parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8 ;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

reg	clk		= 'd0;
reg	rst_n	= 'd0;

reg                        valid_insert;
reg   [DATA_WD-1 : 0]      data_insert;
reg   [DATA_BYTE_WD-1 : 0] keep_insert;
wire                       ready_insert;
reg   [BYTE_CNT_WD-1 : 0]  byte_insert_cnt; 
reg                        valid_in;
reg   [DATA_WD-1 : 0]      data_in;
reg   [DATA_BYTE_WD-1 : 0] keep_in;
reg                        last_in;
wire                       ready_in;
wire                       valid_out;
wire  [DATA_WD-1 : 0]      data_out;
wire  [DATA_BYTE_WD-1 : 0] keep_out;
wire                       last_out;
reg                        ready_out;

always #10 clk = ~clk;

axi_stream_header_insert #(
    .DATA_WD(DATA_WD),
    .DATA_BYTE_WD(DATA_BYTE_WD),
    .BYTE_CNT_WD(BYTE_CNT_WD)
) u_axi_stream_header_insert (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .keep_in(keep_in),
    .last_in(last_in),
    .ready_in(ready_in),
    .valid_out(valid_out),
    .data_out(data_out),
    .keep_out(keep_out),
    .last_out(last_out),
    .ready_out(ready_out),
    .valid_insert(valid_insert),
    .data_insert(data_insert),
    .keep_insert(keep_insert),
    .byte_insert_cnt(byte_insert_cnt),
    .ready_insert(ready_insert)
);

function integer count_ones;
    input [DATA_BYTE_WD-1:0] keep;
    integer i;
    begin
        count_ones = 0;
        for (i = 0; i < DATA_BYTE_WD; i = i + 1) begin
            count_ones = count_ones + keep[i];
        end
    end
endfunction

task send_axi_stream_header(
    input [DATA_WD-1:0] data,
    input [DATA_BYTE_WD-1:0] keep);
    begin
        valid_insert = 1;
        data_insert = data;
        keep_insert = keep;
        byte_insert_cnt = count_ones(keep);
    end
endtask

task send_axi_stream_data(
    input [DATA_WD-1:0] data);
    begin
        valid_in = 1;
        data_in = data;
        keep_in = 4'b1111;
        last_in = 1'b0;
    end
endtask

task send_axi_stream_data_last(
    input [DATA_WD-1:0] data,
    input [DATA_BYTE_WD-1:0] keep);
    begin
        valid_in = 1'b1;
        data_in = data;
        keep_in = keep;
        last_in = 1'b1;
        @(posedge clk);
        valid_in = 1'b0;
        last_in = 1'b0;
    end
endtask

task insert_header_check_1;
    input [DATA_BYTE_WD-1 : 0] keep_insert ;
    input [DATA_BYTE_WD-1:0] keep_in_last ;
    input [7:0]                data_num;
    begin
        data_insert = $urandom;
        send_axi_stream_header(data_insert, keep_insert);
        @(posedge clk);
        repeat(data_num - 1) begin
            data_in = $urandom;
            send_axi_stream_data(data_in);
            @(posedge clk);
        end
        data_in = $urandom;
        send_axi_stream_data_last(data_in,keep_in_last);
        wait(last_out)
            valid_insert = 0;
        wait(!valid_out);
    end
endtask

task insert_header_check_2;
    input [DATA_BYTE_WD-1 : 0] keep_insert ;
    input [DATA_BYTE_WD-1:0] keep_in_last ;
    input [7:0]              data_num;
    begin
        data_in = $urandom;
        send_axi_stream_data(data_in);
        @(posedge clk);
        data_insert = $urandom;
        send_axi_stream_header(data_insert, keep_insert);
        @(posedge clk);
        @(posedge clk);
        repeat(data_num - 1) begin
            data_in = $urandom;
            send_axi_stream_data(data_in);
            @(posedge clk);
        end
        data_in = $urandom;
        send_axi_stream_data_last(data_in,keep_in_last);
        wait(last_out)
            valid_insert = 0;
        wait(!valid_out);
    end
endtask

initial 
begin
	clk		= 'd0;
	rst_n	= 'd0;
	ready_out =1'b1;
	valid_in = 0;
	data_in = 0;
	keep_in = 0;
	last_in = 0;
	valid_insert = 0;
	data_insert = 0;
	keep_insert = 0;
	byte_insert_cnt = 0;
	#20;
    rst_n = 1;
	@(posedge clk);
	insert_header_check_1(4'b0111,4'b1110,3);
    insert_header_check_1(4'b0001,4'b1111,4);
    insert_header_check_1(4'b0011,4'b1100,10);
    insert_header_check_2(4'b0011,4'b1000,5);
    insert_header_check_2(4'b0011,4'b1100,3);
end

endmodule