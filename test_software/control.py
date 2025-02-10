import uselect
import sys
import math 
from machine import UART

uart = UART(0, baudrate=115200, tx=tt.pins.ui_in3.raw_pin, rx=tt.pins.uo_out4.raw_pin)
poll = uselect.poll()
poll.register(sys.stdin, uselect.POLLIN)


def LOW(x):
    return x[1].to_bytes(1, 'big')

def HIG(x):
    return x[0].to_bytes(1, 'big')

def int2fix(a):
    return a.to_bytes(2, 'big', True)

def float2fix(a):
    return int(a * 256.0)
    
def dot(a,b):
    return a[0]*b[0] + a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
    
def dot3(a,b):
    return a[0]*b[0] + a[1]*b[1] + a[2]*b[2]
    
def normalize(a):
    inv_dist = 1.0/math.sqrt(a[0]*a[0] + a[1]*a[1] + a[2]*a[2])
    return [a[0]*inv_dist,a[1]*inv_dist,a[2]*inv_dist]

def cross(a,b):
    return [a[1]*b[2] - a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]

#input float Q8.8 [+-127] 0.004
#result = int2fix(float2fix(-127))	
#print(result)      #b'\x81\x00'
#print(LOW(result)) #b'\x00'
#print(HIG(result)) #b'\x81'

#byte 0-17: v012.xyz (const)
#byte 18-23: n (const)
#byte 24-29: v dir (const)
#byte 30-53: VP (cal in float, convert to fix at the end)
#     Q8.8 [+-127] 0.004
#byte 54-58: v3.xyz (const)
#byte 59: render mode 
byte0_23 = bytearray([0x5d, 0xf9, 0x00, 0x04, 0x00, 0x00, 0x5d, 0xf9, 0x00, 0xfc,
                     0x00, 0x00, 0xa3, 0x06, 0x00, 0xfc, 0x00, 0x00, 0x00, 0x00, 
                     0x00, 0x00, 0xff, 0x00])  
# byte30_53 = bytearray([0x3a, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                       # 0xc0, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
                       # 0x01, 0xff, 0xe1, 0x1e])  
byte54_58 = bytearray([0xa3, 0x06, 0x00, 0x04, 0x00])
byte59 = b'\x00'



#init3D()
cam_yaw = 90.0
cam_pitch = 0.0
cam_zoom = 30.0
eye = [0.0,0.0,cam_zoom]
center = [0.0,0.0,0.0]
up = [0.0,1.0,0.0]
projection_row0 = [1.23,0.0,0.0,0.0]
projection_row1 = [0.0,2.75,0.0,0.0]
projection_row2 = [0.0,0.0,-1.22,-22.5]
projection_row3 = [0.0,0.0,-1.0,0.0]
viewMat_col0 = [0.0,0.0,0.0,0.0]
viewMat_col1 = [0.0,0.0,0.0,0.0]
viewMat_col2 = [0.0,0.0,0.0,0.0]
viewMat_col3 = [0.0,0.0,0.0,0.0]
vp_row0 = [0.0,0.0,0.0,0.0]
vp_row1 = [0.0,0.0,0.0,0.0]
vp_row3 = [0.0,0.0,0.0,0.0]


