<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## What is it

- This is a tiniest ASIC GPU.  It can render a quad using two triangles with texture mapped.
- The chip comes with two texture ROM images. (My schools' logo)
- The transformation, lighting and rasterization are done in the GPU.
- It support solid shading with one directional light source and affine texture mapping.
- All 3D data (coordinates, transformation, render mode) are sent from the PC each frame via a COM port.
- The output is sent to the VGA monitor using TinyVGA.  The output resolution is 640x480 pixels, 6-bit RGB.
- The clock fequency is 50 Mhz.

## Folders

1. src: ASIC Verilog version
2. Basys3: Verilog version targeted Basys3 FPGA board
3. Verilator_sim: Verilog simulation version using Verilator and SDL
4. test_software: PC app used to sending data to the GPU

## How to test

Plugin a TinyVGA PMOD, connect at the port uio. \
Send UART command to control the GPU via serial console, ui_in[3] - RX


   
   
