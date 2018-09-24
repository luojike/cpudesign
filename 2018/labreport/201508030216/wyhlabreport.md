# 实验报告
## RISC-V基本指令集模拟器设计与实现
班级：通信1502

学号：201508030216

姓名：王雨恒

## 实验目标
设计一个CPU迷你器，能模拟CPU指令集的功能

## 实验要求
* 采用C/C++编写程序
* 模拟器的输入
* 模拟器的输出是CPU各个寄存器的状态和相关的存储器单元状态

## 实验内容
### CPU指令集
CPU的指令集请见[这里](https://riscv.org/specifications/)，其中基本指令集共有_47_条指令。
所需写入的指令为

### 模拟器程序框架
考虑到CPU执行指令的流程为：
1. 取指
2. 译码
3. 执行（包括运算和结果写回）

对模拟器程序的框架设计如下：
```C++
 while(1) {
    inst = fetch(cpu.pc);
    cpu.pc = cpu.pc + 4;
    
    inst.decode();
    
    switch(inst.opcode) {
        case ADD:
            cpu.regs[inst.rd] = cpu.regs[rs] + cpu.regs[rt];
            break;
        case /*其它操作码*/ :
            /* 执行相关操作 */
            break;
        default:
            cout << "无法识别的操作码：” << inst.opcode;
    }
}
```
其中while循环条件可以根据需要改为模拟终止条件。

### 具体指令编码内容如下
```C++
case FENCE:
          cout<<"Do FENCE"<<endl;
          cout<<"FENCE,nop"<<endl;
          break;
case ECALL:
          cout<<"Do ECALL"<<endl;
          R[rd]=PC+4;
          break;
case CSRRW:
          cout<<"Do CSRRW"<<endl;
          R[rd] = src2 & 0x00000fff;
          R[rs2] = src1;
          break;
case CSRRC:
          cout<<"Do CSRRC"<<endl;
          R[rd] = src2 & 0x00000fff;
          R[rs2] = ~src1 & src2;
          break;
case CSRRSI:
          cout<<"Do CSRRSI"<<endl;
          R[rd] = src2 & 0x00000fff;
          R[rs2] = (zimm&0x0000001f) | src2;
          break;
```

## 测试
### 测试平台
模拟器在如下机器上进行了测试。

| 部件 | 配置 | 备注 |
| ------ | ------ | ------ |
| CPU | core i5-825U |  |
| 内存 | DDR3 8GB |  |
| 操作系统 | Windows10 | 中文版 |

## 测试记录
模拟器的测试输入如下所示
```C++
	writeWord(12, 0x00229b73);// CSRRW
	writeWord(16, 0x0022bb73);// CSRRC
	writeWord(20, 0x0022eb73);// CSRRSI
	writeWord(28, 0x0000000f);//FENCE
	writeWord(32, 0x00000073);//ECALL,默认跳转到pc为4的位置
```

执行指令之前的各寄存器的状态

![before](https://github.com/oceans1997/cpudesign/blob/master/2018/labreport/201508030216/before.png)

可以看到2号寄存器存的数值为0xfffff000，5号寄存器存的数值为0x1004。
指令的作用分别为：
CSRRW指令：原子性的交换CSR和整数寄存器的值。将CSR寄存器（2号寄存器）的旧值存放在rd中，rs1寄存器（5号寄存器）的值存放回CSR（2号寄存器）中。
CSRRC指令：读取CSR的值，将其零扩展到XLEN位，写入rd中。rs1寄存器（5号寄存器）的值被当做按位掩码指明哪些CSR（2号寄存器）中的位被置为1。
CSRRSI指令：读取CSR的值，将其零扩展到XLEN位，写入rd中。rs1寄存器字段的立即数零扩展到XLEN位的值被当做按位掩码指明哪些CSR（2号寄存器）中的位被置为0。
FENCE指令：用于顺序华其他RISC-V线程，外部设备或者协处理器看到的设备I/O和存储器访问。在本次实验中，无法实现，故直接输出“fence，Nop”。
ECALL指令：向支持的运行环境发出一个请求，这个运行环境通常是一个操作系统。

模拟器运行过程的截图如下：
CSRRW指令运行后模拟器的输出

![csrrw](https://github.com/oceans1997/cpudesign/blob/master/2018/labreport/201508030216/csrrw.png)

CSRRC指令运行后模拟器的输出

![csrrc](https://github.com/oceans1997/cpudesign/blob/master/2018/labreport/201508030216/csrrc.png)

CSRRSI指令运行后模拟器的输出

![csrrsi](https://github.com/oceans1997/cpudesign/blob/master/2018/labreport/201508030216/csrrsi.png)

FENCE指令运行后模拟器的输出

![fence](https://github.com/oceans1997/cpudesign/blob/master/2018/labreport/201508030216/fence.png)

ECALL指令运行后模拟器的输出

![ecall](https://github.com/oceans1997/cpudesign/blob/master/2018/labreport/201508030216/ecall.png)

# 分析与结论
根据分析结果，可以认为编写的模拟器实现了所要求的功能，完成了实验目标。
