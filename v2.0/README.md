## README

### v2.0改进

* 1.乘法：将原来的计算data_insert_shift部分的 *8 更改为了 <<3（综合工具应该会自动将乘2^n优化为左移n位）。

* 2.减少了输出延迟，当两路axi_stream信号都到来后只**延迟一拍**输出。

* 3.解决了当最后一拍的data_in到来后data_in变为0时最后一拍数据丢失的问题。

* 4.增加了更多情景下的仿真验证，控制信号采用随机生成的激励，将byte_insert_cnt信号的位宽改为3：

test_case_1：同时到来一拍的header信号与连续多拍的data信号。

test_case_1：先到来一拍的header信号，若干拍之后再到来连续多拍的data信号。

test_case_3：先到来一拍的data信号，若干拍之后再到来一拍的header信号和连续多拍的data信号。

test_case_4：先到来两拍的header信号，第二拍header保持直到接收，接着到来两次连续多拍的data信号。

test_case_5：先到来一拍的header信号，若干拍之后，同时到来第二个header信号和连续多拍的data信号，第一次输出结束后到再来连续多拍的data信号。

test_case_6：先到来一拍的data信号，若干拍之后再到两个header信号，接着到来两次连续多拍的data信号。