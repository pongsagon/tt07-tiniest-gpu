

#include <stdio.h>
#include <SDL.h>
#include <verilated.h>
#include <math.h>
#include "Vproject.h"


// fix.cpp
#include "fix.h"

fix14 dot14(Vec3f14 v1, Vec3f14 v2){
  return multfix14(v1.x,v2.x)+multfix14(v1.y,v2.y)+multfix14(v1.z,v2.z);
}

fix   dot(Vec3f v1, Vec3f v2){
  return multfix(v1.x,v2.x)+multfix(v1.y,v2.y)+multfix(v1.z,v2.z);
}

fix   dot4(Vec4f v1, Vec4f v2){
  return  multfix(v1.x,v2.x)+multfix(v1.y,v2.y)+multfix(v1.z,v2.z)+multfix(v1.w,v2.w);
}

Vec3f cross(Vec3f v1, Vec3f v2){
  Vec3f result;
  result.x = multfix(v1.y,v2.z)-multfix(v1.z,v2.y);
  result.y = multfix(v1.z,v2.x)-multfix(v1.x,v2.z);
  result.z = multfix(v1.x,v2.y)-multfix(v1.y,v2.x);
  return result;
}


Vec3f normalize(Vec3f v){
  // watch out!, can easily overflow, ex. 10x10 + 10x10 + 10x10 = 300 > 127
  fix sqrdist = multfix(v.x,v.x)+multfix(v.y,v.y)+multfix(v.z,v.z);
  fix dist = sqrtfix(sqrdist);
  if (dist == 0) 
    printf("divide by zero \n");
  fix inv_dist = divfix(int2fix(1),dist);
  Vec3f result;
  result.x = multfix(v.x,inv_dist);
  result.y = multfix(v.y,inv_dist);
  result.z = multfix(v.z,inv_dist);
  return result;
}


Vec4f mulMatVec(Mat4f mat, Vec4f v){
  Vec4f result;
  result.x = dot4(mat.row0, v);
  result.y = dot4(mat.row1, v);
  result.z = dot4(mat.row2, v);
  result.w = dot4(mat.row3, v);
  return result;
}

