# Overview

ASIC GPU testing app written in C run on Windows. \
To be able to run on different OS, you may need to use different UART library. \
The app will send these data, 60 bytes, each frame @11520 baud rate to the GPU
- 4 vertices world coordinate
- 1 normal
- 1 light direction
- 4x4 ModelViewProjection matrix
- 1 byte render mode
  - solid shading, texture, alpha masked
    
The code has been successfully tested with the Basys3 board, sending data at 60fps.

# How to use
1. The code rely on SFML library for the input and windows. https://www.sfml-dev.org/tutorials/2.6/start-vc.php. \
   Plese install it first.
2. short cut keys
   - arrow key: yaw pitch
   - as: zoom
   - df: change model size
   - er: X translation
   - 012: render mode
   - 34: change texture
   - 6789: change triangle 1 color
   - uiop: change triangle 2 color

