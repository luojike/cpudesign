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
```
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
```
case 

```

## 测试
### 测试平台
模拟器的测试输入如下所示。
| 部件 | 配置 | 备注 |
| ------ | ------ | ------ |
| CPU | core i5-825U |  |
| 内存 | DDR3 8GB |  |
| 操作系统 | Windows10 | 中文版 |

## 测试记录

# 分析与结论