while True:
	if poll.poll(0):
            charRead = sys.stdin.buffer.read(1)
            if(charRead == b'a'):
                    cam_yaw -= 3
            if(charRead == b'd'):
                    cam_yaw += 3
            if(charRead == b'w'):
                    cam_pitch -= 3
            if(charRead == b's'):
                    cam_pitch += 3  
            if(cam_pitch >= 84):
                    cam_pitch = 84
            if(cam_pitch < -84):
                    cam_pitch = -84
            # define style byte[59]
            if(charRead == b'1'):
                    byte59 = b'\x40'     #suan
            if(charRead == b'2'):
                    byte59 = b'\x00'     #ddct
            if(charRead == b'3'):
                    byte59 = b'\x12'     #pb    
                  
            #updateCamEye();
            dir_x = math.cos(math.radians(cam_yaw))*math.cos(math.radians(cam_pitch))
            dir_y = math.sin(math.radians(cam_pitch))
            dir_z = math.sin(math.radians(cam_yaw))*math.cos(math.radians(cam_pitch))
            #dist = 30.0/math.sqrt(dir_x*dir_x + dir_y*dir_y + dir_z*dir_z)
            dist = 30.0
            eye_x = dir_x*dist
            eye_y = dir_y*dist
            eye_z = dir_z*dist
            eye = [eye_x,eye_y,eye_z]
            
            #lookat(eye, center, up);
            viewDir = [eye_x - center[0],eye_y - center[1],eye_z - center[2]]
            axisZ = normalize(viewDir)
            axisX = normalize(cross(up,axisZ))
            axisY = normalize(cross(axisZ,axisX))
            viewMat_col0[0] = axisX[0]
            viewMat_col0[1] = axisY[0]
            viewMat_col0[2] = axisZ[0]
            viewMat_col0[3] = 0.0
            viewMat_col1[0] = axisX[1]
            viewMat_col1[1] = axisY[1]
            viewMat_col1[2] = axisZ[1]
            viewMat_col1[3] = 0.0
            viewMat_col2[0] = axisX[2]
            viewMat_col2[1] = axisY[2]
            viewMat_col2[2] = axisZ[2]
            viewMat_col2[3] = 0.0
            viewMat_col3[0] = -1*dot3(eye,axisX)
            viewMat_col3[1] = -1*dot3(eye,axisY)
            viewMat_col3[2] = -1*dot3(eye,axisZ)
            viewMat_col3[3] = 1.0
            
            #VP = mulMatMat(ProjectionMat, ViewMat);
            vp_row0[0] = dot(projection_row0,viewMat_col0)
            vp_row0[1] = dot(projection_row0,viewMat_col1)
            vp_row0[2] = dot(projection_row0,viewMat_col2)
            vp_row0[3] = dot(projection_row0,viewMat_col3)
            vp_row1[0] = dot(projection_row1,viewMat_col0)
            vp_row1[1] = dot(projection_row1,viewMat_col1)
            vp_row1[2] = dot(projection_row1,viewMat_col2)
            vp_row1[3] = dot(projection_row1,viewMat_col3)
            vp_row3[0] = dot(projection_row3,viewMat_col0)
            vp_row3[1] = dot(projection_row3,viewMat_col1)
            vp_row3[2] = dot(projection_row3,viewMat_col2)
            vp_row3[3] = dot(projection_row3,viewMat_col3)
            
            #0-23
            for i in byte0_23:
                    bytes_val = i.to_bytes(1, 'big')
                    _ = uart.write(bytes_val)
            # 24-29
            result = int2fix(float2fix(axisZ[0]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result))
            result = int2fix(float2fix(axisZ[1]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result))
            result = int2fix(float2fix(axisZ[2]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result))
            # 30-53
            result = int2fix(float2fix(vp_row0[0]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            result = int2fix(float2fix(vp_row0[1]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result))                
            result = int2fix(float2fix(vp_row0[2]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            result = int2fix(float2fix(vp_row0[3]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result))   
            result = int2fix(float2fix(vp_row1[0]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            result = int2fix(float2fix(vp_row1[1]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result))                
            result = int2fix(float2fix(vp_row1[2]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            result = int2fix(float2fix(vp_row1[3]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            result = int2fix(float2fix(vp_row3[0]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            result = int2fix(float2fix(vp_row3[1]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result))                
            result = int2fix(float2fix(vp_row3[2]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            result = int2fix(float2fix(vp_row3[3]))	
            _ = uart.write(LOW(result))
            _ = uart.write(HIG(result)) 
            #54-58
            for i in byte54_58:
                    bytes_val = i.to_bytes(1, 'big')
                    _ = uart.write(bytes_val)
            _ = uart.write(byte59)