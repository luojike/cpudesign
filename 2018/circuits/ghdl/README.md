# GHDL的示例

本目录下的 adder.vhd 和 adder\_tb.vhd 来自于 GHDL 的[快速上手指南](http://ghdl.readthedocs.io/en/latest/using/QuickStartGuide.html)。

为了查看adder.vhd中的内部信号，另外设计了一个myprober的包，其中包含一个test信号。在adder.vhd中使用myprober包，并将adder.vhd中感兴趣的信号或表达式赋值给myprober包中的test信号。然后在adder\_tb.vhd中也使用myprober包，即可查看myprober包中的test信号，从而间接地查看了adder.vhd中的信号。
