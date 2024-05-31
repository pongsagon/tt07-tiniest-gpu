//
// UART communication to FPGA/ASIC
// - HW files: https://github.com/pongsagon/tt07-tiniest-gpu
// - use SFML to get user input
// 
// serial communication adapted from Ted Burke - last updated 13-2-2013
//  - https://batchloaf.wordpress.com/2013/02/13/writing-bytes-to-a-serial-port-in-c/
// 
// 
//
//
// 



#include <SFML/Graphics.hpp>
#include <SFML/System/Clock.hpp>
#include <iostream>
#include <windows.h>
#include <stdio.h>
#include <math.h>

#include "fix.h"

fix14 dot14(Vec3f14 v1, Vec3f14 v2) {
    return multfix14(v1.x, v2.x) + multfix14(v1.y, v2.y) + multfix14(v1.z, v2.z);
}

fix   dot(Vec3f v1, Vec3f v2) {
    return multfix(v1.x, v2.x) + multfix(v1.y, v2.y) + multfix(v1.z, v2.z);
}

fix   dot4(Vec4f v1, Vec4f v2) {
    return  multfix(v1.x, v2.x) + multfix(v1.y, v2.y) + multfix(v1.z, v2.z) + multfix(v1.w, v2.w);
}

Vec3f cross(Vec3f v1, Vec3f v2) {
    Vec3f result;
    result.x = multfix(v1.y, v2.z) - multfix(v1.z, v2.y);
    result.y = multfix(v1.z, v2.x) - multfix(v1.x, v2.z);
    result.z = multfix(v1.x, v2.y) - multfix(v1.y, v2.x);
    return result;
}


Vec3f normalize(Vec3f v) {
    // watch out!, can easily overflow, ex. 10x10 + 10x10 + 10x10 = 300 > 127
    fix sqrdist = multfix(v.x, v.x) + multfix(v.y, v.y) + multfix(v.z, v.z);
    fix dist = sqrtfix(sqrdist);
    if (dist == 0)
        printf("divide by zero \n");
    fix inv_dist = divfix(int2fix(1), dist);
    Vec3f result;
    result.x = multfix(v.x, inv_dist);
    result.y = multfix(v.y, inv_dist);
    result.z = multfix(v.z, inv_dist);
    return result;
}


Vec4f mulMatVec(Mat4f mat, Vec4f v) {
    Vec4f result;
    result.x = dot4(mat.row0, v);
    result.y = dot4(mat.row1, v);
    result.z = dot4(mat.row2, v);
    result.w = dot4(mat.row3, v);
    return result;
}

Mat4f mulMatMat(Mat4f mat1, Mat4f mat2) {
    Mat4f result;
    Vec4f mat2col0 = { mat2.row0.x, mat2.row1.x,mat2.row2.x,mat2.row3.x };
    Vec4f mat2col1 = { mat2.row0.y, mat2.row1.y,mat2.row2.y,mat2.row3.y };
    Vec4f mat2col2 = { mat2.row0.z, mat2.row1.z,mat2.row2.z,mat2.row3.z };
    Vec4f mat2col3 = { mat2.row0.w, mat2.row1.w,mat2.row2.w,mat2.row3.w };
    result.row0.x = dot4(mat1.row0, mat2col0);
    result.row0.y = dot4(mat1.row0, mat2col1);
    result.row0.z = dot4(mat1.row0, mat2col2);
    result.row0.w = dot4(mat1.row0, mat2col3);
    result.row1.x = dot4(mat1.row1, mat2col0);
    result.row1.y = dot4(mat1.row1, mat2col1);
    result.row1.z = dot4(mat1.row1, mat2col2);
    result.row1.w = dot4(mat1.row1, mat2col3);
    result.row2.x = dot4(mat1.row2, mat2col0);
    result.row2.y = dot4(mat1.row2, mat2col1);
    result.row2.z = dot4(mat1.row2, mat2col2);
    result.row2.w = dot4(mat1.row2, mat2col3);
    result.row3.x = dot4(mat1.row3, mat2col0);
    result.row3.y = dot4(mat1.row3, mat2col1);
    result.row3.z = dot4(mat1.row3, mat2col2);
    result.row3.w = dot4(mat1.row3, mat2col3);

    return result;
}

