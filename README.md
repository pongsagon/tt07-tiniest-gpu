![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# WIP

- updating

## Folders

1. src: ASIC Verilog version
2. Basys3: Verilog version targeted Basys3 FPGA board
3. Verilator_sim: Verilog simulation version using Verilator and SDL
4. test_software: PC app used to sending data to the GPU

## Acknowledgment

This project has used/modified some modules form the opensource community. 
1. Dr. Pong P. Chu, Great book on learning Verilog "FPGA Prototyping By Verilog Examples" 
   - for the UART modules, and the adapted code by David J. Marion (FPGADude). https://github.com/FPGADude/Digital-Design 
2. Will Green, Projectf.io great tutorial. 
   - for the divider module. https://github.com/projf/projf-explore 
3. Dr. Dan Gisselquist, of Zip CPU. many interesting blog post on HDL.
   - for the multiplication module.  https://github.com/ZipCPU/fwmpy
4. Uri Shaked
   - for the trick on image ROM and python image2ROM conversion utilites, https://github.com/TinyTapeout/tt07-dvd-screensaver
     
I have learned a lot from your works and many super helpful people on the TinyTapout discord. Thanks you
