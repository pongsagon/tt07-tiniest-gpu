# Overview

ASIC GPU testing app written in python run through REPL. \
https://tinytapeout.com/guides/get-started-demoboard/#accessing-the-repl \
You can just copy and paste the code in REPL \
The app will send these data, 60 bytes, each frame @11520 baud rate to the GPU
- 4 vertices world coordinate that form a quad
- 1 normalize normal
- 1 normalize light direction
- 3x4 ModelViewProjection matrix. (third row is not used)
- 1 byte render mode
  - solid shading, texture, alpha masked

The data are in the format of fixed point Q8.8 except for the 1-byte render mode. \
The code has been successfully tested on the tt07 ASIC, sending data at 60fps.

# Data corruption issue 
- Sometime data sending from PC to the demoboard's USB can be corrupted. Reconnect the board or change the PC's USB port or change the USB cable would help

   
# How to use
   - wsad: yaw, pitch
   - 123: render mode, change texture
   - You can modify the python code to changes the vertices coordinate, quad normal and light direction using code.  I have not write short cut keys for setting them.