fix  fixSin(short i) {
    while (i < 0) i += 360;
    while (i >= 360) i -= 360;
    if (i < 90)  return(sinTable[i]); else
        if (i < 180) return(sinTable[180 - i]); else
            if (i < 270) return(-sinTable[i - 180]); else
                return(-sinTable[360 - i]);
}

fix  fixCos(short i) {
    return fixSin(i + 90);
}

fix32   dot32(Vec3f32 v1, Vec3f32 v2) {
    return multfix32(v1.x, v2.x) + multfix32(v1.y, v2.y) + multfix32(v1.z, v2.z);
}

fix32   dot432(Vec4f32 v1, Vec4f32 v2) {
    return  multfix32(v1.x, v2.x) + multfix32(v1.y, v2.y) + multfix32(v1.z, v2.z) + multfix32(v1.w, v2.w);
}

Vec3f32 cross32(Vec3f32 v1, Vec3f32 v2) {
    Vec3f32 result;
    result.x = multfix32(v1.y, v2.z) - multfix32(v1.z, v2.y);
    result.y = multfix32(v1.z, v2.x) - multfix32(v1.x, v2.z);
    result.z = multfix32(v1.x, v2.y) - multfix32(v1.y, v2.x);
    return result;
}

Vec3f32 normalize32(Vec3f32 v) {
    fix32 sqrdist = multfix32(v.x, v.x) + multfix32(v.y, v.y) + multfix32(v.z, v.z);
    fix32 dist = sqrtfix32(sqrdist);
    if (dist == 0)
        printf("divide by zero 32 \n");
    fix32 inv_dist = divfix32(int2fix32(1), dist);
    Vec3f32 result;
    result.x = multfix32(v.x, inv_dist);
    result.y = multfix32(v.y, inv_dist);
    result.z = multfix32(v.z, inv_dist);
    return result;
}

Vec3f32 normalizeScale32(Vec3f32 v, fix32 scale) {
    fix32 sqrdist = multfix32(v.x, v.x) + multfix32(v.y, v.y) + multfix32(v.z, v.z);
    fix32 dist = sqrtfix32(sqrdist);
    fix32 inv_dist = divfix32(int2fix32(1), dist);
    fix32 inv_distScale = multfix32(inv_dist, scale);
    Vec3f32 result;
    result.x = multfix32(v.x, inv_distScale);
    result.y = multfix32(v.y, inv_distScale);
    result.z = multfix32(v.z, inv_distScale);
    return result;
}

Vec4f32 mulMatVec32(Mat4f32 mat, Vec4f32 v) {
    Vec4f32 result;
    result.x = dot432(mat.row0, v);
    result.y = dot432(mat.row1, v);
    result.z = dot432(mat.row2, v);
    result.w = dot432(mat.row3, v);
    return result;
}

