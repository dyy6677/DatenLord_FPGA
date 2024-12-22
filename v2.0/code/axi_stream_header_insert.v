module axi_stream_header_insert #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8 ,
	parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
)(
    input                               clk,
    input                               rst_n,
// AXI Stream input original data
    input                               valid_in,
    input     [DATA_WD-1 : 0]           data_in,
    input     [DATA_BYTE_WD-1 : 0]      keep_in,
    input                               last_in,
    output                              ready_in,
// AXI Stream output with header inserted
    output                              valid_out,
    output    [DATA_WD-1 : 0]           data_out,
    output    [DATA_BYTE_WD-1 : 0]      keep_out,
    output                              last_out,
    input                               ready_out,
// The header to be inserted to AXI Stream input
    input                               valid_insert,
    input     [DATA_WD-1 : 0]           data_insert,
    input     [DATA_BYTE_WD-1 : 0]      keep_insert,
    input     [BYTE_CNT_WD : 0]         byte_insert_cnt,
    output                              ready_insert
);

reg                              valid_out_r                       ;
reg     [DATA_WD-1 : 0]          data_out_r                        ;
reg     [DATA_BYTE_WD-1 : 0]     keep_out_r                        ;
reg     [DATA_WD-1 : 0]          data_insert_r                     ;
reg     [DATA_BYTE_WD-1 : 0]     keep_insert_r                     ;
reg     [BYTE_CNT_WD : 0]        byte_insert_cnt_r                 ;
reg                              data_insert_r_full                ;
reg     [DATA_WD-1 : 0]          data_in_r                         ;
reg     [DATA_BYTE_WD-1 : 0]     keep_in_r                         ;
reg     [1:0]                    last_in_r                         ;
reg     [1:0]                    data_in_first                     ;
reg     [2*DATA_WD-1 : 0]        data_out_temp                     ;
reg     [2*DATA_BYTE_WD-1 : 0]   keep_out_temp                     ;
reg                              valid_out_end                     ;
reg                              last_out_r                        ;
reg                              handshake_in_r                    ;
reg     [DATA_BYTE_WD-1 : 0]     keep_in_temp                      ;
wire                             handshake_insert                  ;
wire                             handshake_in                      ;
wire                             data_out_start                    ;
wire    [DATA_WD-1 : 0]          data_insert_shift                 ;
wire    [DATA_WD-1 : 0]          data_insert_shift_1               ;
wire    [DATA_BYTE_WD-1 : 0]     keep_insert_shift                 ;  

//------------------data insert register-----------------
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        data_insert_r <= 0;
        keep_insert_r <= 0;
        byte_insert_cnt_r <= 0;
    end
    else if(handshake_insert)begin
        data_insert_r <= data_insert;
        keep_insert_r <= keep_insert;
        byte_insert_cnt_r <= byte_insert_cnt;
    end
    else begin
        data_insert_r <= data_insert_r;
        keep_insert_r <= keep_insert_r;
        byte_insert_cnt_r <= byte_insert_cnt_r;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        data_insert_r_full <= 1'b0;
    end
    else if(handshake_insert)begin
        data_insert_r_full <= 1'b1;
    end
    else if(last_out)begin//传输完毕
        data_insert_r_full <= 1'b0;
    end
end

//------------------data in register-----------------
always@(*)begin
    if(!rst_n)begin
        data_in_r <= 0;
        keep_in_r <= 0;
    end
    else begin
        data_in_r <= data_in;
        keep_in_r <= keep_in;
    end
end

//------------------control signal-----------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        data_in_first <= 2'b0;
    end
    else 
        data_in_first[0] <= handshake_in;
        data_in_first[1] <= data_in_first[0];
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        handshake_in_r <= 1'b0;
    end
    else 
        handshake_in_r <= handshake_in;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        last_in_r <= 2'b0;
    end
    else begin
        last_in_r[0] <= last_in;
        last_in_r[1] <= last_in_r[0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        keep_in_temp <= 4'b0;
    end
    else if(last_in)begin
        keep_in_temp <= keep_in;
    end
    else begin
        keep_in_temp <= 4'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        valid_out_end <= 1'b0;
    end
    else if(last_out_r)begin
        valid_out_end <= 1'b1;
    end
    else begin
        valid_out_end <= 1'b0;
    end
end

//------------------data process-------------------
always @(*) begin
    if (!rst_n) begin
        data_out_temp = 0;
        keep_out_temp = 0;
    end
    else if (data_out_start) begin //diyipai
        data_out_temp[2*DATA_WD-1 : 0] = {data_insert_r,data_in_r};
        data_out_temp = data_out_temp << data_insert_shift;
        keep_out_temp[2*DATA_BYTE_WD-1 : 0] = {keep_insert_r,keep_in_r};
        keep_out_temp = keep_out_temp << keep_insert_shift;
    end
    else if (handshake_in)begin
        data_out_temp = data_out_temp << data_insert_shift_1;
        data_out_temp[DATA_WD-1 : 0] = data_in_r;
        data_out_temp = data_out_temp << data_insert_shift;
        keep_out_temp = keep_out_temp << byte_insert_cnt_r;
        keep_out_temp[DATA_BYTE_WD-1:0] = keep_in_r;
        keep_out_temp = keep_out_temp << keep_insert_shift;
    end
    else begin
        data_out_temp = data_out_temp;
        keep_out_temp = keep_out_temp; 
    end
end


always @(*) begin
    if(!rst_n)begin
        data_out_r <= 0;
        keep_out_r <= 0;
    end
    else if(handshake_in) begin  
        data_out_r <= data_out_temp[2*DATA_WD-1:DATA_WD];
        keep_out_r  <= keep_out_temp[2*DATA_BYTE_WD-1:DATA_BYTE_WD];
    end
    else if(last_out_r)begin 
        data_out_r <= data_out_temp[DATA_WD-1:0];
        keep_out_r  <= keep_out_temp[DATA_BYTE_WD-1:0];
    end
    else begin
        data_out_r <= 0;
        keep_out_r <= 0;
    end
end

always @(*) begin
if(!rst_n)begin
        valid_out_r <= 0;
    end
    else if(handshake_in)begin //last
        valid_out_r <= 1;
    end
    else if(valid_out_end) begin
        valid_out_r <= 0;
    end
    else begin
        valid_out_r <= valid_out_r;
    end
end

always @(*) begin
if(!rst_n)begin
        last_out_r <= 0;
    end
    else if(handshake_in)begin //last
        if((keep_in_r & keep_insert_r) == 4'b0000)begin
            last_out_r <= last_in;
        end
        else begin
            last_out_r <= last_in_r[0];
        end
    end
    else begin
        if((keep_in_temp  & keep_insert_r) == 4'b0000)begin
            last_out_r <= last_in;
        end
        else begin
            last_out_r <= last_in_r[0];
        end
    end
end

//------------------control signal && output-----------------
assign ready_insert   = !data_insert_r_full;
assign ready_in         =  data_insert_r_full; 
assign handshake_insert = valid_insert & ready_insert;
assign handshake_in = valid_in & ready_in;
assign data_out_start = (handshake_in & !data_in_first[0]);
assign data_insert_shift = (4-byte_insert_cnt_r)<<3;
assign data_insert_shift_1 = byte_insert_cnt_r<<3;
assign keep_insert_shift = (4-byte_insert_cnt_r);
assign valid_out = valid_out_r;
assign data_out = data_out_r;
assign keep_out = keep_out_r;
assign last_out = last_out_r;
endmodule