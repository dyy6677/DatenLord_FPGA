`timescale 		1ns/1ns

module axi_stream_header_insert_tb(
    );
parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8 ;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

reg	clk		= 'd0;
reg	rst_n	= 'd0;
// AXI Stream reg header
reg                        valid_insert;
reg   [DATA_WD-1 : 0]      data_insert;
reg   [DATA_BYTE_WD-1 : 0] keep_insert;
wire                       ready_insert;
reg   [BYTE_CNT_WD : 0]    byte_insert_cnt; 
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
reg   [7:0]                data_num;

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

function [3:0] generate_keep_insert(input dummy);
    reg [1:0] rand_index; 
    begin
        rand_index = $random % 4; // 生成随机索引 (0-3)
        case (rand_index)
            2'b00: generate_keep_insert = 4'b1111;
            2'b01: generate_keep_insert = 4'b0111;
            2'b10: generate_keep_insert = 4'b0011;
            2'b11: generate_keep_insert = 4'b0001;
            default: generate_keep_insert = 4'b0000; 
        endcase
    end
endfunction

function [3:0] generate_keep_in(input dummy);
    reg [1:0] rand_index; 
    begin
        rand_index = $random % 4; // 生成随机索引 (0-3)
        case (rand_index)
            2'b00: generate_keep_in = 4'b1111;
            2'b01: generate_keep_in = 4'b1110;
            2'b10: generate_keep_in = 4'b1100;
            2'b11: generate_keep_in = 4'b1000;
            default: generate_keep_in = 4'b0000; 
        endcase
    end
endfunction

task send_axi_stream_header();
    begin
        valid_insert = 1;
        data_insert = $urandom;
        keep_insert = generate_keep_insert(0);
        byte_insert_cnt = count_ones(keep_insert);
    end
endtask

task send_axi_stream_data();
    begin
        valid_in = 1;
        data_in = $urandom;
        keep_in = 4'b1111;
        last_in = 1'b0;
    end
endtask

task send_axi_stream_data_last();
    begin
        valid_in = 1'b1;
        data_in = $urandom;
        keep_in = generate_keep_in(0);
        last_in = 1'b1;
        @(posedge clk);
        valid_in = 1'b0;
        data_in = 0;
        keep_in = 0;
        last_in = 1'b0;
    end
endtask

task test_case_1;//两路axi信号同时到来
    begin
        data_num = $random & 8'hFF;
        send_axi_stream_header;
        send_axi_stream_data;
        wait(ready_in);
        valid_insert = 0;
        data_insert = 0;
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
        wait(!valid_out);
    end
endtask

task test_case_2;//axi_stream_header信号先到来
    begin
        data_num = $random & 8'hFF;
        send_axi_stream_header;
        repeat($random & 4'hF)begin
            @(posedge clk);
            data_insert = 0;
            valid_insert = 0;
        end
        send_axi_stream_data;
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
        wait(!valid_out);
    end
endtask

task test_case_3;//axi_stream_data信号先到来
    begin
        data_num = $random & 8'hFF;
        send_axi_stream_data;
        repeat($random & 4'hF)begin
            @(posedge clk);
        end
        send_axi_stream_header;
        wait(ready_in);
        valid_insert = 0;
        data_insert = 0;
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
        wait(!valid_out);
    end
endtask

task test_case_4;
    begin
        data_num = $random & 8'hFF;
        send_axi_stream_header;
        @(posedge clk);
        send_axi_stream_header;
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
        wait(!valid_out);
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;  
        @(posedge clk);
        data_insert = 0;
        valid_insert = 0;
        wait(!valid_out);
    end
endtask

task test_case_5;
    begin
        data_num = $random & 8'hFF;
        send_axi_stream_header;
        repeat($random & 4'hF)begin
            @(posedge clk);
            data_insert = 0;
            valid_insert = 0;
        end
        send_axi_stream_data;
        send_axi_stream_header;
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
        wait(!valid_out);
        @(posedge clk);
        data_insert = 0;
        valid_insert = 0;
        repeat(data_num -1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
        wait(!valid_out);
    end
endtask

task test_case_6;
    begin
        data_num = $random & 8'hFF;
        send_axi_stream_data;
        send_axi_stream_header;
        send_axi_stream_header;
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
        wait(!valid_out);
        @(posedge clk);
        data_insert = 0;
        valid_insert = 0;
        repeat(data_num - 1)begin
            @(posedge clk);
            send_axi_stream_data;
        end
        send_axi_stream_data_last;    
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
    test_case_1;
    test_case_2;
    test_case_3;
    test_case_4;
    test_case_5;
    test_case_6;
end

endmodule