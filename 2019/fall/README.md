# 2019年秋季课程实验安排

## 实验任务

必做：
1. 完成一个模拟RISC-V的基本整数指令集RV32I的汇编器设计
2. 完成一个模拟RISC-V的基本整数指令集RV32I的模拟器设计
3. 完成一个简单存储器的设计
4. 完成一个执行RISC-V的基本整数指令集RV32I的CPU设计（单周期实现）

选做：
1. 完成一个执行RISC-V的基本整数指令集RV32I的CPU设计（流水线实现）
2. 其它经教师确认的任务，例如调试器、编译器，或者RV32I之外的扩展指令集CPU设计

## 实验要求

硬件设计采用VHDL或Verilog语言，软件设计采用C/C++或SystemC语言，其它语言例如Chisel、MyHDL等也可选。

实验报告采用markdown语言，或者直接上传PDF文档

实验最终提交所有代码和文档

## 实验组织

独立完成实验任务。

请各自在[课程的github网站](https://github.com/luojike/cpudesign)的2019/fall目录下创建本人的子目录，最好用学号姓名来命名，以免与别人混淆，每个人负责将自己代码和报告上传到自己的子目录下。

## 考核标准

考核分数综合报告质量（50%）、代码质量（50%）。

报告分数根据格式是否规范、条理是否清晰、文字是否通顺、数据记录和分析是否详尽评分，代码分数根据是否能编译运行，实现所需功能以及代码排版风格评分。

## 参考资料

1. RISC-V官方指令集手册. [https://riscv.org/specifications/](https://riscv.org/specifications/). 已上传，点击[这里](https://github.com/luojike/cpudesign/blob/master/2019/riscv-spec.pdf)下载
2. RISC-V资源列表. [https://cnrv.io/resource](https://cnrv.io/resource).
3. 武汉聚芯和北京九天的蜂鸟E200系列处理器GitHub网页. [https://github.com/SI-RISCV/e200_opensource](https://github.com/SI-RISCV/e200_opensource).

