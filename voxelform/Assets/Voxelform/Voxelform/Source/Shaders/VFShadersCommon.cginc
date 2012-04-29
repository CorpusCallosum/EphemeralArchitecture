/*  Author: Mark Davis
 *  
 *  Some of the following code is based on a public sample provided by Ken Perlin.
 *  Source: http://mrl.nyu.edu/~perlin/noise/
 *
 *  The code has been heavily tweaked for gaming performance.  Note the lack of texture lookup tables.
 *  I found that they could be replaced with in-code noise generation with reasonably decent results.
 *  Unaltered Improved Perlin Noise probably does look a little nicer, but it's expensive.
 *  
 */

#ifndef __VOXELFORM_SHADERS_COMMON__
#define __VOXELFORM_SHADERS_COMMON__

// Don't forget to create properties for these values.
float _NoiseScale;
float _NoiseVal1;
float _NoiseVal2;

// Modified to remove texture lookups.
float perm(float t)
{
	// Noise generation without the use of a lookup texture.
	// Nothing sacred here... just a result of playing around a bit... but it works well.
	float p = frac(_NoiseVal1 / t) - frac(_NoiseVal2 * t);
	return p;
}

float3 fade(float3 t)
{
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// Modified to remove texture lookups.
float grad(float x, float3 p)
{
	// Another texture lookup replacement.  This started off a bit different, and quite logical.
	// The floating point numbers below were being used as 16 element arrays.
	// But this worked just as well and it's cheaper... so here we are.
	// I tried replacing these numbers, since at this point they're just magic...
	// but it turned out that they worked better than other values that I tried... so again, here we are.
	float3 gv = (x / float3(.2020202011112101, .2200111120202020, .1111220022001210));
	return (dot(gv, p));
}

// Returns a heavily tweaked implementation of Improved Perlin Noise, if it can still be called that.
float inoise(float3 p)
{
	float X = floor(p.x);
	float Y = floor(p.y);
	float Z = floor(p.z);
									
	p -= floor(p);
	
	float3 f = fade(p);
	
	// Hash coordinates for 6 of the 8 cube corners.

	float A = 	perm(X)	+ Y;
	float AA = 	perm(A)	+ Z;
	float AB = 	perm(A + 1.0) + Z;
	float B = 	perm(X + 1.0) + Y;
	float BA = 	perm(B) + Z;
	float BB = 	perm(B + 1.0) + Z;
	
	float ret = lerp(
		    lerp(lerp(grad(perm(AA), 	p),
		              grad(perm(BA), 	p + float3(-1.0,	 0.0,	 0.0)), f.x),
		         lerp(grad(perm(AB), 	p + float3( 0.0,	-1.0,	 0.0)),
		              grad(perm(BB), 	p + float3(-1.0,	-1.0,	 0.0)), f.x), f.y),
		    lerp(lerp(grad(perm(AA + 1.0),p + float3( 0.0,	 0.0,	-1.0)),
		              grad(perm(BA + 1.0),p + float3(-1.0,	 0.0,	-1.0)), f.x),
		         lerp(grad(perm(AB + 1.0),p + float3( 0.0,	-1.0,	-1.0)),
		              grad(perm(BB + 1.0),p + float3(-1.0,	-1.0,	-1.0)), f.x), f.y),
		    f.z);
	
	return ret;
}

// Returns decent 3D fractal noise.  It looks better with one more sample,
// but with a limit of 512 instructions, it's not possible in most of the shaders...
// at least in a single pass.  In case you're wondering... to get a decent fractal
// look to the noise, the second sample is absolutely required.
float fractalNoise(float3 p)
{
	p += float3(1023.0, 1230.0, 2300.0);
	
	// 1st sample
	float noise = inoise(p);
	
	p /= 16.0;
	
	// 2nd sample
	noise += 16.0 * inoise(p);
	
	noise += 17.0;
	noise /= 34.0;

	return clamp(noise, 0.0, 1.0);
}

#endif