Mat4f32 mulMatMat32(Mat4f32 mat1, Mat4f32 mat2) {
    Mat4f32 result;
    Vec4f32 mat2col0 = { mat2.row0.x, mat2.row1.x,mat2.row2.x,mat2.row3.x };
    Vec4f32 mat2col1 = { mat2.row0.y, mat2.row1.y,mat2.row2.y,mat2.row3.y };
    Vec4f32 mat2col2 = { mat2.row0.z, mat2.row1.z,mat2.row2.z,mat2.row3.z };
    Vec4f32 mat2col3 = { mat2.row0.w, mat2.row1.w,mat2.row2.w,mat2.row3.w };
    result.row0.x = dot432(mat1.row0, mat2col0);
    result.row0.y = dot432(mat1.row0, mat2col1);
    result.row0.z = dot432(mat1.row0, mat2col2);
    result.row0.w = dot432(mat1.row0, mat2col3);
    result.row1.x = dot432(mat1.row1, mat2col0);
    result.row1.y = dot432(mat1.row1, mat2col1);
    result.row1.z = dot432(mat1.row1, mat2col2);
    result.row1.w = dot432(mat1.row1, mat2col3);
    result.row2.x = dot432(mat1.row2, mat2col0);
    result.row2.y = dot432(mat1.row2, mat2col1);
    result.row2.z = dot432(mat1.row2, mat2col2);
    result.row2.w = dot432(mat1.row2, mat2col3);
    result.row3.x = dot432(mat1.row3, mat2col0);
    result.row3.y = dot432(mat1.row3, mat2col1);
    result.row3.z = dot432(mat1.row3, mat2col2);
    result.row3.w = dot432(mat1.row3, mat2col3);

    return result;
}

fix32  fixSin32(short i) {
    while (i < 0) i += 360;
    while (i >= 360) i -= 360;
    if (i < 90)  return(sinTable32[i]); else
        if (i < 180) return(sinTable32[180 - i]); else
            if (i < 270) return(-sinTable32[i - 180]); else
                return(-sinTable32[360 - i]);
}

fix32  fixCos32(short i) {
    return fixSin32(i + 90);
}

// graphics.h.cpp
// init fix constant
fix fix_0 = int2fix(0);
fix fix_1 = int2fix(1);
fix fix_32 = int2fix(32);
fix fix_64 = int2fix(64);
fix fix_neg1 = float2fix(-1);
fix fix_neg10 = float2fix(-10);
fix fix_neg100 = float2fix(-100);
fix fix_nearclip = float2fix(-3);
//
fix32   fix32_1 = int2fix32(1);
fix32   fix32_160 = int2fix32(160);
fix32   fix32_120 = int2fix32(120);
//
fix14   fix14_0 = int2fix14(0);


// transform
Mat4f ModelMat;
Mat4f ViewMat;
Mat4f ModelViewMat;
Mat4f ProjectionMat;
Mat4f VP;

// cam, light
Vec3f14  light_dir;
fix      cam_zoom;
short    cam_yaw;
short    cam_pitch;
Vec3f    eye;
Vec3f    center;
Vec3f    up;


// FOV = 40, near = 10, far = 100
void projection() {
    ProjectionMat.row0 = { float2fix(1.23), fix_0,fix_0,fix_0 };
    ProjectionMat.row1 = { fix_0, float2fix(2.75), fix_0,fix_0 };
    ProjectionMat.row2 = { fix_0, fix_0, float2fix(-1.22), float2fix(-22.5) };
    ProjectionMat.row3 = { fix_0, fix_0, float2fix(-1),fix_0 };
}


void init3D() {

    //init light, cam
    light_dir = { int2fix14(0), int2fix14(0), int2fix14(1) };
    cam_yaw = 90;
    cam_pitch = 0;
    cam_zoom = int2fix(30);
    eye = { int2fix(0),int2fix(0),cam_zoom };
    center = { float2fix(0.0),float2fix(0),int2fix(0) };
    up = { fix_0,fix_1,fix_0 };

    // set projection matrix
    projection();
}


// orbit camera 
void lookat(Vec3f eye, Vec3f center, Vec3f up) {
    // normalize non-near unit vector can easily overflow, use normalize32 just in case
    Vec3f32 viewDir32 = { eye.x - center.x,eye.y - center.y,eye.z - center.z };
    Vec3f32 z32 = normalize32(viewDir32);
    Vec3f z;
    z.x = fix322fix(z32.x);
    z.y = fix322fix(z32.y);
    z.z = fix322fix(z32.z);
    Vec3f x = normalize(cross(up, z));
    Vec3f y = normalize(cross(z, x));
    ViewMat.row0 = { x.x, x.y, x.z, dot(eye,x) };
    ViewMat.row1 = { y.x, y.y, y.z, dot(eye,y) };
    ViewMat.row2 = { z.x, z.y, z.z, dot(eye,z) };
    ViewMat.row3 = { fix_0,fix_0,fix_0,fix_1 };
    ViewMat.row0.w = multfix(ViewMat.row0.w, fix_neg1);
    ViewMat.row1.w = multfix(ViewMat.row1.w, fix_neg1);
    ViewMat.row2.w = multfix(ViewMat.row2.w, fix_neg1);
}

