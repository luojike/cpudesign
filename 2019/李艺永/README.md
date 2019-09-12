## Intro

- `circuits` directory contains a hardware design of a basic RV32I core.
- `simulator` directory contains a simulator of a basic RV32I core written in Dlang.

## Circuits

### Requirements

- POSIX compliant OS(I've been developing this under OS X. All other *nix should be the same)
- GHDL version 0.36
- GNU make

Once you've cloned this repo, make sure your cwd is set to `circuits`, which should be at the same level as this README.md file. Run `make` to analyse, elaborate and run testbench on RV32I core. If you change the those source file, you can run `make analyse` to analyse(compile) the circuits and `make elaborate` to elaborate(link).

## Simulator

### Rquirements

- POSIX compliant OS(I've been developing this under OS X. All other *nix should be the same)
- D compiler(preferrably [DMD](http://dlang.org/download.html))
- GNU make

Allow me to explain why D as the chosen language:

- You're instantly capable of reading D code if you're familiar with C++, thanks to its familarity. I've only used a limited subset of D, which should be concise and simple.
- No header files or namespaces are needed.
- Garbage collector is on by default, freeing from managing memory manually.
- D is much simpler but way as powerful as C++.

TODO: finish the simulator.