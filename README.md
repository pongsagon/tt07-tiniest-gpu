![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

![](https://github.com/pongsagon/tt07-tiniest-gpu/blob/main/test_software/tt-ezgif.com-crop.gif)
![](https://github.com/pongsagon/tt07-tiniest-gpu/blob/main/test_software/pic.jpg)

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

## How to use

[Please see this note on how to play with the GPU using the test_software](test_software/readme.md)


## How it work

- Fixed point
   - All of the calculation are done in fixed point.
   - The format of the fixed point is depend on the type of variables to save register space as much as possible. Thus, they are a lot of bit operation in the code to transiton between fixed point formats.
- Modules
   - ia.v (input assembly)
      - manage reading data (60 bytes each frame) from UART and save to the registers 
   - vs.v (vertex stage)
      - transform vertices from world space to screen space
      - compute lighting intensity color for each triangle
      - compute triangles' edge parameters and barycentric coordinates 
   - raster.v
      - rasterization two triangles, interpolate color, texture mapping 
- No framebuffer or linebuffer
   -  Each pixel color has to be computed in 2 clock cycles.
   -  the rasterization is running in parallel with the vertex stage.
   -  Using incremental edge function to do pixel-triangle inside test.
- Computation steps
   1. read data from the PC via UART (in project.v, ia.v)
   2. for each frame (in vs.v)
      - transform vertices to screen space and compute lighting
      - (done during VBlank) compute triangles' edge parameters and barycentric coordinates
      - all of these calculation are done in 82 states and use around 2,000 clock cycles.
   4. for each scanline (in vs.v, raster.v)
      - done in 1 clock cycle
      - increment edge functions parameters of each scanline
      - increment barycentric parameters of each scanline
   5. for each pixel (in raster.v)
      - 1st clock cycle:
         - check pixel inside/outside of which triangles
         - compute interpolated (u,v) of this pixel, get texel color from this (u,v)
      - 2nd clock cycle:
         - color the pixel using texel color or light intensity color
         - actually the texture ROM is monochorme, the color is hardcoded using (u,v) coordinate.



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