Mat4f mulMatMat(Mat4f mat1, Mat4f mat2){
  Mat4f result;
  Vec4f mat2col0 = {mat2.row0.x, mat2.row1.x,mat2.row2.x,mat2.row3.x};
  Vec4f mat2col1 = {mat2.row0.y, mat2.row1.y,mat2.row2.y,mat2.row3.y};
  Vec4f mat2col2 = {mat2.row0.z, mat2.row1.z,mat2.row2.z,mat2.row3.z};
  Vec4f mat2col3 = {mat2.row0.w, mat2.row1.w,mat2.row2.w,mat2.row3.w};
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

fix  fixSin(short i){
  while(i<0) i+=360;
  while(i>=360) i-=360;
  if(i<90)  return(sinTable[i]); else
  if(i<180) return(sinTable[180-i]); else
  if(i<270) return(-sinTable[i-180]); else
            return(-sinTable[360-i]);
}

fix  fixCos(short i){
  return fixSin(i + 90);
}

fix32   dot32(Vec3f32 v1, Vec3f32 v2){
  return multfix32(v1.x,v2.x)+multfix32(v1.y,v2.y)+multfix32(v1.z,v2.z);
}

fix32   dot432(Vec4f32 v1, Vec4f32 v2){
  return  multfix32(v1.x,v2.x)+multfix32(v1.y,v2.y)+multfix32(v1.z,v2.z)+multfix32(v1.w,v2.w);
}

Vec3f32 cross32(Vec3f32 v1, Vec3f32 v2){
  Vec3f32 result;
  result.x = multfix32(v1.y,v2.z)-multfix32(v1.z,v2.y);
  result.y = multfix32(v1.z,v2.x)-multfix32(v1.x,v2.z);
  result.z = multfix32(v1.x,v2.y)-multfix32(v1.y,v2.x);
  return result;
}

Vec3f32 normalize32(Vec3f32 v){
  fix32 sqrdist = multfix32(v.x,v.x)+multfix32(v.y,v.y)+multfix32(v.z,v.z);
  fix32 dist = sqrtfix32(sqrdist);
  if (dist == 0) 
    printf("divide by zero 32 \n");
  fix32 inv_dist = divfix32(int2fix32(1),dist);
  Vec3f32 result;
  result.x = multfix32(v.x,inv_dist);
  result.y = multfix32(v.y,inv_dist);
  result.z = multfix32(v.z,inv_dist);
  return result;
}

Vec3f32 normalizeScale32(Vec3f32 v, fix32 scale){
  fix32 sqrdist = multfix32(v.x,v.x)+multfix32(v.y,v.y)+multfix32(v.z,v.z);
  fix32 dist = sqrtfix32(sqrdist);
  fix32 inv_dist = divfix32(int2fix32(1),dist);
  fix32 inv_distScale = multfix32(inv_dist, scale);
  Vec3f32 result;
  result.x = multfix32(v.x, inv_distScale);
  result.y = multfix32(v.y,inv_distScale);
  result.z = multfix32(v.z,inv_distScale);
  return result;
}

Vec4f32 mulMatVec32(Mat4f32 mat, Vec4f32 v){
  Vec4f32 result;
  result.x = dot432(mat.row0, v);
  result.y = dot432(mat.row1, v);
  result.z = dot432(mat.row2, v);
  result.w = dot432(mat.row3, v);
  return result;
}

Mat4f32 mulMatMat32(Mat4f32 mat1, Mat4f32 mat2){
  Mat4f32 result;
  Vec4f32 mat2col0 = {mat2.row0.x, mat2.row1.x,mat2.row2.x,mat2.row3.x};
  Vec4f32 mat2col1 = {mat2.row0.y, mat2.row1.y,mat2.row2.y,mat2.row3.y};
  Vec4f32 mat2col2 = {mat2.row0.z, mat2.row1.z,mat2.row2.z,mat2.row3.z};
  Vec4f32 mat2col3 = {mat2.row0.w, mat2.row1.w,mat2.row2.w,mat2.row3.w};
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

fix32  fixSin32(short i){
  while(i<0) i+=360;
  while(i>=360) i-=360;
  if(i<90)  return(sinTable32[i]); else
  if(i<180) return(sinTable32[180-i]); else
  if(i<270) return(-sinTable32[i-180]); else
            return(-sinTable32[360-i]);
}

fix32  fixCos32(short i){
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
    ProjectionMat.row0 = (Vec4f){float2fix(1.23), fix_0,fix_0,fix_0};
    ProjectionMat.row1 = (Vec4f){fix_0, float2fix(2.75), fix_0,fix_0};
    ProjectionMat.row2 = (Vec4f){fix_0, fix_0, float2fix(-1.22), float2fix(-22.5)};
    ProjectionMat.row3 = (Vec4f){fix_0, fix_0, float2fix(-1),fix_0};
}


void init3D(){

    //init light, cam
    light_dir = (Vec3f14){int2fix14(0), int2fix14(0), int2fix14(1)};
    cam_yaw = 90;
    cam_pitch = 0;
    cam_zoom = int2fix(30);
    eye = (Vec3f){int2fix(0),int2fix(0),cam_zoom};
    center = (Vec3f){float2fix(0.0),float2fix(0),int2fix(0) };
    up = (Vec3f){fix_0,fix_1,fix_0};

  // set projection matrix
    projection();
}
 

// orbit camera 
void lookat(Vec3f eye, Vec3f center, Vec3f up) {
    // normalize non-near unit vector can easily overflow, use normalize32 just in case
    Vec3f32 viewDir32 = (Vec3f32){eye.x-center.x,eye.y-center.y,eye.z-center.z};
    Vec3f32 z32 = normalize32(viewDir32); 
    Vec3f z;
    z.x = fix322fix(z32.x);
    z.y = fix322fix(z32.y);
    z.z = fix322fix(z32.z);
    Vec3f x = normalize(cross(up,z));
    Vec3f y = normalize(cross(z,x));
    ViewMat.row0 = (Vec4f){x.x, x.y, x.z, dot(eye,x)};
    ViewMat.row1 = (Vec4f){y.x, y.y, y.z, dot(eye,y)};
    ViewMat.row2 = (Vec4f){z.x, z.y, z.z, dot(eye,z)};
    ViewMat.row3 = (Vec4f){fix_0,fix_0,fix_0,fix_1};
    ViewMat.row0.w = multfix(ViewMat.row0.w, fix_neg1);
    ViewMat.row1.w = multfix(ViewMat.row1.w, fix_neg1);
    ViewMat.row2.w = multfix(ViewMat.row2.w, fix_neg1);
}

void updateCamEye(){
  Vec3f dir;
  dir.x = multfix(fixCos(cam_yaw),fixCos(cam_pitch));
  dir.y = fixSin(cam_pitch);
  dir.z = multfix(fixSin(cam_yaw),fixCos(cam_pitch));
  // normalizeScale non-near unit vector can easily overflow, use normalizeScale32 instead
  Vec3f32 dir32;
  dir32.x = fix2fix32(dir.x);
  dir32.y = fix2fix32(dir.y);
  dir32.z = fix2fix32(dir.z);
  Vec3f32 eye32 = normalizeScale32(dir32,fix2fix32(cam_zoom));
  eye.x = fix322fix(eye32.x);
  eye.y = fix322fix(eye32.y);
  eye.z = fix322fix(eye32.z);
}


// screen dimensions
const int H_RES = 640;
const int V_RES = 480;

typedef struct Pixel {  // for SDL texture
    uint8_t a;  // transparency
    uint8_t b;  // blue
    uint8_t g;  // green
    uint8_t r;  // red
} Pixel;


//https://stackoverflow.com/questions/111928/is-there-a-printf-converter-to-print-in-binary-format
// Assumes little endian
void printBits(size_t const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;
    
    for (i = size-1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    printf("\n");
}


float world = 1;
float world_offset = 0;
char render_mode = 0;
char tex_mode = 0;
char color1_mode = 0;
char color2_mode = 0;


int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL init failed.\n");
        return 1;
    }

    Pixel screenbuffer[H_RES*V_RES];

    SDL_Window*   sdl_window   = NULL;
    SDL_Renderer* sdl_renderer = NULL;
    SDL_Texture*  sdl_texture  = NULL;

    sdl_window = SDL_CreateWindow("mario", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, H_RES, V_RES, SDL_WINDOW_SHOWN);
    if (!sdl_window) {
        printf("Window creation failed: %s\n", SDL_GetError());
        return 1;
    }

    sdl_renderer = SDL_CreateRenderer(sdl_window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!sdl_renderer) {
        printf("Renderer creation failed: %s\n", SDL_GetError());
        return 1;
    }

    sdl_texture = SDL_CreateTexture(sdl_renderer, SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_TARGET, H_RES, V_RES);
    if (!sdl_texture) {
        printf("Texture creation failed: %s\n", SDL_GetError());
        return 1;
    }

    // reference SDL keyboard state array: https://wiki.libsdl.org/SDL_GetKeyboardState
    const Uint8 *keyb_state = SDL_GetKeyboardState(NULL);

    printf("Simulation running. Press 'Q' in simulation window to quit.\n\n");

    // initialize Verilog module
    Vproject* top = new Vproject;

    // reset
    top->rst_n = 0;
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
    top->rst_n = 1;
    top->clk = 0;
    top->eval();

    uint64_t frame_count = 0;
    uint64_t start_ticks = SDL_GetPerformanceCounter();

    init3D();

    while (1) {
        // cycle 2 clock per 1 pixel
        top->clk = 1;
        top->eval();
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();
        top->clk = 0;
        top->eval();

        // update pixel if not in blanking interval
        if (top->SIM_de) {
            Pixel* p = &screenbuffer[top->SIM_sy*H_RES + top->SIM_sx];
            p->a = 0xFF;  // transparencys
            p->b = top->SIM_b;
            p->g = top->SIM_g;
            p->r = top->SIM_r;
        }

        // update texture and keyboard input once per frame (in blanking)
        if (top->SIM_sy == V_RES && top->SIM_sx == 0) {
            // check for quit event
            SDL_Event e;
            if (SDL_PollEvent(&e)) {
                if (e.type == SDL_QUIT) {
                    //break;
                }
            }

            if (keyb_state[SDL_SCANCODE_Q]) break;  // quit if user presses 'Q'



            // Sending data to HW

            top->SIM_pc_data_ready = 1;     // true for 1 clk

            if (keyb_state[SDL_SCANCODE_LEFT]){
                cam_yaw -= 4;
            }
            if (keyb_state[SDL_SCANCODE_RIGHT]){
                cam_yaw += 4;
            }
            if (keyb_state[SDL_SCANCODE_UP]){
                cam_pitch -= 4;
            }
            if (keyb_state[SDL_SCANCODE_DOWN]){
                cam_pitch += 4;
            }
            if (keyb_state[SDL_SCANCODE_A]){
                cam_zoom += fix_1;
            }
            if (keyb_state[SDL_SCANCODE_S]){
                cam_zoom -= fix_1;
            }
            if (keyb_state[SDL_SCANCODE_D]){
                world -= 0.2;
            }
            if (keyb_state[SDL_SCANCODE_F]){
                world += 0.2;
            }
            if (keyb_state[SDL_SCANCODE_E]){
                world_offset -= 0.5;
            }
            if (keyb_state[SDL_SCANCODE_R]){
                world_offset += 0.5;
            }
            // uv, mask, color
            if (keyb_state[SDL_SCANCODE_0]){
                render_mode = 0x00;
            }
            if (keyb_state[SDL_SCANCODE_1]){
                render_mode = 0x01;
            }
            if (keyb_state[SDL_SCANCODE_2]){
                render_mode = 0x02;
            }
             if (keyb_state[SDL_SCANCODE_3]){
                tex_mode = 0x00;
            }
            if (keyb_state[SDL_SCANCODE_4]){
                tex_mode = 0b01000000;
            }
            if (keyb_state[SDL_SCANCODE_5]){
                tex_mode = 0b10000000;
            }
            if (keyb_state[SDL_SCANCODE_6]){
                color1_mode = 0b00000000;
            }
             if (keyb_state[SDL_SCANCODE_7]){
                color1_mode = 0b00000100;
            }
            if (keyb_state[SDL_SCANCODE_8]){
                color1_mode = 0b00001000;
            }
            if (keyb_state[SDL_SCANCODE_9]){
                color1_mode = 0b00001100;
            }
            if (keyb_state[SDL_SCANCODE_U]){
                color2_mode = 0b00000000;
            }
             if (keyb_state[SDL_SCANCODE_I]){
                color2_mode = 0b00010000;
            }
            if (keyb_state[SDL_SCANCODE_O]){
                color2_mode = 0b00100000;
            }
            if (keyb_state[SDL_SCANCODE_P]){
                color2_mode = 0b00110000;
            }


            if(cam_pitch >= 84)
                cam_pitch = 84;
            if(cam_pitch < -84)
                cam_pitch = -84;
            if(cam_zoom >= int2fix(120))
                cam_zoom = int2fix(120);
            if(cam_zoom < int2fix(2))
                cam_zoom = int2fix(2);
            if(world < 0.2)
                world = 0.2;

            printf("cam_yaw: %i cam_pitch %i cam_zoom: %i\n", cam_yaw, cam_pitch, fix2int(cam_zoom));
            printf("world: %f\n", world);

            updateCamEye();
            lookat(eye, center, up);
            VP = mulMatMat(ProjectionMat,ViewMat);

            //send xyz_world_v012, n, light, [VP]
            //  obj center at (0,0,0) size [-10,10]
            //  world: clockwise order, Y- point up, Z+ out of the screen
            top->SIM_x_world_v0 = float2fix(-1.66*world+world_offset);
            top->SIM_y_world_v0 = float2fix(world);
            top->SIM_z_world_v0 = float2fix(0);
            //
            top->SIM_x_world_v1 = float2fix(-1.66*world+world_offset);
            top->SIM_y_world_v1 = float2fix(-world);
            top->SIM_z_world_v1 = float2fix(0);
            //
            top->SIM_x_world_v2 = float2fix(1.66*world+world_offset);
            top->SIM_y_world_v2 = float2fix(-world);
            top->SIM_z_world_v2 = float2fix(0);     
            //
            top->SIM_x_world_v3 = float2fix(1.66*world+world_offset);
            top->SIM_y_world_v3 = float2fix(world);
            top->SIM_z_world_v3 = float2fix(0);
            
            // edge cross product, normalize, Q8.8
            Vec3f32 e1_32 = (Vec3f32){top->SIM_x_world_v1 - top->SIM_x_world_v0,
                                        top->SIM_y_world_v1 - top->SIM_y_world_v0,
                                        top->SIM_z_world_v1 - top->SIM_z_world_v0};
            e1_32 = normalize32(e1_32);
            Vec3f32 e2_32 = (Vec3f32){top->SIM_x_world_v2 - top->SIM_x_world_v1,
                                        top->SIM_y_world_v2 - top->SIM_y_world_v1,
                                        top->SIM_z_world_v2 - top->SIM_z_world_v1};
            e2_32 = normalize32(e2_32);
            Vec3f32 n_32 = normalize32(cross32(e1_32,e2_32));
            top->SIM_nx = fix322fix(n_32.x);
            top->SIM_ny = fix322fix(n_32.y);
            top->SIM_nz = fix322fix(n_32.z);
            // compute light dir, = eye dir, Q8.8
            Vec3f32 viewDir32 = (Vec3f32){eye.x-center.x,eye.y-center.y,eye.z-center.z};
            Vec3f32 v32 = normalize32(viewDir32); 
            top->SIM_light_x = fix322fix(v32.x);
            top->SIM_light_y = fix322fix(v32.y);
            top->SIM_light_z = fix322fix(v32.z);
            //
            top->SIM_vp_00 = VP.row0.x;
            top->SIM_vp_01 = VP.row0.y;
            top->SIM_vp_02 = VP.row0.z;
            top->SIM_vp_03 = VP.row0.w;
            top->SIM_vp_10 = VP.row1.x;
            top->SIM_vp_11 = VP.row1.y;
            top->SIM_vp_12 = VP.row1.z;
            top->SIM_vp_13 = VP.row1.w;
            top->SIM_vp_30 = VP.row3.x;
            top->SIM_vp_31 = VP.row3.y;
            top->SIM_vp_32 = VP.row3.z;
            top->SIM_vp_33 = VP.row3.w;
            //
            top->SIM_render_mode = render_mode + tex_mode + color1_mode + color2_mode;

            //short dot_result = top->SIM_dot_result;
            //printf("dot result: %f\n", dot_result/256.0f);


            top->clk = 1;
            top->eval();
            top->clk = 0;
            top->eval();

            top->SIM_pc_data_ready = 0;     





            SDL_UpdateTexture(sdl_texture, NULL, screenbuffer, H_RES*sizeof(Pixel));
            SDL_RenderClear(sdl_renderer);
            SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, NULL);
            SDL_RenderPresent(sdl_renderer);
            frame_count++;

            uint64_t end_ticks = SDL_GetPerformanceCounter();
            double duration = ((double)(end_ticks-start_ticks))/SDL_GetPerformanceFrequency();
            double fps = (double)frame_count/duration;
            printf("Frames per second: %.1f\n", fps);
        }
    }
    

    top->final();  // simulation done

    SDL_DestroyTexture(sdl_texture);
    SDL_DestroyRenderer(sdl_renderer);
    SDL_DestroyWindow(sdl_window);
    SDL_Quit();
    return 0;
}