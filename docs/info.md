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
https://github.com/pongsagon/tt07-tiniest-gpu
1. src: ASIC Verilog version
2. Basys3: Verilog version targeted Basys3 FPGA board
3. Verilator_sim: Verilog simulation version using Verilator and SDL
4. test_software: PC app used to sending data to the GPU

## How to test

Plugin a TinyVGA PMOD, connect at the port uio. \
Send UART command to control the GPU via serial console, ui_in[3] - RX 

Please get the testing app here https://github.com/pongsagon/tt07-tiniest-gpu/tree/main/test_software \
ASIC GPU testing app written in C run on Windows. \
To be able to run on different OS, you may need to use different UART library. \
The app will send these data, 60 bytes, each frame @11520 baud rate to the GPU
- 4 vertices world coordinate that form a quad
- 1 normalize normal
- 1 normalize light direction
- 3x4 ModelViewProjection matrix. (third row is not used)
- 1 byte render mode
  - solid shading, texture, alpha masked

The data are in the format of fixed point Q8.8 except for the 1-byte render mode. \
The code has been successfully tested with the Basys3 board, sending data at 60fps.

## Run/Edit the code
1. The code rely on SFML library for the input and windows. https://www.sfml-dev.org/tutorials/2.6/start-vc.php. \
   Please install SFML first.
2. Change the COM port number in C code to match with the ASIC/FPGA port (line number 330)
3. short cut keys
   - arrow key: yaw pitch
   - as: zoom
   - df: change model size
   - er: X translation
   - 012: render mode
   - 34: change texture
   - 6789: change triangle 1 color
   - uiop: change triangle 2 color
4. You can also changes the vertices coordinate, quad normal and light direction using code.  I have not write short cut keys for setting them.

   
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
   
