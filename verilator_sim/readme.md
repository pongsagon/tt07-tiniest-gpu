# Overview

The main different between this Verilator simulation and the ASIC is that \
the sim does not use UART to send data to the GPU.
The data are directly send to the GPU input signals each frame.

The sim version can switch among 3 textures instead of 2 in the ASIC. 

# How to run

1. install Verilator and SDL
2. Building and running
   verilator -I../ -cc project.v --exe project.cpp -o project \
    -CFLAGS "$(sdl2-config --cflags)" -LDFLAGS "$(sdl2-config --libs)"

    make -C ./obj_dir -f Vproject.mk


For more detail on how to use Verilator, please visit this great tutorial of Will Green.
https://projectf.io/posts/verilog-sim-verilator-sdl/
