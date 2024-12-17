## README

### code:

rtl和testbench代码

### sim_result

Modelsim仿真结果截图及波形文件

### 说明

* 对header相关信号缓存一拍，并通过其缓存满信号(data_insert_r_full)来反压data相关的这一路AXI stream信号，由此保证当接收到data信号时，已经缓存了header信号，可以直接对信号进行处理。

* 仿真验证了几种典型情况，输入header和data信号由$urandom随机产生：

insert_header_check_1（keep_insert ，keep_in_last，data_num）：验证不同header长度，不同最后一个data长度下，突发传输data_num个数据的情况。

insert_header_check_2（keep_insert ，keep_in_last，data_num）：验证当data信号先到来，对data路信号进行反压，不丢数据的情况。

* 题目给出的header路byte_insert_cnt信号位宽为2，当keep_insert = 4‘b1111时，byte_insert_cnt为4会发生溢出，测试时没有设置keep_insert全1的情况。

### 仿真结果

![sim_result1](https://github.com/dyy6677/DatenLord_FPGA/blob/main/sim_result/sim_result1.png)

keep_insert=4'b0111,keep_in_last=4'b1110连续传输10个数据

![sim_result1](https://github.com/dyy6677/DatenLord_FPGA/blob/main/sim_result/sim_result2.png)

keep_insert=4'b0011,keep_in_last=4'b1100连续传输10个数据

![sim_result1](https://github.com/dyy6677/DatenLord_FPGA/blob/main/sim_result/sim_result3.png)

data路数据先到来，进行反压，keep_insert=4'b0011,keep_in_last=4'b1000，连续传输6个数据
