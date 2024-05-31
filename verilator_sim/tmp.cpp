

EACH FRAME (vs)
	// @ endframe if ((y == 480) && (x == 1))
	//1. ei_init, mul x6
	done

	//2. denom, mul x2 + div x1
	done

	//3. bar_iy, bar_iz  (no need for bar_ix, uv[0] (0,0))
	// Q2.14 = Q20.0 * Q2.14 
	// fix bar_ix = ((P.y-pts[2].y)*(-x3x2) + (y2y3)*(pts[2].x - P.x)) * denom;
	// 10 mul

init
	//bar_iy = pts[0].y * x1x3 + (-y1y3)*pts[0].x
	bar_iy = pts[0].y * x1x3 + (-y1y3)*pts[0].x
	bar_iy_dy = -x1x3
	bar_iy_dx = y1y3

each y
    //bar_iy = (P.y-pts[0].y)*(-x1x3);   //original
    //
    y_bar_iy = bar_iy	// y=0
    y_bar_iy += -x1x3	// y=1
    y_bar_iy += -x1x3	// y=2
    //
    bar_iy <= bar_iy + bar_iy_dy;

each x
	bar_i.y = bar_iy;    	 		// y=0
	bar_i.y = bar_iy + bar_iy_dx;  // y=1
    bar_i.y = bar_iy + 2*bar_iy_dx;  // y=2
    bar_i.y = bar_iy + 3*bar_iy_dx;  // y=3
    
    //
    b_iy <= bar_iy;
    b_iy += bar_iy_dx 
    b_iy += bar_iy_dx 

	
	done

EACH LINE (vs)(+1y)
	// @ endline, if (y < 480) && (x == 640) begin
	//1. ei_init +=
	done

	//2. 
	//bar_iy <= bar_iy + bar_iy_dy;
	//bar_iz <= bar_iz + bar_iz_dy;
	done

EACH PIXEL (+1x)
	
	// tri1: uv (0,0) (0,1) (1,1)
	bar_iy <= bar_iy + bar_iy_dx;
	bar_iz <= bar_iz + bar_iz_dx;

	fix14 ui <= (bar_iz + bar_iz_dx); 
	fix14 vi <= (bar_iy + bar_iy_dx + bar_iz + bar_iz_dx); 


	// tri2: uv (0,0) (1,1) (1,0)
	bar_iy <= bar_iy + bar_iy_dx;
	bar_iz <= bar_iz + bar_iz_dx;

	fix14 ui <= (bar_iy + bar_iy_dx + bar_iz + bar_iz_dx); 
	fix14 vi <= (bar_iy + bar_iy_dx); 





	// clk2: Q2.14 [0.0.9999] x 128 -> Q9.7
	[10:0] addr = {vi[13:7],ui[13:10]};
	texel = mem[addr][ui&7];
	rgb <= texel;
	
	
// fix14 ubar14 = multfix14(uv[0].x,bar14.x)+multfix14(uv[1].x,bar14.y)+multfix14(uv[2].x,bar14.z);
// fix14 vbar14 = multfix14(uv[0].y,bar14.x)+multfix14(uv[1].y,bar14.y)+multfix14(uv[2].y,bar14.z);

// fix14 ubar14 = bar14.y + bar14.z;
// fix14 vbar14 = bar14.y;
             
// uv (0,0) (0,1) (1,1)
// fix14 ubar14 = bar14.z;
// fix14 vbar14 = bar14.y + bar14.z;

//short ui = ubar14 >> 6;
//short vi = 255-(vbar14 >> 6);

			 


			 
			 
		