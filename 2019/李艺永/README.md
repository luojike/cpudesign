## Intro

- `circuits` directory contains a hardware design of a basic RV32I core.
- `simulator` directory contains a simulator of a basic RV32I core written in Dlang.
- `devnotes` directory contains my design decisions or miscs during development.
- `labreport` directory contains the formal reports.

## Circuits

### Requirements

- POSIX compliant OS(FreeBSD, Linux, macOS)
- GHDL version 0.36
- GNU make
- Gtkwave(optional) for viewing the vcd wave file

Once you've cloned this repo, make sure your cwd is set to `circuits`, which should be at the same level as this README.md file. 
Run `make` to analyse, elaborate and run testbench on RV32I core. If you change the those source file, you can run `make analyse` to analyse(compile) the circuits and `make elaborate` to elaborate(link).

Also run `make %_testbench` to elaborate and run component testbenches, where `%_testbench` is any file that matches the pattern `xxx_testbench.vhdl`.

You'll have to press `ctrl + c` to terminate it.

## Simulator

### Rquirements

- POSIX compliant OS(FreeBSD, Linux, macOS)
- D compiler(preferrably [DMD](http://dlang.org/download.html))
- GNU make

The reasons that D was chosen:

- Similarity with C/C++. Much simpler that C++.
- Blazing fast compilation compared to C++.
- Header files are not mandatory, thanks to D's intuitive and convient module system.
- Auto memory management with garbage collector on by default.

This simulator is an interpreter in essence. You can easily scan through the code and grasp the idea. Once you've cloned this repo, make sure your cwd is set to `simulator`, which should be at the same level as this README.md file.

Run `make` to build the executable and `rv32i example.bin` to run the interpreter.
Also run `make debug` to run unittests on modules.