void updateCamEye() {
    Vec3f dir;
    dir.x = multfix(fixCos(cam_yaw), fixCos(cam_pitch));
    dir.y = fixSin(cam_pitch);
    dir.z = multfix(fixSin(cam_yaw), fixCos(cam_pitch));
    // normalizeScale non-near unit vector can easily overflow, use normalizeScale32 instead
    Vec3f32 dir32;
    dir32.x = fix2fix32(dir.x);
    dir32.y = fix2fix32(dir.y);
    dir32.z = fix2fix32(dir.z);
    Vec3f32 eye32 = normalizeScale32(dir32, fix2fix32(cam_zoom));
    eye.x = fix322fix(eye32.x);
    eye.y = fix322fix(eye32.y);
    eye.z = fix322fix(eye32.z);
}

//https://stackoverflow.com/questions/111928/is-there-a-printf-converter-to-print-in-binary-format
// Assumes little endian
void printBits(size_t const size, void const* const ptr)
{
    unsigned char* b = (unsigned char*)ptr;
    unsigned char byte;
    int i, j;

    for (i = size - 1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    printf("\n");
}

sf::RenderWindow window;


int main()
{
    //////////////////////////////////////////////
    // Serial setup
    // ///////////////////////////////////////////
    
    char bytes_to_send[61];

    // Declare variables and structures
    HANDLE hSerial;
    DCB dcbSerialParams = { 0 };
    COMMTIMEOUTS timeouts = { 0 };

    // Open the highest available serial port number
    fprintf(stderr, "Opening serial port...");
    hSerial = CreateFile(
        "\\\\.\\COM8", GENERIC_READ | GENERIC_WRITE, 0, NULL,
        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hSerial == INVALID_HANDLE_VALUE)
    {
        fprintf(stderr, "Error\n");
        return 1;
    }
    else fprintf(stderr, "OK\n");

    // Set device parameters (115200 baud, 1 start bit,
    // 1 stop bit, no parity)
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (GetCommState(hSerial, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error getting device state\n");
        CloseHandle(hSerial);
        return 1;
    }

    dcbSerialParams.BaudRate = CBR_115200;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    if (SetCommState(hSerial, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error setting device parameters\n");
        CloseHandle(hSerial);
        return 1;
    }
    // Set COM port timeout settings
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    if (SetCommTimeouts(hSerial, &timeouts) == 0)
    {
        fprintf(stderr, "Error setting timeouts\n");
        CloseHandle(hSerial);
        return 1;
    }
    
    //////////////////////////////////////////////
    // End Serial setup
    // ///////////////////////////////////////////
    


    // create windo
    window.create(sf::VideoMode(500, 500), "UART to ASIC");
    window.setFramerateLimit(60);

    std::cout << "<>^v: yaw pitch, as: zoom, dfer: model size, tx" << std::endl;
    std::cout << "012: render mode, 345: tex id, 6789: color1, uiop: color2" << std::endl;

    float world = 1;
    float world_offset = 0;
    char render_mode = 0;
    char tex_mode = 0;
    char color1_mode = 0;
    char color2_mode = 0;
  
    
    init3D();

    while (window.isOpen())
    {

        bool user_update = false;
        // handle event
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Left)) {
            cam_yaw -= 3;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Right)) {
            cam_yaw += 3;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Up)) {
            cam_pitch -= 3;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Down)) {
            cam_pitch += 3;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::A)) {
            cam_zoom += fix_1;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::S)) {
            cam_zoom -= fix_1;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::D)) {
            world -= 0.2;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::F)) {
            world += 0.2;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::E)) {
            world_offset -= 0.2;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::R)) {
            world_offset += 0.2;
            user_update = true;
        }
        // uv, mask, color
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num0)) {
            render_mode = 0x00;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num1)) {
            render_mode = 0x01;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num2)) {
            render_mode = 0x02;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num3)) {
            tex_mode = 0x00;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num4)) {
            tex_mode = 0b01000000;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num5)) {
            tex_mode = 0b10000000;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num6)) {
            color1_mode = 0b00000000;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num7)) {
            color1_mode = 0b00000100;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num8)) {
            color1_mode = 0b00001000;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Num9)) {
            color1_mode = 0b00001100;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::U)) {
            color2_mode = 0b00000000;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::I)) {
            color2_mode = 0b00010000;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::O)) {
            color2_mode = 0b00100000;
            user_update = true;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::P)) {
            color2_mode = 0b00110000;
            user_update = true;
        }




        if (user_update) {
            if (cam_pitch >= 84)
                cam_pitch = 84;
            if (cam_pitch < -84)
                cam_pitch = -84;
            if (cam_zoom >= int2fix(120))
                cam_zoom = int2fix(120);
            if (cam_zoom < int2fix(2))
                cam_zoom = int2fix(2);
            if (world < 0.2)
                world = 0.2;

            // div by zero when world = 0.8;
            //printf("%f\n", world);

            updateCamEye();
            lookat(eye, center, up);
            VP = mulMatMat(ProjectionMat, ViewMat);

            //send xyz_world_v012, n, light, [VP]
            //  obj center at (0,0,0) size [-10,10]
            //  world: clockwise order, Y- point up, Z+ out of the screen
            Vec3f v0 = { float2fix(-1.66 * world + world_offset),float2fix(world), float2fix(0) };
            Vec3f v1 = { float2fix(-1.66 * world + world_offset), float2fix(-world), float2fix(0) };
            Vec3f v2 = { float2fix(1.66 * world + world_offset), float2fix(-world), float2fix(0) };
            Vec3f v3 = { float2fix(1.66 * world + world_offset), float2fix(world), float2fix(0) };
            // v0
            bytes_to_send[0] = LOW(v0.x);
            bytes_to_send[1] = HIG(v0.x);
            bytes_to_send[2] = LOW(v0.y);
            bytes_to_send[3] = HIG(v0.y);
            bytes_to_send[4] = LOW(v0.z);
            bytes_to_send[5] = HIG(v0.z);
            // v1
            bytes_to_send[6] = LOW(v1.x);
            bytes_to_send[7] = HIG(v1.x);
            bytes_to_send[8] = LOW(v1.y);
            bytes_to_send[9] = HIG(v1.y);
            bytes_to_send[10] = LOW(v1.z);
            bytes_to_send[11] = HIG(v1.z);
            // v2
            bytes_to_send[12] = LOW(v2.x);
            bytes_to_send[13] = HIG(v2.x);
            bytes_to_send[14] = LOW(v2.y);
            bytes_to_send[15] = HIG(v2.y);
            bytes_to_send[16] = LOW(v2.z);
            bytes_to_send[17] = HIG(v2.z);
            // edge cross product, normalize, Q8.8
            Vec3f32 e1_32 = { fix2fix32(v1.x - v0.x), fix2fix32(v1.y - v0.y), fix2fix32( v1.z - v0.z )};
            e1_32 = normalize32(e1_32);
            Vec3f32 e2_32 = { fix2fix32(v2.x - v1.x), fix2fix32(v2.y - v1.y), fix2fix32(v2.z - v1.z) };
            e2_32 = normalize32(e2_32);
            Vec3f32 n_32 = normalize32(cross32(e1_32, e2_32));
            bytes_to_send[18] = LOW(fix322fix(n_32.x));
            bytes_to_send[19] = HIG(fix322fix(n_32.x));
            bytes_to_send[20] = LOW(fix322fix(n_32.y));
            bytes_to_send[21] = HIG(fix322fix(n_32.y));
            bytes_to_send[22] = LOW(fix322fix(n_32.z));
            bytes_to_send[23] = HIG(fix322fix(n_32.z));
            // compute light dir, = eye dir, Q8.8
            Vec3f32 viewDir32 = { fix2fix32(eye.x - center.x),fix2fix32(eye.y - center.y),fix2fix32(eye.z - center.z) };
            Vec3f32 v32 = normalize32(viewDir32);
            bytes_to_send[24] = LOW(fix322fix(v32.x));
            bytes_to_send[25] = HIG(fix322fix(v32.x));
            bytes_to_send[26] = LOW(fix322fix(v32.y));
            bytes_to_send[27] = HIG(fix322fix(v32.y));
            bytes_to_send[28] = LOW(fix322fix(v32.z));
            bytes_to_send[29] = HIG(fix322fix(v32.z));
            //
            bytes_to_send[30] = LOW(VP.row0.x);
            bytes_to_send[31] = HIG(VP.row0.x);
            bytes_to_send[32] = LOW(VP.row0.y);
            bytes_to_send[33] = HIG(VP.row0.y);
            bytes_to_send[34] = LOW(VP.row0.z);
            bytes_to_send[35] = HIG(VP.row0.z);
            bytes_to_send[36] = LOW(VP.row0.w);
            bytes_to_send[37] = HIG(VP.row0.w);
            bytes_to_send[38] = LOW(VP.row1.x);
            bytes_to_send[39] = HIG(VP.row1.x);
            bytes_to_send[40] = LOW(VP.row1.y);
            bytes_to_send[41] = HIG(VP.row1.y);
            bytes_to_send[42] = LOW(VP.row1.z);
            bytes_to_send[43] = HIG(VP.row1.z);
            bytes_to_send[44] = LOW(VP.row1.w);
            bytes_to_send[45] = HIG(VP.row1.w);
            bytes_to_send[46] = LOW(VP.row3.x);
            bytes_to_send[47] = HIG(VP.row3.x);
            bytes_to_send[48] = LOW(VP.row3.y);
            bytes_to_send[49] = HIG(VP.row3.y);
            bytes_to_send[50] = LOW(VP.row3.z);
            bytes_to_send[51] = HIG(VP.row3.z);
            bytes_to_send[52] = LOW(VP.row3.w);
            bytes_to_send[53] = HIG(VP.row3.w);
            //
            // v3
            bytes_to_send[54] = LOW(v3.x);
            bytes_to_send[55] = HIG(v3.x);
            bytes_to_send[56] = LOW(v3.y);
            bytes_to_send[57] = HIG(v3.y);
            bytes_to_send[58] = LOW(v3.z);
            //bytes_to_send[59] = HIG(v3.z);
            //
            bytes_to_send[59] = render_mode + tex_mode + color1_mode + color2_mode;

            /*for (int i = 0; i < 6; i++) {
                printBits(sizeof(bytes_to_send[i]), &bytes_to_send[i]);
            }*/
            //printBits(sizeof(bytes_to_send[60]), &bytes_to_send[60]);

            DWORD bytes_written, total_bytes_written = 0;
            //fprintf(stderr, "Sending bytes...");
            if (!WriteFile(hSerial, bytes_to_send, 60, &bytes_written, NULL))
            {
                fprintf(stderr, "Error\n");
                CloseHandle(hSerial);
                return 1;
            }
            //fprintf(stderr, "%d bytes written\n", bytes_written);
        }
        


        // draw framebuffer
        window.clear(sf::Color::Black);
        window.display();
    }

    // Close serial port
    fprintf(stderr, "Closing serial port...");
    if (CloseHandle(hSerial) == 0)
    {
        fprintf(stderr, "Error\n");
        return 1;
    }
    fprintf(stderr, "OK\n");


    return 0;
}