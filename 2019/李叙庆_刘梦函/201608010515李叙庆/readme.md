
实验环境：win10 + quartus 9.0 

设计手册可实现R类指令，load，store，beq指令，如果在他的datapath基础上继续添加指令，可能会控制信号bit位不够用。
可考虑合并alu_control模块与alu模块，或者alu直接连funt位控制信号，或者增加alu_control控制信号宽度（后两者修改较快，不用重写模块）。

代码修改，指令测试中
