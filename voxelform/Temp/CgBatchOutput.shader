/*  Author: Mark Davis
 *  
 *  This shader provides psuedo-volumetric texturing, using a 2D texture as a source.
 *  Please experiment with different source textures.  The 3D texturing will look different
 *  than the 2D source, but some elements will still be seen.  Results will vary due to
 *  the number of cycles and unique features of the 2D source.
 *
 *  Note: Fixed mip-mapping "black mirage" issue in v1.1
 *  
 *  I highly recommend experimenting with some of the textures from this site:
 *  http://www.filterforge.com/filters/category46-page1.html
 */

Shader "Voxelform/Solid Textured/Diffuse" {

    Properties {
    
      _PlasmaTex ("Plasma", 2D) = "white" {}
      _Color ("Main Color", Color) = (1, .8, .1, 1)
      _Tilt ("Tilt", Float) = .15
      _BandsShift ("Bands Shift", Float) = 1.614
      _BandsIntensity ("Bands Intensity", Float) = .75
      
    }

    SubShader {
		
		Tags { "RenderType" = "Opaque" }
		
			
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
Program "vp" {
// Vertex combos: 8
//   opengl - ALU: 11 to 68
//   d3d9 - ALU: 11 to 68
SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [unity_Scale]
Matrix 5 [_Object2World]
Vector 10 [unity_SHAr]
Vector 11 [unity_SHAg]
Vector 12 [unity_SHAb]
Vector 13 [unity_SHBr]
Vector 14 [unity_SHBg]
Vector 15 [unity_SHBb]
Vector 16 [unity_SHC]
"3.0-!!ARBvp1.0
# 32 ALU
PARAM c[17] = { { 1 },
		state.matrix.mvp,
		program.local[5..16] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, vertex.normal, c[9].w;
DP3 R3.w, R1, c[6];
DP3 R2.w, R1, c[7];
DP3 R0.x, R1, c[5];
MOV R0.y, R3.w;
MOV R0.z, R2.w;
MUL R1, R0.xyzz, R0.yzzx;
MOV R0.w, c[0].x;
DP4 R2.z, R0, c[12];
DP4 R2.y, R0, c[11];
DP4 R2.x, R0, c[10];
MUL R0.y, R3.w, R3.w;
DP4 R3.z, R1, c[15];
DP4 R3.y, R1, c[14];
DP4 R3.x, R1, c[13];
MAD R0.y, R0.x, R0.x, -R0;
MUL R1.xyz, R0.y, c[16];
ADD R2.xyz, R2, R3;
ADD result.texcoord[3].xyz, R2, R1;
MOV result.texcoord[2].z, R2.w;
MOV result.texcoord[2].y, R3.w;
MOV result.texcoord[2].x, R0;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 32 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [unity_Scale]
Matrix 4 [_Object2World]
Vector 9 [unity_SHAr]
Vector 10 [unity_SHAg]
Vector 11 [unity_SHAb]
Vector 12 [unity_SHBr]
Vector 13 [unity_SHBg]
Vector 14 [unity_SHBb]
Vector 15 [unity_SHC]
"vs_3_0
; 32 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c16, 1.00000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
mul r1.xyz, v1, c8.w
dp3 r3.w, r1, c5
dp3 r2.w, r1, c6
dp3 r0.x, r1, c4
mov r0.y, r3.w
mov r0.z, r2.w
mul r1, r0.xyzz, r0.yzzx
mov r0.w, c16.x
dp4 r2.z, r0, c11
dp4 r2.y, r0, c10
dp4 r2.x, r0, c9
mul r0.y, r3.w, r3.w
dp4 r3.z, r1, c14
dp4 r3.y, r1, c13
dp4 r3.x, r1, c12
mad r0.y, r0.x, r0.x, -r0
mul r1.xyz, r0.y, c15
add r2.xyz, r2, r3
add o4.xyz, r2, r1
mov o3.z, r2.w
mov o3.y, r3.w
mov o3.x, r0
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = tmpvar_8;
  mediump vec3 tmpvar_10;
  mediump vec4 normal;
  normal = tmpvar_9;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAr, normal);
  x1.x = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAg, normal);
  x1.y = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAb, normal);
  x1.z = tmpvar_13;
  mediump vec4 tmpvar_14;
  tmpvar_14 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBr, tmpvar_14);
  x2.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBg, tmpvar_14);
  x2.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBb, tmpvar_14);
  x2.z = tmpvar_17;
  mediump float tmpvar_18;
  tmpvar_18 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_18;
  highp vec3 tmpvar_19;
  tmpvar_19 = (unity_SHC.xyz * vC);
  x3 = tmpvar_19;
  tmpvar_10 = ((x1 + x2) + x3);
  shlight = tmpvar_10;
  tmpvar_4 = shlight;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * (max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = tmpvar_8;
  mediump vec3 tmpvar_10;
  mediump vec4 normal;
  normal = tmpvar_9;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAr, normal);
  x1.x = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAg, normal);
  x1.y = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAb, normal);
  x1.z = tmpvar_13;
  mediump vec4 tmpvar_14;
  tmpvar_14 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBr, tmpvar_14);
  x2.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBg, tmpvar_14);
  x2.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBb, tmpvar_14);
  x2.z = tmpvar_17;
  mediump float tmpvar_18;
  tmpvar_18 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_18;
  highp vec3 tmpvar_19;
  tmpvar_19 = (unity_SHC.xyz * vC);
  x3 = tmpvar_19;
  tmpvar_10 = ((x1 + x2) + x3);
  shlight = tmpvar_10;
  tmpvar_4 = shlight;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * (max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 5 [_Object2World]
Vector 9 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 11 ALU
PARAM c[10] = { program.local[0],
		state.matrix.mvp,
		program.local[5..9] };
MAD result.texcoord[2].xy, vertex.texcoord[1], c[9], c[9].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 11 instructions, 0 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [_Object2World]
Vector 8 [unity_LightmapST]
"vs_3_0
; 11 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
mad o3.xy, v2, c8, c8.zwzw
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_3;
  tmpvar_3 = (tmpvar_2 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  c = vec4(0.0, 0.0, 0.0, 0.0);
  c.xyz = (tmpvar_2 * (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD2).xyz));
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_3;
  tmpvar_3 = (tmpvar_2 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  c = vec4(0.0, 0.0, 0.0, 0.0);
  lowp vec4 tmpvar_49;
  tmpvar_49 = texture2D (unity_Lightmap, xlv_TEXCOORD2);
  c.xyz = (tmpvar_2 * ((8.0 * tmpvar_49.w) * tmpvar_49.xyz));
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 5 [_Object2World]
Vector 9 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 11 ALU
PARAM c[10] = { program.local[0],
		state.matrix.mvp,
		program.local[5..9] };
MAD result.texcoord[2].xy, vertex.texcoord[1], c[9], c[9].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 11 instructions, 0 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [_Object2World]
Vector 8 [unity_LightmapST]
"vs_3_0
; 11 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
mad o3.xy, v2, c8, c8.zwzw
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_3;
  tmpvar_3 = (tmpvar_2 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  c = vec4(0.0, 0.0, 0.0, 0.0);
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_49;
  tmpvar_49 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD2).xyz);
  lm_i0 = tmpvar_49;
  mediump vec3 tmpvar_50;
  tmpvar_50 = (tmpvar_2 * lm_i0);
  c.xyz = tmpvar_50;
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_3;
  tmpvar_3 = (tmpvar_2 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  c = vec4(0.0, 0.0, 0.0, 0.0);
  lowp vec4 tmpvar_49;
  tmpvar_49 = texture2D (unity_Lightmap, xlv_TEXCOORD2);
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_50;
  tmpvar_50 = ((8.0 * tmpvar_49.w) * tmpvar_49.xyz);
  lm_i0 = tmpvar_50;
  mediump vec3 tmpvar_51;
  tmpvar_51 = (tmpvar_2 * lm_i0);
  c.xyz = tmpvar_51;
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [_ProjectionParams]
Vector 10 [unity_Scale]
Matrix 5 [_Object2World]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
"3.0-!!ARBvp1.0
# 37 ALU
PARAM c[18] = { { 1, 0.5 },
		state.matrix.mvp,
		program.local[5..17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R0.xyz, vertex.normal, c[10].w;
DP3 R3.w, R0, c[6];
DP3 R2.w, R0, c[7];
DP3 R1.w, R0, c[5];
MOV R1.x, R3.w;
MOV R1.y, R2.w;
MOV R1.z, c[0].x;
MUL R0, R1.wxyy, R1.xyyw;
DP4 R2.z, R1.wxyz, c[13];
DP4 R2.y, R1.wxyz, c[12];
DP4 R2.x, R1.wxyz, c[11];
DP4 R1.z, R0, c[16];
DP4 R1.y, R0, c[15];
DP4 R1.x, R0, c[14];
MUL R3.x, R3.w, R3.w;
MAD R0.x, R1.w, R1.w, -R3;
ADD R3.xyz, R2, R1;
MUL R2.xyz, R0.x, c[17];
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R1.xyz, R0.xyww, c[0].y;
MUL R1.y, R1, c[9].x;
ADD result.texcoord[3].xyz, R3, R2;
ADD result.texcoord[4].xy, R1, R1.z;
MOV result.position, R0;
MOV result.texcoord[4].zw, R0;
MOV result.texcoord[2].z, R2.w;
MOV result.texcoord[2].y, R3.w;
MOV result.texcoord[2].x, R1.w;
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 37 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Vector 10 [unity_Scale]
Matrix 4 [_Object2World]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
"vs_3_0
; 37 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c18, 1.00000000, 0.50000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
mul r0.xyz, v1, c10.w
dp3 r3.w, r0, c5
dp3 r2.w, r0, c6
dp3 r1.w, r0, c4
mov r1.x, r3.w
mov r1.y, r2.w
mov r1.z, c18.x
mul r0, r1.wxyy, r1.xyyw
dp4 r2.z, r1.wxyz, c13
dp4 r2.y, r1.wxyz, c12
dp4 r2.x, r1.wxyz, c11
dp4 r1.z, r0, c16
dp4 r1.y, r0, c15
dp4 r1.x, r0, c14
mul r3.x, r3.w, r3.w
mad r0.x, r1.w, r1.w, -r3
add r3.xyz, r2, r1
mul r2.xyz, r0.x, c17
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r1.xyz, r0.xyww, c18.y
mul r1.y, r1, c8.x
add o4.xyz, r3, r2
mad o5.xy, r1.z, c9.zwzw, r1
mov o0, r0
mov o5.zw, r0
mov o3.z, r2.w
mov o3.y, r3.w
mov o3.x, r1.w
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * tmpvar_1);
  tmpvar_2 = tmpvar_7;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_9;
  tmpvar_9 = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_9;
  highp vec4 tmpvar_10;
  tmpvar_10.w = 1.0;
  tmpvar_10.xyz = tmpvar_9;
  mediump vec3 tmpvar_11;
  mediump vec4 normal;
  normal = tmpvar_10;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAr, normal);
  x1.x = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAg, normal);
  x1.y = tmpvar_13;
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHAb, normal);
  x1.z = tmpvar_14;
  mediump vec4 tmpvar_15;
  tmpvar_15 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBr, tmpvar_15);
  x2.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBg, tmpvar_15);
  x2.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHBb, tmpvar_15);
  x2.z = tmpvar_18;
  mediump float tmpvar_19;
  tmpvar_19 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_19;
  highp vec3 tmpvar_20;
  tmpvar_20 = (unity_SHC.xyz * vC);
  x3 = tmpvar_20;
  tmpvar_11 = ((x1 + x2) + x3);
  shlight = tmpvar_11;
  tmpvar_4 = shlight;
  highp vec4 o_i0;
  highp vec4 tmpvar_21;
  tmpvar_21 = (tmpvar_5 * 0.5);
  o_i0 = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = tmpvar_21.x;
  tmpvar_22.y = (tmpvar_21.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_22 + tmpvar_21.w);
  o_i0.zw = tmpvar_5.zw;
  gl_Position = tmpvar_5;
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * texture2DProj (_ShadowMapTexture, xlv_TEXCOORD4).x) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * tmpvar_1);
  tmpvar_2 = tmpvar_7;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_9;
  tmpvar_9 = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_9;
  highp vec4 tmpvar_10;
  tmpvar_10.w = 1.0;
  tmpvar_10.xyz = tmpvar_9;
  mediump vec3 tmpvar_11;
  mediump vec4 normal;
  normal = tmpvar_10;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAr, normal);
  x1.x = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAg, normal);
  x1.y = tmpvar_13;
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHAb, normal);
  x1.z = tmpvar_14;
  mediump vec4 tmpvar_15;
  tmpvar_15 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBr, tmpvar_15);
  x2.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBg, tmpvar_15);
  x2.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHBb, tmpvar_15);
  x2.z = tmpvar_18;
  mediump float tmpvar_19;
  tmpvar_19 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_19;
  highp vec3 tmpvar_20;
  tmpvar_20 = (unity_SHC.xyz * vC);
  x3 = tmpvar_20;
  tmpvar_11 = ((x1 + x2) + x3);
  shlight = tmpvar_11;
  tmpvar_4 = shlight;
  highp vec4 o_i0;
  highp vec4 tmpvar_21;
  tmpvar_21 = (tmpvar_5 * 0.5);
  o_i0 = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = tmpvar_21.x;
  tmpvar_22.y = (tmpvar_21.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_22 + tmpvar_21.w);
  o_i0.zw = tmpvar_5.zw;
  gl_Position = tmpvar_5;
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * texture2DProj (_ShadowMapTexture, xlv_TEXCOORD4).x) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Vector 9 [_ProjectionParams]
Matrix 5 [_Object2World]
Vector 10 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 16 ALU
PARAM c[11] = { { 0.5 },
		state.matrix.mvp,
		program.local[5..10] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R1.xyz, R0.xyww, c[0].x;
MUL R1.y, R1, c[9].x;
ADD result.texcoord[3].xy, R1, R1.z;
MOV result.position, R0;
MOV result.texcoord[3].zw, R0;
MAD result.texcoord[2].xy, vertex.texcoord[1], c[10], c[10].zwzw;
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 16 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Matrix 4 [_Object2World]
Vector 10 [unity_LightmapST]
"vs_3_0
; 16 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c11, 0.50000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r1.xyz, r0.xyww, c11.x
mul r1.y, r1, c8.x
mad o4.xy, r1.z, c9.zwzw, r1
mov o0, r0
mov o4.zw, r0
mad o3.xy, v2, c10, c10.zwzw
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD3 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  c = vec4(0.0, 0.0, 0.0, 0.0);
  c.xyz = (tmpvar_2 * min ((2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD2).xyz), vec3((texture2DProj (_ShadowMapTexture, xlv_TEXCOORD3).x * 2.0))));
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD3 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 tmpvar_49;
  tmpvar_49 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD3);
  c = vec4(0.0, 0.0, 0.0, 0.0);
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2D (unity_Lightmap, xlv_TEXCOORD2);
  lowp vec3 tmpvar_51;
  tmpvar_51 = ((8.0 * tmpvar_50.w) * tmpvar_50.xyz);
  c.xyz = (tmpvar_2 * max (min (tmpvar_51, ((tmpvar_49.x * 2.0) * tmpvar_50.xyz)), (tmpvar_51 * tmpvar_49.x)));
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Vector 9 [_ProjectionParams]
Matrix 5 [_Object2World]
Vector 10 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 16 ALU
PARAM c[11] = { { 0.5 },
		state.matrix.mvp,
		program.local[5..10] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R1.xyz, R0.xyww, c[0].x;
MUL R1.y, R1, c[9].x;
ADD result.texcoord[3].xy, R1, R1.z;
MOV result.position, R0;
MOV result.texcoord[3].zw, R0;
MAD result.texcoord[2].xy, vertex.texcoord[1], c[10], c[10].zwzw;
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 16 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Matrix 4 [_Object2World]
Vector 10 [unity_LightmapST]
"vs_3_0
; 16 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c11, 0.50000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r1.xyz, r0.xyww, c11.x
mul r1.y, r1, c8.x
mad o4.xy, r1.z, c9.zwzw, r1
mov o0, r0
mov o4.zw, r0
mad o3.xy, v2, c10, c10.zwzw
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD3 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  c = vec4(0.0, 0.0, 0.0, 0.0);
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_49;
  tmpvar_49 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD2).xyz);
  lm_i0 = tmpvar_49;
  mediump vec4 tmpvar_50;
  tmpvar_50.w = 0.0;
  tmpvar_50.xyz = lm_i0;
  lowp vec3 tmpvar_51;
  tmpvar_51 = vec3((texture2DProj (_ShadowMapTexture, xlv_TEXCOORD3).x * 2.0));
  mediump vec3 tmpvar_52;
  tmpvar_52 = (tmpvar_2 * min (tmpvar_50.xyz, tmpvar_51));
  c.xyz = tmpvar_52;
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD3 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD3;
varying highp vec2 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 tmpvar_49;
  tmpvar_49 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD3);
  c = vec4(0.0, 0.0, 0.0, 0.0);
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2D (unity_Lightmap, xlv_TEXCOORD2);
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_51;
  tmpvar_51 = ((8.0 * tmpvar_50.w) * tmpvar_50.xyz);
  lm_i0 = tmpvar_51;
  mediump vec4 tmpvar_52;
  tmpvar_52.w = 0.0;
  tmpvar_52.xyz = lm_i0;
  mediump vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_2 * max (min (tmpvar_52.xyz, ((tmpvar_49.x * 2.0) * tmpvar_50.xyz)), (lm_i0 * tmpvar_49.x)));
  c.xyz = tmpvar_53;
  c.w = 1.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [unity_Scale]
Matrix 5 [_Object2World]
Vector 10 [unity_4LightPosX0]
Vector 11 [unity_4LightPosY0]
Vector 12 [unity_4LightPosZ0]
Vector 13 [unity_4LightAtten0]
Vector 14 [unity_LightColor0]
Vector 15 [unity_LightColor1]
Vector 16 [unity_LightColor2]
Vector 17 [unity_LightColor3]
Vector 18 [unity_SHAr]
Vector 19 [unity_SHAg]
Vector 20 [unity_SHAb]
Vector 21 [unity_SHBr]
Vector 22 [unity_SHBg]
Vector 23 [unity_SHBb]
Vector 24 [unity_SHC]
"3.0-!!ARBvp1.0
# 62 ALU
PARAM c[25] = { { 1, 0 },
		state.matrix.mvp,
		program.local[5..24] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
MUL R3.xyz, vertex.normal, c[9].w;
DP3 R5.x, R3, c[5];
DP4 R4.zw, vertex.position, c[6];
ADD R2, -R4.z, c[11];
DP3 R4.z, R3, c[6];
DP3 R3.z, R3, c[7];
DP4 R3.w, vertex.position, c[5];
MUL R0, R4.z, R2;
ADD R1, -R3.w, c[10];
DP4 R4.xy, vertex.position, c[7];
MUL R2, R2, R2;
MOV R5.y, R4.z;
MOV R5.z, R3;
MOV R5.w, c[0].x;
MAD R0, R5.x, R1, R0;
MAD R2, R1, R1, R2;
ADD R1, -R4.x, c[12];
MAD R2, R1, R1, R2;
MAD R0, R3.z, R1, R0;
MUL R1, R2, c[13];
ADD R1, R1, c[0].x;
RSQ R2.x, R2.x;
RSQ R2.y, R2.y;
RSQ R2.z, R2.z;
RSQ R2.w, R2.w;
MUL R0, R0, R2;
DP4 R2.z, R5, c[20];
DP4 R2.y, R5, c[19];
DP4 R2.x, R5, c[18];
RCP R1.x, R1.x;
RCP R1.y, R1.y;
RCP R1.w, R1.w;
RCP R1.z, R1.z;
MAX R0, R0, c[0].y;
MUL R0, R0, R1;
MUL R1.xyz, R0.y, c[15];
MAD R1.xyz, R0.x, c[14], R1;
MAD R0.xyz, R0.z, c[16], R1;
MAD R1.xyz, R0.w, c[17], R0;
MUL R0, R5.xyzz, R5.yzzx;
MUL R1.w, R4.z, R4.z;
DP4 R5.w, R0, c[23];
DP4 R5.z, R0, c[22];
DP4 R5.y, R0, c[21];
MAD R1.w, R5.x, R5.x, -R1;
MUL R0.xyz, R1.w, c[24];
ADD R2.xyz, R2, R5.yzww;
ADD R0.xyz, R2, R0;
MOV R3.x, R4.w;
MOV R3.y, R4;
ADD result.texcoord[3].xyz, R0, R1;
MOV result.texcoord[1].xyz, R3.wxyw;
MOV result.texcoord[2].z, R3;
MOV result.texcoord[2].y, R4.z;
MOV result.texcoord[2].x, R5;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
END
# 62 instructions, 6 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [unity_Scale]
Matrix 4 [_Object2World]
Vector 9 [unity_4LightPosX0]
Vector 10 [unity_4LightPosY0]
Vector 11 [unity_4LightPosZ0]
Vector 12 [unity_4LightAtten0]
Vector 13 [unity_LightColor0]
Vector 14 [unity_LightColor1]
Vector 15 [unity_LightColor2]
Vector 16 [unity_LightColor3]
Vector 17 [unity_SHAr]
Vector 18 [unity_SHAg]
Vector 19 [unity_SHAb]
Vector 20 [unity_SHBr]
Vector 21 [unity_SHBg]
Vector 22 [unity_SHBb]
Vector 23 [unity_SHC]
"vs_3_0
; 62 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c24, 1.00000000, 0.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
mul r3.xyz, v1, c8.w
dp3 r5.x, r3, c4
dp4 r4.zw, v0, c5
add r2, -r4.z, c10
dp3 r4.z, r3, c5
dp3 r3.z, r3, c6
dp4 r3.w, v0, c4
mul r0, r4.z, r2
add r1, -r3.w, c9
dp4 r4.xy, v0, c6
mul r2, r2, r2
mov r5.y, r4.z
mov r5.z, r3
mov r5.w, c24.x
mad r0, r5.x, r1, r0
mad r2, r1, r1, r2
add r1, -r4.x, c11
mad r2, r1, r1, r2
mad r0, r3.z, r1, r0
mul r1, r2, c12
add r1, r1, c24.x
rsq r2.x, r2.x
rsq r2.y, r2.y
rsq r2.z, r2.z
rsq r2.w, r2.w
mul r0, r0, r2
dp4 r2.z, r5, c19
dp4 r2.y, r5, c18
dp4 r2.x, r5, c17
rcp r1.x, r1.x
rcp r1.y, r1.y
rcp r1.w, r1.w
rcp r1.z, r1.z
max r0, r0, c24.y
mul r0, r0, r1
mul r1.xyz, r0.y, c14
mad r1.xyz, r0.x, c13, r1
mad r0.xyz, r0.z, c15, r1
mad r1.xyz, r0.w, c16, r0
mul r0, r5.xyzz, r5.yzzx
mul r1.w, r4.z, r4.z
dp4 r5.w, r0, c22
dp4 r5.z, r0, c21
dp4 r5.y, r0, c20
mad r1.w, r5.x, r5.x, -r1
mul r0.xyz, r1.w, c23
add r2.xyz, r2, r5.yzww
add r0.xyz, r2, r0
mov r3.x, r4.w
mov r3.y, r4
add o4.xyz, r0, r1
mov o2.xyz, r3.wxyw
mov o3.z, r3
mov o3.y, r4.z
mov o3.x, r5
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightAtten0;

uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = tmpvar_8;
  mediump vec3 tmpvar_10;
  mediump vec4 normal;
  normal = tmpvar_9;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAr, normal);
  x1.x = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAg, normal);
  x1.y = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAb, normal);
  x1.z = tmpvar_13;
  mediump vec4 tmpvar_14;
  tmpvar_14 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBr, tmpvar_14);
  x2.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBg, tmpvar_14);
  x2.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBb, tmpvar_14);
  x2.z = tmpvar_17;
  mediump float tmpvar_18;
  tmpvar_18 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_18;
  highp vec3 tmpvar_19;
  tmpvar_19 = (unity_SHC.xyz * vC);
  x3 = tmpvar_19;
  tmpvar_10 = ((x1 + x2) + x3);
  shlight = tmpvar_10;
  tmpvar_4 = shlight;
  highp vec3 tmpvar_20;
  tmpvar_20 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_21;
  tmpvar_21 = (unity_4LightPosX0 - tmpvar_20.x);
  highp vec4 tmpvar_22;
  tmpvar_22 = (unity_4LightPosY0 - tmpvar_20.y);
  highp vec4 tmpvar_23;
  tmpvar_23 = (unity_4LightPosZ0 - tmpvar_20.z);
  highp vec4 tmpvar_24;
  tmpvar_24 = (((tmpvar_21 * tmpvar_21) + (tmpvar_22 * tmpvar_22)) + (tmpvar_23 * tmpvar_23));
  highp vec4 tmpvar_25;
  tmpvar_25 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_21 * tmpvar_8.x) + (tmpvar_22 * tmpvar_8.y)) + (tmpvar_23 * tmpvar_8.z)) * inversesqrt (tmpvar_24))) * (1.0/((1.0 + (tmpvar_24 * unity_4LightAtten0)))));
  highp vec3 tmpvar_26;
  tmpvar_26 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_25.x) + (unity_LightColor[1].xyz * tmpvar_25.y)) + (unity_LightColor[2].xyz * tmpvar_25.z)) + (unity_LightColor[3].xyz * tmpvar_25.w)));
  tmpvar_4 = tmpvar_26;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * (max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightAtten0;

uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec4 tmpvar_9;
  tmpvar_9.w = 1.0;
  tmpvar_9.xyz = tmpvar_8;
  mediump vec3 tmpvar_10;
  mediump vec4 normal;
  normal = tmpvar_9;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAr, normal);
  x1.x = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAg, normal);
  x1.y = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAb, normal);
  x1.z = tmpvar_13;
  mediump vec4 tmpvar_14;
  tmpvar_14 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBr, tmpvar_14);
  x2.x = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBg, tmpvar_14);
  x2.y = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBb, tmpvar_14);
  x2.z = tmpvar_17;
  mediump float tmpvar_18;
  tmpvar_18 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_18;
  highp vec3 tmpvar_19;
  tmpvar_19 = (unity_SHC.xyz * vC);
  x3 = tmpvar_19;
  tmpvar_10 = ((x1 + x2) + x3);
  shlight = tmpvar_10;
  tmpvar_4 = shlight;
  highp vec3 tmpvar_20;
  tmpvar_20 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_21;
  tmpvar_21 = (unity_4LightPosX0 - tmpvar_20.x);
  highp vec4 tmpvar_22;
  tmpvar_22 = (unity_4LightPosY0 - tmpvar_20.y);
  highp vec4 tmpvar_23;
  tmpvar_23 = (unity_4LightPosZ0 - tmpvar_20.z);
  highp vec4 tmpvar_24;
  tmpvar_24 = (((tmpvar_21 * tmpvar_21) + (tmpvar_22 * tmpvar_22)) + (tmpvar_23 * tmpvar_23));
  highp vec4 tmpvar_25;
  tmpvar_25 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_21 * tmpvar_8.x) + (tmpvar_22 * tmpvar_8.y)) + (tmpvar_23 * tmpvar_8.z)) * inversesqrt (tmpvar_24))) * (1.0/((1.0 + (tmpvar_24 * unity_4LightAtten0)))));
  highp vec3 tmpvar_26;
  tmpvar_26 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_25.x) + (unity_LightColor[1].xyz * tmpvar_25.y)) + (unity_LightColor[2].xyz * tmpvar_25.z)) + (unity_LightColor[3].xyz * tmpvar_25.w)));
  tmpvar_4 = tmpvar_26;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * (max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [_ProjectionParams]
Vector 10 [unity_Scale]
Matrix 5 [_Object2World]
Vector 11 [unity_4LightPosX0]
Vector 12 [unity_4LightPosY0]
Vector 13 [unity_4LightPosZ0]
Vector 14 [unity_4LightAtten0]
Vector 15 [unity_LightColor0]
Vector 16 [unity_LightColor1]
Vector 17 [unity_LightColor2]
Vector 18 [unity_LightColor3]
Vector 19 [unity_SHAr]
Vector 20 [unity_SHAg]
Vector 21 [unity_SHAb]
Vector 22 [unity_SHBr]
Vector 23 [unity_SHBg]
Vector 24 [unity_SHBb]
Vector 25 [unity_SHC]
"3.0-!!ARBvp1.0
# 68 ALU
PARAM c[26] = { { 1, 0, 0.5 },
		state.matrix.mvp,
		program.local[5..25] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
MUL R3.xyz, vertex.normal, c[10].w;
DP3 R5.x, R3, c[5];
DP4 R4.zw, vertex.position, c[6];
ADD R2, -R4.z, c[12];
DP3 R4.z, R3, c[6];
DP3 R3.z, R3, c[7];
DP4 R3.w, vertex.position, c[5];
MUL R0, R4.z, R2;
ADD R1, -R3.w, c[11];
DP4 R4.xy, vertex.position, c[7];
MUL R2, R2, R2;
MOV R5.y, R4.z;
MOV R5.z, R3;
MOV R5.w, c[0].x;
MAD R0, R5.x, R1, R0;
MAD R2, R1, R1, R2;
ADD R1, -R4.x, c[13];
MAD R2, R1, R1, R2;
MAD R0, R3.z, R1, R0;
MUL R1, R2, c[14];
ADD R1, R1, c[0].x;
RSQ R2.x, R2.x;
RSQ R2.y, R2.y;
RSQ R2.z, R2.z;
RSQ R2.w, R2.w;
MUL R0, R0, R2;
DP4 R2.z, R5, c[21];
DP4 R2.y, R5, c[20];
DP4 R2.x, R5, c[19];
RCP R1.x, R1.x;
RCP R1.y, R1.y;
RCP R1.w, R1.w;
RCP R1.z, R1.z;
MAX R0, R0, c[0].y;
MUL R0, R0, R1;
MUL R1.xyz, R0.y, c[16];
MAD R1.xyz, R0.x, c[15], R1;
MAD R0.xyz, R0.z, c[17], R1;
MAD R1.xyz, R0.w, c[18], R0;
MUL R0, R5.xyzz, R5.yzzx;
MUL R1.w, R4.z, R4.z;
DP4 R5.w, R0, c[24];
DP4 R5.z, R0, c[23];
DP4 R5.y, R0, c[22];
MAD R1.w, R5.x, R5.x, -R1;
MUL R0.xyz, R1.w, c[25];
ADD R2.xyz, R2, R5.yzww;
ADD R5.yzw, R2.xxyz, R0.xxyz;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R2.xyz, R0.xyww, c[0].z;
ADD result.texcoord[3].xyz, R5.yzww, R1;
MOV R1.x, R2;
MUL R1.y, R2, c[9].x;
MOV R3.x, R4.w;
MOV R3.y, R4;
ADD result.texcoord[4].xy, R1, R2.z;
MOV result.position, R0;
MOV result.texcoord[4].zw, R0;
MOV result.texcoord[1].xyz, R3.wxyw;
MOV result.texcoord[2].z, R3;
MOV result.texcoord[2].y, R4.z;
MOV result.texcoord[2].x, R5;
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
END
# 68 instructions, 6 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Vector 10 [unity_Scale]
Matrix 4 [_Object2World]
Vector 11 [unity_4LightPosX0]
Vector 12 [unity_4LightPosY0]
Vector 13 [unity_4LightPosZ0]
Vector 14 [unity_4LightAtten0]
Vector 15 [unity_LightColor0]
Vector 16 [unity_LightColor1]
Vector 17 [unity_LightColor2]
Vector 18 [unity_LightColor3]
Vector 19 [unity_SHAr]
Vector 20 [unity_SHAg]
Vector 21 [unity_SHAb]
Vector 22 [unity_SHBr]
Vector 23 [unity_SHBg]
Vector 24 [unity_SHBb]
Vector 25 [unity_SHC]
"vs_3_0
; 68 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c26, 1.00000000, 0.00000000, 0.50000000, 0
dcl_position0 v0
dcl_normal0 v1
mul r3.xyz, v1, c10.w
dp3 r5.x, r3, c4
dp4 r4.zw, v0, c5
add r2, -r4.z, c12
dp3 r4.z, r3, c5
dp3 r3.z, r3, c6
dp4 r3.w, v0, c4
mul r0, r4.z, r2
add r1, -r3.w, c11
dp4 r4.xy, v0, c6
mul r2, r2, r2
mov r5.y, r4.z
mov r5.z, r3
mov r5.w, c26.x
mad r0, r5.x, r1, r0
mad r2, r1, r1, r2
add r1, -r4.x, c13
mad r2, r1, r1, r2
mad r0, r3.z, r1, r0
mul r1, r2, c14
add r1, r1, c26.x
rsq r2.x, r2.x
rsq r2.y, r2.y
rsq r2.z, r2.z
rsq r2.w, r2.w
mul r0, r0, r2
dp4 r2.z, r5, c21
dp4 r2.y, r5, c20
dp4 r2.x, r5, c19
rcp r1.x, r1.x
rcp r1.y, r1.y
rcp r1.w, r1.w
rcp r1.z, r1.z
max r0, r0, c26.y
mul r0, r0, r1
mul r1.xyz, r0.y, c16
mad r1.xyz, r0.x, c15, r1
mad r0.xyz, r0.z, c17, r1
mad r1.xyz, r0.w, c18, r0
mul r0, r5.xyzz, r5.yzzx
mul r1.w, r4.z, r4.z
dp4 r5.w, r0, c24
dp4 r5.z, r0, c23
dp4 r5.y, r0, c22
mad r1.w, r5.x, r5.x, -r1
mul r0.xyz, r1.w, c25
add r2.xyz, r2, r5.yzww
add r5.yzw, r2.xxyz, r0.xxyz
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r2.xyz, r0.xyww, c26.z
add o4.xyz, r5.yzww, r1
mov r1.x, r2
mul r1.y, r2, c8.x
mov r3.x, r4.w
mov r3.y, r4
mad o5.xy, r2.z, c9.zwzw, r1
mov o0, r0
mov o5.zw, r0
mov o2.xyz, r3.wxyw
mov o3.z, r3
mov o3.y, r4.z
mov o3.x, r5
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightAtten0;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * tmpvar_1);
  tmpvar_2 = tmpvar_7;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_9;
  tmpvar_9 = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_9;
  highp vec4 tmpvar_10;
  tmpvar_10.w = 1.0;
  tmpvar_10.xyz = tmpvar_9;
  mediump vec3 tmpvar_11;
  mediump vec4 normal;
  normal = tmpvar_10;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAr, normal);
  x1.x = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAg, normal);
  x1.y = tmpvar_13;
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHAb, normal);
  x1.z = tmpvar_14;
  mediump vec4 tmpvar_15;
  tmpvar_15 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBr, tmpvar_15);
  x2.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBg, tmpvar_15);
  x2.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHBb, tmpvar_15);
  x2.z = tmpvar_18;
  mediump float tmpvar_19;
  tmpvar_19 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_19;
  highp vec3 tmpvar_20;
  tmpvar_20 = (unity_SHC.xyz * vC);
  x3 = tmpvar_20;
  tmpvar_11 = ((x1 + x2) + x3);
  shlight = tmpvar_11;
  tmpvar_4 = shlight;
  highp vec3 tmpvar_21;
  tmpvar_21 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_22;
  tmpvar_22 = (unity_4LightPosX0 - tmpvar_21.x);
  highp vec4 tmpvar_23;
  tmpvar_23 = (unity_4LightPosY0 - tmpvar_21.y);
  highp vec4 tmpvar_24;
  tmpvar_24 = (unity_4LightPosZ0 - tmpvar_21.z);
  highp vec4 tmpvar_25;
  tmpvar_25 = (((tmpvar_22 * tmpvar_22) + (tmpvar_23 * tmpvar_23)) + (tmpvar_24 * tmpvar_24));
  highp vec4 tmpvar_26;
  tmpvar_26 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_22 * tmpvar_9.x) + (tmpvar_23 * tmpvar_9.y)) + (tmpvar_24 * tmpvar_9.z)) * inversesqrt (tmpvar_25))) * (1.0/((1.0 + (tmpvar_25 * unity_4LightAtten0)))));
  highp vec3 tmpvar_27;
  tmpvar_27 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_26.x) + (unity_LightColor[1].xyz * tmpvar_26.y)) + (unity_LightColor[2].xyz * tmpvar_26.z)) + (unity_LightColor[3].xyz * tmpvar_26.w)));
  tmpvar_4 = tmpvar_27;
  highp vec4 o_i0;
  highp vec4 tmpvar_28;
  tmpvar_28 = (tmpvar_5 * 0.5);
  o_i0 = tmpvar_28;
  highp vec2 tmpvar_29;
  tmpvar_29.x = tmpvar_28.x;
  tmpvar_29.y = (tmpvar_28.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_29 + tmpvar_28.w);
  o_i0.zw = tmpvar_5.zw;
  gl_Position = tmpvar_5;
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * texture2DProj (_ShadowMapTexture, xlv_TEXCOORD4).x) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
uniform highp vec4 unity_LightColor[4];
uniform highp vec4 unity_4LightPosZ0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightAtten0;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  highp vec3 shlight;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec4 tmpvar_5;
  tmpvar_5 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_6;
  tmpvar_6[0] = _Object2World[0].xyz;
  tmpvar_6[1] = _Object2World[1].xyz;
  tmpvar_6[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (tmpvar_6 * tmpvar_1);
  tmpvar_2 = tmpvar_7;
  mat3 tmpvar_8;
  tmpvar_8[0] = _Object2World[0].xyz;
  tmpvar_8[1] = _Object2World[1].xyz;
  tmpvar_8[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_9;
  tmpvar_9 = (tmpvar_8 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_9;
  highp vec4 tmpvar_10;
  tmpvar_10.w = 1.0;
  tmpvar_10.xyz = tmpvar_9;
  mediump vec3 tmpvar_11;
  mediump vec4 normal;
  normal = tmpvar_10;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAr, normal);
  x1.x = tmpvar_12;
  highp float tmpvar_13;
  tmpvar_13 = dot (unity_SHAg, normal);
  x1.y = tmpvar_13;
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHAb, normal);
  x1.z = tmpvar_14;
  mediump vec4 tmpvar_15;
  tmpvar_15 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBr, tmpvar_15);
  x2.x = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = dot (unity_SHBg, tmpvar_15);
  x2.y = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = dot (unity_SHBb, tmpvar_15);
  x2.z = tmpvar_18;
  mediump float tmpvar_19;
  tmpvar_19 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_19;
  highp vec3 tmpvar_20;
  tmpvar_20 = (unity_SHC.xyz * vC);
  x3 = tmpvar_20;
  tmpvar_11 = ((x1 + x2) + x3);
  shlight = tmpvar_11;
  tmpvar_4 = shlight;
  highp vec3 tmpvar_21;
  tmpvar_21 = (_Object2World * _glesVertex).xyz;
  highp vec4 tmpvar_22;
  tmpvar_22 = (unity_4LightPosX0 - tmpvar_21.x);
  highp vec4 tmpvar_23;
  tmpvar_23 = (unity_4LightPosY0 - tmpvar_21.y);
  highp vec4 tmpvar_24;
  tmpvar_24 = (unity_4LightPosZ0 - tmpvar_21.z);
  highp vec4 tmpvar_25;
  tmpvar_25 = (((tmpvar_22 * tmpvar_22) + (tmpvar_23 * tmpvar_23)) + (tmpvar_24 * tmpvar_24));
  highp vec4 tmpvar_26;
  tmpvar_26 = (max (vec4(0.0, 0.0, 0.0, 0.0), ((((tmpvar_22 * tmpvar_9.x) + (tmpvar_23 * tmpvar_9.y)) + (tmpvar_24 * tmpvar_9.z)) * inversesqrt (tmpvar_25))) * (1.0/((1.0 + (tmpvar_25 * unity_4LightAtten0)))));
  highp vec3 tmpvar_27;
  tmpvar_27 = (tmpvar_4 + ((((unity_LightColor[0].xyz * tmpvar_26.x) + (unity_LightColor[1].xyz * tmpvar_26.y)) + (unity_LightColor[2].xyz * tmpvar_26.z)) + (unity_LightColor[3].xyz * tmpvar_26.w)));
  tmpvar_4 = tmpvar_27;
  highp vec4 o_i0;
  highp vec4 tmpvar_28;
  tmpvar_28 = (tmpvar_5 * 0.5);
  o_i0 = tmpvar_28;
  highp vec2 tmpvar_29;
  tmpvar_29.x = tmpvar_28.x;
  tmpvar_29.y = (tmpvar_28.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_29 + tmpvar_28.w);
  o_i0.zw = tmpvar_5.zw;
  gl_Position = tmpvar_5;
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = o_i0;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp float _Tilt;
uniform sampler2D _ShadowMapTexture;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, _WorldSpaceLightPos0.xyz)) * texture2DProj (_ShadowMapTexture, xlv_TEXCOORD4).x) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.xyz = (c_i0_i1.xyz + (tmpvar_2 * xlv_TEXCOORD3));
  gl_FragData[0] = c;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 6
//   opengl - ALU: 134 to 140, TEX: 17 to 19
//   d3d9 - ALU: 45 to 50, TEX: 5 to 7, FLOW: 5 to 5
SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_Tilt]
Float 3 [_BandsIntensity]
Float 4 [_BandsShift]
Vector 5 [_Color]
SetTexture 0 [_PlasmaTex] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 136 ALU, 17 TEX
PARAM c[10] = { program.local[0..5],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[7].w;
MAD R0.z, R1, c[2].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[2].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[2], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[6].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[2].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[2].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[2].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[7].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[6];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[7].x;
ADD R0.w, R0.z, c[6];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[5], c[5].y;
MUL R2.xyz, fragment.texcoord[1], c[8].x;
ADD R0.w, R1.x, c[5].z;
MUL R0.z, R0.y, c[7].y;
MUL R0.y, R0.w, c[7].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[7].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[2].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[2].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[2].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[7].x;
MUL R2.xyz, fragment.texcoord[1], c[8].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[6].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[7].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[2].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[2].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[2].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[7].x;
MUL R2.xyz, fragment.texcoord[1], c[8].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[6];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[7].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[2].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[2].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[2].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[7].x;
ADD R1.x, R1.y, c[6].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[9].y;
MOV R1.y, c[8].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[7].y;
MUL R0.x, R0, c[4];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[3].x;
MAD R1.y, R2, c[9].x, R0.x;
MOV R1.x, c[8].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
DP3 R0.w, fragment.texcoord[2], c[0];
ADD R0.y, R1.x, c[6];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R0.xyz, R0.x, c[5];
MUL R1.xyz, R0, c[6].x;
MUL R0.xyz, R1, fragment.texcoord[3];
MUL R1.xyz, R1, c[1];
MAX R0.w, R0, c[8];
MUL R1.xyz, R0.w, R1;
MAD result.color.xyz, R1, c[7].x, R0;
MOV result.color.w, c[6].y;
END
# 136 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_Tilt]
Float 3 [_BandsIntensity]
Float 4 [_BandsShift]
Vector 5 [_Color]
SetTexture 0 [_PlasmaTex] 2D
"ps_3_0
; 48 ALU, 5 TEX, 5 FLOW
dcl_2d s0
def c6, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c7, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c8, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
add r0.x, c5, c5.y
add r0.x, r0, c5.z
mov r0.z, c6.x
mov r0.w, c6.x
mul r1.z, r0.x, c6.y
loop aL, i0
add r0.w, r0, c6.z
mul r0.x, r0.w, c6.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c7.x
mov r0.y, r2.x
mad r0.x, r2.z, c2, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c2, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c2, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c7.y, c7.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c7.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c8.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c6.x
mul r0.x, r0, c8.y
texld r0.x, r0, s0
mul r0.x, r0, c4
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c8.z, r0.x
mov r0.x, c6
texld r0.x, r0, s0
mul r0.w, r0, c3.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c6.z
mul r0.x, r0.z, r0
mul r1.xyz, r0.x, c5
mul_pp r0.xyz, r1, v3
dp3_pp r0.w, v2, c0
mul_pp r1.xyz, r1, c1
max_pp r0.w, r0, c6.x
mul_pp r1.xyz, r0.w, r1
mad_pp oC0.xyz, r1, c7.y, r0
mov_pp oC0.w, c6.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 134 ALU, 18 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[5].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[5].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R1.xyz, R0.x, c[3];
TEX R0, fragment.texcoord[2], texture[1], 2D;
MUL R1.xyz, R1, c[4].x;
MUL R0.xyz, R0.w, R0;
MUL R0.xyz, R0, R1;
MUL result.color.xyz, R0, c[7].z;
MOV result.color.w, c[4].y;
END
# 134 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [unity_Lightmap] 2D
"ps_3_0
; 45 ALU, 6 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xy
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.z, c4.x
mov r0.w, c4.x
mul r1.z, r0.x, c4.y
loop aL, i0
add r0.w, r0, c4.z
mul r0.x, r0.w, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c6.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.w, r0, c1.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c4.z
mul r1.x, r0.z, r0
texld r0, v2, s1
mul r1.xyz, r1.x, c3
mul_pp r0.xyz, r0.w, r0
mul_pp r0.xyz, r0, r1
mul_pp oC0.xyz, r0, c6.w
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 134 ALU, 18 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[5].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[5].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R1.xyz, R0.x, c[3];
TEX R0, fragment.texcoord[2], texture[1], 2D;
MUL R1.xyz, R1, c[4].x;
MUL R0.xyz, R0.w, R0;
MUL R0.xyz, R0, R1;
MUL result.color.xyz, R0, c[7].z;
MOV result.color.w, c[4].y;
END
# 134 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [unity_Lightmap] 2D
"ps_3_0
; 45 ALU, 6 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xy
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.z, c4.x
mov r0.w, c4.x
mul r1.z, r0.x, c4.y
loop aL, i0
add r0.w, r0, c4.z
mul r0.x, r0.w, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c6.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.w, r0, c1.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c4.z
mul r1.x, r0.z, r0
texld r0, v2, s1
mul r1.xyz, r1.x, c3
mul_pp r0.xyz, r0.w, r0
mul_pp r0.xyz, r0, r1
mul_pp oC0.xyz, r0, c6.w
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_Tilt]
Float 3 [_BandsIntensity]
Float 4 [_BandsShift]
Vector 5 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_ShadowMapTexture] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 138 ALU, 18 TEX
PARAM c[10] = { program.local[0..5],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[7].w;
MAD R0.z, R1, c[2].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[2].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[2], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[6].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[2].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[2].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[2].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[7].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[6];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[7].x;
ADD R0.w, R0.z, c[6];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[5], c[5].y;
MUL R2.xyz, fragment.texcoord[1], c[8].x;
ADD R0.w, R1.x, c[5].z;
MUL R0.z, R0.y, c[7].y;
MUL R0.y, R0.w, c[7].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[7].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[2].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[2].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[2].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[7].x;
MUL R2.xyz, fragment.texcoord[1], c[8].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[6].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[7].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[2].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[2].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[2].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[7].x;
MUL R2.xyz, fragment.texcoord[1], c[8].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[6];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[7].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[2].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[2].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[2].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[7].x;
ADD R1.x, R1.y, c[6].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[9].y;
MOV R1.y, c[8].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.x, R0, c[4];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[3].x;
MAD R1.y, R2, c[9].x, R0.x;
MOV R1.x, c[8].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
MUL R0.w, R0, c[7].y;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[6];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R0.xyz, R0.x, c[5];
MUL R0.xyz, R0, c[6].x;
MUL R2.xyz, R0, fragment.texcoord[3];
MUL R1.xyz, R0, c[1];
DP3 R0.y, fragment.texcoord[2], c[0];
MAX R0.y, R0, c[8].w;
TXP R0.x, fragment.texcoord[4], texture[1], 2D;
MUL R0.x, R0.y, R0;
MUL R0.xyz, R0.x, R1;
MAD result.color.xyz, R0, c[7].x, R2;
MOV result.color.w, c[6].y;
END
# 138 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Vector 0 [_WorldSpaceLightPos0]
Vector 1 [_LightColor0]
Float 2 [_Tilt]
Float 3 [_BandsIntensity]
Float 4 [_BandsShift]
Vector 5 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_ShadowMapTexture] 2D
"ps_3_0
; 49 ALU, 6 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
def c6, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c7, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c8, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4
add r0.x, c5, c5.y
add r0.x, r0, c5.z
mov r0.z, c6.x
mov r0.w, c6.x
mul r1.z, r0.x, c6.y
loop aL, i0
add r0.w, r0, c6.z
mul r0.x, r0.w, c6.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c7.x
mov r0.y, r2.x
mad r0.x, r2.z, c2, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c2, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c2, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c7.y, c7.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c7.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c8.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c6.x
mul r0.x, r0, c8.y
texld r0.x, r0, s0
mul r0.x, r0, c4
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c8.z, r0.x
mov r0.x, c6
texld r0.x, r0, s0
mul r0.w, r0, c3.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c6.z
mul r0.x, r0.z, r0
mul r0.xyz, r0.x, c5
mul_pp r2.xyz, r0, v3
mul_pp r1.xyz, r0, c1
dp3_pp r0.y, v2, c0
max_pp r0.y, r0, c6.x
texldp r0.x, v4, s1
mul_pp r0.x, r0.y, r0
mul_pp r0.xyz, r0.x, r1
mad_pp oC0.xyz, r0, c7.y, r2
mov_pp oC0.w, c6.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_ShadowMapTexture] 2D
SetTexture 2 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 140 ALU, 19 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[5].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
MUL R0.w, R0, c[5].y;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R2.xyz, R0.x, c[3];
TEX R1, fragment.texcoord[2], texture[2], 2D;
MUL R3.xyz, R1.w, R1;
TXP R0.x, fragment.texcoord[3], texture[1], 2D;
MUL R1.xyz, R1, R0.x;
MUL R3.xyz, R3, c[7].z;
MUL R1.xyz, R1, c[5].x;
MIN R1.xyz, R3, R1;
MUL R0.xyz, R3, R0.x;
MAX R0.xyz, R1, R0;
MUL R1.xyz, R2, c[4].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[4].y;
END
# 140 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_ShadowMapTexture] 2D
SetTexture 2 [unity_Lightmap] 2D
"ps_3_0
; 50 ALU, 7 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xy
dcl_texcoord3 v3
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.w, c4.x
mov r1.z, c4.x
mul r0.z, r0.x, c4.y
loop aL, i0
add r1.z, r1, c4
mul r0.x, r1.z, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r0.z
mad r0.w, r0.x, c6.x, r0
endloop
add r0.x, r2, r2.z
texld r1, v2, s2
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.z, v0
add_sat r0.z, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.z, r0, c1.x
mad r0.y, r0.x, r0.z, -r0.z
texldp r0.x, v3, s1
mul_pp r2.xyz, r1, r0.x
mul_pp r1.xyz, r1.w, r1
add r1.w, r0.y, c4.z
mul_pp r1.xyz, r1, c6.w
mul_pp r2.xyz, r2, c5.y
min_pp r2.xyz, r1, r2
mul_pp r0.xyz, r1, r0.x
mul r0.w, r0, r1
max_pp r0.xyz, r2, r0
mul r1.xyz, r0.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_ShadowMapTexture] 2D
SetTexture 2 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 140 ALU, 19 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.z, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.w, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.z, R1.w;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
MUL R0.w, -R2.y, c[5].x;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
RCP R0.z, R2.z;
ADD R0.y, R3.x, -R2.x;
MUL_SAT R0.y, R0, R0.z;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.z, R1.x, -R0.x;
RCP R0.w, R1.w;
MUL_SAT R0.z, R0, R0.w;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.z, R1.x, -R0.x;
RCP R0.w, R1.w;
MUL_SAT R0.w, R0.z, R0;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.z, R1.x, -R0.x;
RCP R0.w, R1.w;
MUL_SAT R2.w, R0.z, R0;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
MUL R0.w, R0, c[5].y;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R2.xyz, R0.x, c[3];
TEX R1, fragment.texcoord[2], texture[2], 2D;
MUL R3.xyz, R1.w, R1;
TXP R0.x, fragment.texcoord[3], texture[1], 2D;
MUL R1.xyz, R1, R0.x;
MUL R3.xyz, R3, c[7].z;
MUL R1.xyz, R1, c[5].x;
MIN R1.xyz, R3, R1;
MUL R0.xyz, R3, R0.x;
MAX R0.xyz, R1, R0;
MUL R1.xyz, R2, c[4].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[4].y;
END
# 140 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_ShadowMapTexture] 2D
SetTexture 2 [unity_Lightmap] 2D
"ps_3_0
; 50 ALU, 7 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xy
dcl_texcoord3 v3
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.w, c4.x
mov r1.z, c4.x
mul r0.z, r0.x, c4.y
loop aL, i0
add r1.z, r1, c4
mul r0.x, r1.z, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r0.z
mad r0.w, r0.x, c6.x, r0
endloop
add r0.x, r2, r2.z
texld r1, v2, s2
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.z, v0
add_sat r0.z, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.z, r0, c1.x
mad r0.y, r0.x, r0.z, -r0.z
texldp r0.x, v3, s1
mul_pp r2.xyz, r1, r0.x
mul_pp r1.xyz, r1.w, r1
add r1.w, r0.y, c4.z
mul_pp r1.xyz, r1, c6.w
mul_pp r2.xyz, r2, c5.y
min_pp r2.xyz, r1, r2
mul_pp r0.xyz, r1, r0.x
mul r0.w, r0, r1
max_pp r0.xyz, r2, r0
mul r1.xyz, r0.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "SHADOWS_SCREEN" }
"!!GLES"
}

}
	}
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off Blend One One Fog { Color (0,0,0,0) }
Program "vp" {
// Vertex combos: 5
//   opengl - ALU: 15 to 22
//   d3d9 - ALU: 15 to 22
SubProgram "opengl " {
Keywords { "POINT" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 13 [unity_Scale]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 21 ALU
PARAM c[15] = { program.local[0],
		state.matrix.mvp,
		program.local[5..14] };
TEMP R0;
TEMP R1;
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
MOV R0.xyz, R1;
DP4 R0.w, vertex.position, c[8];
DP4 result.texcoord[4].z, R0, c[11];
DP4 result.texcoord[4].y, R0, c[10];
DP4 result.texcoord[4].x, R0, c[9];
MUL R0.xyz, vertex.normal, c[13].w;
MOV result.texcoord[1].xyz, R1;
DP3 result.texcoord[2].z, R0, c[7];
DP3 result.texcoord[2].y, R0, c[6];
DP3 result.texcoord[2].x, R0, c[5];
ADD result.texcoord[3].xyz, -R1, c[14];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
END
# 21 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 12 [unity_Scale]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 21 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_position0 v0
dcl_normal0 v1
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
mov r0.xyz, r1
dp4 r0.w, v0, c7
dp4 o5.z, r0, c10
dp4 o5.y, r0, c9
dp4 o5.x, r0, c8
mul r0.xyz, v1, c12.w
mov o2.xyz, r1
dp3 o3.z, r0, c6
dp3 o3.y, r0, c5
dp3 o3.x, r0, c4
add o4.xyz, -r1, c13
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
"
}

SubProgram "gles " {
Keywords { "POINT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  mediump vec3 tmpvar_49;
  tmpvar_49 = normalize (xlv_TEXCOORD3);
  lightDir = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = vec2(dot (xlv_TEXCOORD4, xlv_TEXCOORD4));
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * texture2D (_LightTexture0, tmpvar_50).w) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "POINT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  mediump vec3 tmpvar_49;
  tmpvar_49 = normalize (xlv_TEXCOORD3);
  lightDir = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = vec2(dot (xlv_TEXCOORD4, xlv_TEXCOORD4));
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * texture2D (_LightTexture0, tmpvar_50).w) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [unity_Scale]
Vector 10 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
"3.0-!!ARBvp1.0
# 15 ALU
PARAM c[11] = { program.local[0],
		state.matrix.mvp,
		program.local[5..10] };
TEMP R0;
MUL R0.xyz, vertex.normal, c[9].w;
DP3 result.texcoord[2].z, R0, c[7];
DP3 result.texcoord[2].y, R0, c[6];
DP3 result.texcoord[2].x, R0, c[5];
MOV result.texcoord[3].xyz, c[10];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 15 instructions, 1 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [unity_Scale]
Vector 9 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
"vs_3_0
; 15 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_position0 v0
dcl_normal0 v1
mul r0.xyz, v1, c8.w
dp3 o3.z, r0, c6
dp3 o3.y, r0, c5
dp3 o3.x, r0, c4
mov o4.xyz, c9
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = _WorldSpaceLightPos0.xyz;
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lightDir = xlv_TEXCOORD3;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * (max (0.0, dot (xlv_TEXCOORD2, lightDir)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = _WorldSpaceLightPos0.xyz;
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lightDir = xlv_TEXCOORD3;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * (max (0.0, dot (xlv_TEXCOORD2, lightDir)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "SPOT" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 13 [unity_Scale]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 22 ALU
PARAM c[15] = { program.local[0],
		state.matrix.mvp,
		program.local[5..14] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[8];
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
MOV R0.xyz, R1;
DP4 result.texcoord[4].w, R0, c[12];
DP4 result.texcoord[4].z, R0, c[11];
DP4 result.texcoord[4].y, R0, c[10];
DP4 result.texcoord[4].x, R0, c[9];
MUL R0.xyz, vertex.normal, c[13].w;
MOV result.texcoord[1].xyz, R1;
DP3 result.texcoord[2].z, R0, c[7];
DP3 result.texcoord[2].y, R0, c[6];
DP3 result.texcoord[2].x, R0, c[5];
ADD result.texcoord[3].xyz, -R1, c[14];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
END
# 22 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "SPOT" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 12 [unity_Scale]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 22 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_position0 v0
dcl_normal0 v1
dp4 r0.w, v0, c7
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
mov r0.xyz, r1
dp4 o5.w, r0, c11
dp4 o5.z, r0, c10
dp4 o5.y, r0, c9
dp4 o5.x, r0, c8
mul r0.xyz, v1, c12.w
mov o2.xyz, r1
dp3 o3.z, r0, c6
dp3 o3.y, r0, c5
dp3 o3.x, r0, c4
add o4.xyz, -r1, c13
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
"
}

SubProgram "gles " {
Keywords { "SPOT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTextureB0;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  mediump vec3 tmpvar_49;
  tmpvar_49 = normalize (xlv_TEXCOORD3);
  lightDir = tmpvar_49;
  highp vec3 LightCoord_i0;
  LightCoord_i0 = xlv_TEXCOORD4.xyz;
  highp vec2 tmpvar_50;
  tmpvar_50 = vec2(dot (LightCoord_i0, LightCoord_i0));
  lowp float atten;
  atten = ((float((xlv_TEXCOORD4.z > 0.0)) * texture2D (_LightTexture0, ((xlv_TEXCOORD4.xy / xlv_TEXCOORD4.w) + 0.5)).w) * texture2D (_LightTextureB0, tmpvar_50).w);
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * atten) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "SPOT" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec4 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTextureB0;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  mediump vec3 tmpvar_49;
  tmpvar_49 = normalize (xlv_TEXCOORD3);
  lightDir = tmpvar_49;
  highp vec3 LightCoord_i0;
  LightCoord_i0 = xlv_TEXCOORD4.xyz;
  highp vec2 tmpvar_50;
  tmpvar_50 = vec2(dot (LightCoord_i0, LightCoord_i0));
  lowp float atten;
  atten = ((float((xlv_TEXCOORD4.z > 0.0)) * texture2D (_LightTexture0, ((xlv_TEXCOORD4.xy / xlv_TEXCOORD4.w) + 0.5)).w) * texture2D (_LightTextureB0, tmpvar_50).w);
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * atten) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "POINT_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 13 [unity_Scale]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 21 ALU
PARAM c[15] = { program.local[0],
		state.matrix.mvp,
		program.local[5..14] };
TEMP R0;
TEMP R1;
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
MOV R0.xyz, R1;
DP4 R0.w, vertex.position, c[8];
DP4 result.texcoord[4].z, R0, c[11];
DP4 result.texcoord[4].y, R0, c[10];
DP4 result.texcoord[4].x, R0, c[9];
MUL R0.xyz, vertex.normal, c[13].w;
MOV result.texcoord[1].xyz, R1;
DP3 result.texcoord[2].z, R0, c[7];
DP3 result.texcoord[2].y, R0, c[6];
DP3 result.texcoord[2].x, R0, c[5];
ADD result.texcoord[3].xyz, -R1, c[14];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
END
# 21 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 12 [unity_Scale]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 21 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_position0 v0
dcl_normal0 v1
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
mov r0.xyz, r1
dp4 r0.w, v0, c7
dp4 o5.z, r0, c10
dp4 o5.y, r0, c9
dp4 o5.x, r0, c8
mul r0.xyz, v1, c12.w
mov o2.xyz, r1
dp3 o3.z, r0, c6
dp3 o3.y, r0, c5
dp3 o3.x, r0, c4
add o4.xyz, -r1, c13
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
"
}

SubProgram "gles " {
Keywords { "POINT_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTextureB0;
uniform samplerCube _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  mediump vec3 tmpvar_49;
  tmpvar_49 = normalize (xlv_TEXCOORD3);
  lightDir = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = vec2(dot (xlv_TEXCOORD4, xlv_TEXCOORD4));
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * (texture2D (_LightTextureB0, tmpvar_50).w * textureCube (_LightTexture0, xlv_TEXCOORD4).w)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "POINT_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (_WorldSpaceLightPos0.xyz - (_Object2World * _glesVertex).xyz);
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex)).xyz;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTextureB0;
uniform samplerCube _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  mediump vec3 tmpvar_49;
  tmpvar_49 = normalize (xlv_TEXCOORD3);
  lightDir = tmpvar_49;
  highp vec2 tmpvar_50;
  tmpvar_50 = vec2(dot (xlv_TEXCOORD4, xlv_TEXCOORD4));
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * (texture2D (_LightTextureB0, tmpvar_50).w * textureCube (_LightTexture0, xlv_TEXCOORD4).w)) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 13 [unity_Scale]
Vector 14 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_LightMatrix0]
"3.0-!!ARBvp1.0
# 20 ALU
PARAM c[15] = { program.local[0],
		state.matrix.mvp,
		program.local[5..14] };
TEMP R0;
TEMP R1;
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
MOV R0.xyz, R1;
DP4 R0.w, vertex.position, c[8];
DP4 result.texcoord[4].y, R0, c[10];
DP4 result.texcoord[4].x, R0, c[9];
MUL R0.xyz, vertex.normal, c[13].w;
MOV result.texcoord[1].xyz, R1;
DP3 result.texcoord[2].z, R0, c[7];
DP3 result.texcoord[2].y, R0, c[6];
DP3 result.texcoord[2].x, R0, c[5];
MOV result.texcoord[3].xyz, c[14];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
END
# 20 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL_COOKIE" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 12 [unity_Scale]
Vector 13 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_LightMatrix0]
"vs_3_0
; 20 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_position0 v0
dcl_normal0 v1
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
mov r0.xyz, r1
dp4 r0.w, v0, c7
dp4 o5.y, r0, c9
dp4 o5.x, r0, c8
mul r0.xyz, v1, c12.w
mov o2.xyz, r1
dp3 o3.z, r0, c6
dp3 o3.y, r0, c5
dp3 o3.x, r0, c4
mov o4.xyz, c13
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = _WorldSpaceLightPos0.xyz;
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex)).xy;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lightDir = xlv_TEXCOORD3;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * texture2D (_LightTexture0, xlv_TEXCOORD4).w) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp mat4 _Object2World;
uniform highp mat4 _LightMatrix0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec3 tmpvar_1;
  tmpvar_1 = normalize (_glesNormal);
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  mediump vec3 tmpvar_4;
  mat3 tmpvar_5;
  tmpvar_5[0] = _Object2World[0].xyz;
  tmpvar_5[1] = _Object2World[1].xyz;
  tmpvar_5[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_6;
  tmpvar_6 = (tmpvar_5 * tmpvar_1);
  tmpvar_2 = tmpvar_6;
  mat3 tmpvar_7;
  tmpvar_7[0] = _Object2World[0].xyz;
  tmpvar_7[1] = _Object2World[1].xyz;
  tmpvar_7[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_8;
  tmpvar_8 = (tmpvar_7 * (tmpvar_1 * unity_Scale.w));
  tmpvar_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = _WorldSpaceLightPos0.xyz;
  tmpvar_4 = tmpvar_9;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = tmpvar_3;
  xlv_TEXCOORD3 = tmpvar_4;
  xlv_TEXCOORD4 = (_LightMatrix0 * (_Object2World * _glesVertex)).xy;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying lowp vec3 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightTexture0;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 c;
  lowp vec3 lightDir;
  highp vec3 tmpvar_1;
  tmpvar_1 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_2;
  tmpvar_2 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_3;
  tmpvar_3 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_4;
  tmpvar_4.x = (tmpvar_3.x + (tmpvar_3.y * _Tilt));
  tmpvar_4.y = tmpvar_3.z;
  lowp float tmpvar_5;
  tmpvar_5 = texture2D (_PlasmaTex, tmpvar_4).x;
  cx = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = (tmpvar_3.y + (tmpvar_3.z * _Tilt));
  tmpvar_6.y = tmpvar_3.x;
  lowp float tmpvar_7;
  tmpvar_7 = texture2D (_PlasmaTex, tmpvar_6).x;
  cy = tmpvar_7;
  highp vec2 tmpvar_8;
  tmpvar_8.x = (tmpvar_3.z + (tmpvar_3.x * _Tilt));
  tmpvar_8.y = tmpvar_3.y;
  lowp float tmpvar_9;
  tmpvar_9 = texture2D (_PlasmaTex, tmpvar_8).x;
  cz = tmpvar_9;
  highp float tmpvar_10;
  tmpvar_10 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_10;
  if ((tmpvar_10 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_11;
  tmpvar_11 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_12;
  tmpvar_12.x = (tmpvar_11.x + (tmpvar_11.y * _Tilt));
  tmpvar_12.y = tmpvar_11.z;
  lowp float tmpvar_13;
  tmpvar_13 = texture2D (_PlasmaTex, tmpvar_12).x;
  cx = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14.x = (tmpvar_11.y + (tmpvar_11.z * _Tilt));
  tmpvar_14.y = tmpvar_11.x;
  lowp float tmpvar_15;
  tmpvar_15 = texture2D (_PlasmaTex, tmpvar_14).x;
  cy = tmpvar_15;
  highp vec2 tmpvar_16;
  tmpvar_16.x = (tmpvar_11.z + (tmpvar_11.x * _Tilt));
  tmpvar_16.y = tmpvar_11.y;
  lowp float tmpvar_17;
  tmpvar_17 = texture2D (_PlasmaTex, tmpvar_16).x;
  cz = tmpvar_17;
  highp float tmpvar_18;
  tmpvar_18 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_18;
  if ((tmpvar_18 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_19;
  tmpvar_19 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = (tmpvar_19.x + (tmpvar_19.y * _Tilt));
  tmpvar_20.y = tmpvar_19.z;
  lowp float tmpvar_21;
  tmpvar_21 = texture2D (_PlasmaTex, tmpvar_20).x;
  cx = tmpvar_21;
  highp vec2 tmpvar_22;
  tmpvar_22.x = (tmpvar_19.y + (tmpvar_19.z * _Tilt));
  tmpvar_22.y = tmpvar_19.x;
  lowp float tmpvar_23;
  tmpvar_23 = texture2D (_PlasmaTex, tmpvar_22).x;
  cy = tmpvar_23;
  highp vec2 tmpvar_24;
  tmpvar_24.x = (tmpvar_19.z + (tmpvar_19.x * _Tilt));
  tmpvar_24.y = tmpvar_19.y;
  lowp float tmpvar_25;
  tmpvar_25 = texture2D (_PlasmaTex, tmpvar_24).x;
  cz = tmpvar_25;
  highp float tmpvar_26;
  tmpvar_26 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_26;
  if ((tmpvar_26 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_27;
  tmpvar_27 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_28;
  tmpvar_28.x = (tmpvar_27.x + (tmpvar_27.y * _Tilt));
  tmpvar_28.y = tmpvar_27.z;
  lowp float tmpvar_29;
  tmpvar_29 = texture2D (_PlasmaTex, tmpvar_28).x;
  cx = tmpvar_29;
  highp vec2 tmpvar_30;
  tmpvar_30.x = (tmpvar_27.y + (tmpvar_27.z * _Tilt));
  tmpvar_30.y = tmpvar_27.x;
  lowp float tmpvar_31;
  tmpvar_31 = texture2D (_PlasmaTex, tmpvar_30).x;
  cy = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = (tmpvar_27.z + (tmpvar_27.x * _Tilt));
  tmpvar_32.y = tmpvar_27.y;
  lowp float tmpvar_33;
  tmpvar_33 = texture2D (_PlasmaTex, tmpvar_32).x;
  cz = tmpvar_33;
  highp float tmpvar_34;
  tmpvar_34 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_34;
  if ((tmpvar_34 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_35;
  tmpvar_35 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_36;
  tmpvar_36.x = (tmpvar_35.x + (tmpvar_35.y * _Tilt));
  tmpvar_36.y = tmpvar_35.z;
  lowp float tmpvar_37;
  tmpvar_37 = texture2D (_PlasmaTex, tmpvar_36).x;
  cx = tmpvar_37;
  highp vec2 tmpvar_38;
  tmpvar_38.x = (tmpvar_35.y + (tmpvar_35.z * _Tilt));
  tmpvar_38.y = tmpvar_35.x;
  lowp float tmpvar_39;
  tmpvar_39 = texture2D (_PlasmaTex, tmpvar_38).x;
  cy = tmpvar_39;
  highp vec2 tmpvar_40;
  tmpvar_40.x = (tmpvar_35.z + (tmpvar_35.x * _Tilt));
  tmpvar_40.y = tmpvar_35.y;
  lowp float tmpvar_41;
  tmpvar_41 = texture2D (_PlasmaTex, tmpvar_40).x;
  cz = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_42;
  if ((tmpvar_42 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_43;
  tmpvar_43.y = 0.0;
  tmpvar_43.x = ((tmpvar_35.x + tmpvar_35.z) * 0.001);
  lowp vec4 tmpvar_44;
  tmpvar_44 = texture2D (_PlasmaTex, tmpvar_43);
  highp float tmpvar_45;
  tmpvar_45 = (clamp ((abs (tmpvar_1.x) + abs (tmpvar_1.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_46;
  tmpvar_46.x = 0.0;
  tmpvar_46.y = ((tmpvar_35.y * 0.0001) + (tmpvar_44.x * _BandsShift));
  lowp vec4 tmpvar_47;
  tmpvar_47 = texture2D (_PlasmaTex, tmpvar_46);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((c_i0 * ((tmpvar_47.x * tmpvar_45) + (1.0 - tmpvar_45))) * _Color.xyz);
  tmpvar_2 = tmpvar_48;
  lightDir = xlv_TEXCOORD3;
  lowp vec4 c_i0_i1;
  c_i0_i1.xyz = ((tmpvar_2 * _LightColor0.xyz) * ((max (0.0, dot (xlv_TEXCOORD2, lightDir)) * texture2D (_LightTexture0, xlv_TEXCOORD4).w) * 2.0));
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  c.w = 0.0;
  gl_FragData[0] = c;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 5
//   opengl - ALU: 136 to 147, TEX: 17 to 19
//   d3d9 - ALU: 48 to 57, TEX: 5 to 7, FLOW: 5 to 5
SubProgram "opengl " {
Keywords { "POINT" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTexture0] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 141 ALU, 18 TEX
PARAM c[9] = { program.local[0..4],
		{ 0.2, 0, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 9.9999997e-05 },
		{ 0.001, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[6].w;
MAD R0.z, R1, c[1].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[1].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[1], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[5].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[1].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[1].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[1].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[6].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[5];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[6].x;
ADD R0.w, R0.z, c[5];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[4], c[4].y;
MUL R2.xyz, fragment.texcoord[1], c[7].x;
ADD R0.w, R1.x, c[4].z;
MUL R0.z, R0.y, c[6].y;
MUL R0.y, R0.w, c[6].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[6].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[5].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[6].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[5];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[6].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[6].x;
ADD R1.x, R1.y, c[5].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[8];
MOV R1.y, c[5];
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[6].y;
MUL R0.x, R0, c[3];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[2].x;
MAD R1.y, R2, c[7].w, R0.x;
MOV R1.x, c[5].y;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
DP3 R0.w, fragment.texcoord[3], fragment.texcoord[3];
ADD R0.y, R1.x, c[8];
ADD R0.x, R0.z, R0;
RSQ R0.w, R0.w;
MUL R1.xyz, R0.w, fragment.texcoord[3];
MUL R0.x, R0, R0.y;
MUL R0.xyz, R0.x, c[4];
MUL R0.xyz, R0, c[5].x;
DP3 R0.w, fragment.texcoord[4], fragment.texcoord[4];
DP3 R1.x, fragment.texcoord[2], R1;
MUL R0.xyz, R0, c[0];
TEX R0.w, R0.w, texture[1], 2D;
MAX R1.x, R1, c[5].y;
MUL R0.w, R1.x, R0;
MUL R0.xyz, R0.w, R0;
MUL result.color.xyz, R0, c[6].x;
MOV result.color.w, c[5].y;
END
# 141 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTexture0] 2D
"ps_3_0
; 52 ALU, 6 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
def c5, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c6, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c7, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
add r0.x, c4, c4.y
add r0.x, r0, c4.z
mov r0.z, c5.x
mov r0.w, c5.x
mul r1.z, r0.x, c5.y
loop aL, i0
add r0.w, r0, c5.z
mul r0.x, r0.w, c5.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c6.x
mov r0.y, r2.x
mad r0.x, r2.z, c1, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c1, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c1, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c6.y, c6.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c6.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c7.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c5.x
mul r0.x, r0, c7.y
texld r0.x, r0, s0
mul r0.x, r0, c3
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c7.z, r0.x
mov r0.x, c5
texld r0.x, r0, s0
mul r0.w, r0, c2.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c5.z
mul r0.x, r0.z, r0
mul r0.xyz, r0.x, c4
mul_pp r1.xyz, r0, c0
dp3_pp r0.w, v3, v3
rsq_pp r0.w, r0.w
mul_pp r2.xyz, r0.w, v3
dp3 r0.x, v4, v4
dp3_pp r0.y, v2, r2
max_pp r0.y, r0, c5.x
texld r0.x, r0.x, s1
mul_pp r0.x, r0.y, r0
mul_pp r0.xyz, r0.x, r1
mul_pp oC0.xyz, r0, c6.y
mov_pp oC0.w, c5.x
"
}

SubProgram "gles " {
Keywords { "POINT" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "POINT" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 136 ALU, 17 TEX
PARAM c[9] = { program.local[0..4],
		{ 0.2, 0, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 9.9999997e-05 },
		{ 0.001, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[6].w;
MAD R0.z, R1, c[1].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[1].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[1], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[5].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[1].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[1].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[1].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[6].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[5];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[6].x;
ADD R0.w, R0.z, c[5];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[4], c[4].y;
MUL R2.xyz, fragment.texcoord[1], c[7].x;
ADD R0.w, R1.x, c[4].z;
MUL R0.z, R0.y, c[6].y;
MUL R0.y, R0.w, c[6].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[6].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[5].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[6].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[5];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[6].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[6].x;
ADD R1.x, R1.y, c[5].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[8];
MOV R1.y, c[5];
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[6].y;
MUL R0.x, R0, c[3];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[2].x;
MAD R1.y, R2, c[7].w, R0.x;
MOV R1.x, c[5].y;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[8];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R1.xyz, R0.x, c[4];
MOV R0.xyz, fragment.texcoord[3];
DP3 R0.w, fragment.texcoord[2], R0;
MUL R1.xyz, R1, c[5].x;
MUL R0.xyz, R1, c[0];
MAX R0.w, R0, c[5].y;
MUL R0.xyz, R0.w, R0;
MUL result.color.xyz, R0, c[6].x;
MOV result.color.w, c[5].y;
END
# 136 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
"ps_3_0
; 48 ALU, 5 TEX, 5 FLOW
dcl_2d s0
def c5, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c6, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c7, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
add r0.x, c4, c4.y
add r0.x, r0, c4.z
mov r0.z, c5.x
mov r0.w, c5.x
mul r1.z, r0.x, c5.y
loop aL, i0
add r0.w, r0, c5.z
mul r0.x, r0.w, c5.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c6.x
mov r0.y, r2.x
mad r0.x, r2.z, c1, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c1, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c1, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c6.y, c6.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c6.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c7.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c5.x
mul r0.x, r0, c7.y
texld r0.x, r0, s0
mul r0.x, r0, c3
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c7.z, r0.x
mov r0.x, c5
texld r0.x, r0, s0
mul r0.w, r0, c2.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c5.z
mul r0.w, r0.z, r0.x
mov_pp r0.xyz, v3
dp3_pp r0.x, v2, r0
mul r1.xyz, r0.w, c4
mul_pp r1.xyz, r1, c0
max_pp r0.x, r0, c5
mul_pp r0.xyz, r0.x, r1
mul_pp oC0.xyz, r0, c6.y
mov_pp oC0.w, c5.x
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "SPOT" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTexture0] 2D
SetTexture 2 [_LightTextureB0] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 147 ALU, 19 TEX
PARAM c[9] = { program.local[0..4],
		{ 0.2, 0, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 9.9999997e-05 },
		{ 0.001, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[6].w;
MAD R0.z, R1, c[1].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[1].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[1], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[5].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[1].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[1].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[1].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[6].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[5];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[6].x;
ADD R0.w, R0.z, c[5];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[4], c[4].y;
MUL R2.xyz, fragment.texcoord[1], c[7].x;
ADD R0.w, R1.x, c[4].z;
MUL R0.z, R0.y, c[6].y;
MUL R0.y, R0.w, c[6].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[6].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[5].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[6].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[5];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[6].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[6].x;
ADD R1.x, R1.y, c[5].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[8];
MOV R1.y, c[5];
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[6].y;
MUL R0.x, R0, c[3];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[2].x;
MAD R1.y, R2, c[7].w, R0.x;
MOV R1.x, c[5].y;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
DP3 R0.w, fragment.texcoord[3], fragment.texcoord[3];
ADD R0.y, R1.x, c[8];
ADD R0.x, R0.z, R0;
RSQ R0.w, R0.w;
MUL R1.xyz, R0.w, fragment.texcoord[3];
DP3 R1.x, fragment.texcoord[2], R1;
RCP R0.w, fragment.texcoord[4].w;
MAD R1.zw, fragment.texcoord[4].xyxy, R0.w, c[7].x;
MUL R0.x, R0, R0.y;
MUL R0.xyz, R0.x, c[4];
MUL R0.xyz, R0, c[5].x;
DP3 R1.y, fragment.texcoord[4], fragment.texcoord[4];
TEX R0.w, R1.zwzw, texture[1], 2D;
TEX R1.w, R1.y, texture[2], 2D;
SLT R1.y, c[5], fragment.texcoord[4].z;
MUL R0.w, R1.y, R0;
MUL R1.y, R0.w, R1.w;
MAX R0.w, R1.x, c[5].y;
MUL R0.xyz, R0, c[0];
MUL R0.w, R0, R1.y;
MUL R0.xyz, R0.w, R0;
MUL result.color.xyz, R0, c[6].x;
MOV result.color.w, c[5].y;
END
# 147 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "SPOT" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTexture0] 2D
SetTexture 2 [_LightTextureB0] 2D
"ps_3_0
; 57 ALU, 7 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c5, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c6, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c7, 0.20000000, 0.00100000, 0.00010000, 0.50000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4
add r0.x, c4, c4.y
add r0.x, r0, c4.z
mov r0.z, c5.x
mov r0.w, c5.x
mul r1.z, r0.x, c5.y
loop aL, i0
add r0.w, r0, c5.z
mul r0.x, r0.w, c5.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c6.x
mov r0.y, r2.x
mad r0.x, r2.z, c1, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c1, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c1, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c6.y, c6.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c6.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c7.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c5.x
mul r0.x, r0, c7.y
texld r0.x, r0, s0
mul r0.x, r0, c3
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c7.z, r0.x
mov r0.x, c5
texld r0.x, r0, s0
mul r0.w, r0, c2.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c5.z
mul r0.x, r0.z, r0
mul r0.xyz, r0.x, c4
dp3_pp r0.w, v3, v3
rsq_pp r0.w, r0.w
mul_pp r1.xyz, r0, c0
mul_pp r0.xyz, r0.w, v3
dp3_pp r0.y, v2, r0
rcp r0.w, v4.w
mad r2.xy, v4, r0.w, c7.w
dp3 r0.x, v4, v4
max_pp r0.y, r0, c5.x
texld r0.w, r2, s1
cmp r0.z, -v4, c5.x, c5
mul_pp r0.z, r0, r0.w
texld r0.x, r0.x, s2
mul_pp r0.x, r0.z, r0
mul_pp r0.x, r0.y, r0
mul_pp r0.xyz, r0.x, r1
mul_pp oC0.xyz, r0, c6.y
mov_pp oC0.w, c5.x
"
}

SubProgram "gles " {
Keywords { "SPOT" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "SPOT" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "POINT_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTextureB0] 2D
SetTexture 2 [_LightTexture0] CUBE
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 143 ALU, 19 TEX
PARAM c[9] = { program.local[0..4],
		{ 0.2, 0, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 9.9999997e-05 },
		{ 0.001, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[6].w;
MAD R0.z, R1, c[1].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[1].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[1], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[5].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[1].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[1].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[1].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[6].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[5];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[6].x;
ADD R0.w, R0.z, c[5];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[4], c[4].y;
MUL R2.xyz, fragment.texcoord[1], c[7].x;
ADD R0.w, R1.x, c[4].z;
MUL R0.z, R0.y, c[6].y;
MUL R0.y, R0.w, c[6].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[6].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[5].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[6].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[5];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[6].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[6].x;
ADD R1.x, R1.y, c[5].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[8];
MOV R1.y, c[5];
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[6].y;
MUL R0.x, R0, c[3];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[2].x;
MAD R1.y, R2, c[7].w, R0.x;
MOV R1.x, c[5].y;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
DP3 R0.w, fragment.texcoord[3], fragment.texcoord[3];
ADD R0.y, R1.x, c[8];
ADD R0.x, R0.z, R0;
RSQ R0.w, R0.w;
MUL R1.xyz, R0.w, fragment.texcoord[3];
DP3 R1.x, fragment.texcoord[2], R1;
DP3 R1.y, fragment.texcoord[4], fragment.texcoord[4];
MUL R0.x, R0, R0.y;
MUL R0.xyz, R0.x, c[4];
MUL R0.xyz, R0, c[5].x;
TEX R0.w, fragment.texcoord[4], texture[2], CUBE;
TEX R1.w, R1.y, texture[1], 2D;
MUL R1.y, R1.w, R0.w;
MAX R0.w, R1.x, c[5].y;
MUL R0.xyz, R0, c[0];
MUL R0.w, R0, R1.y;
MUL R0.xyz, R0.w, R0;
MUL result.color.xyz, R0, c[6].x;
MOV result.color.w, c[5].y;
END
# 143 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "POINT_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTextureB0] 2D
SetTexture 2 [_LightTexture0] CUBE
"ps_3_0
; 53 ALU, 7 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_cube s2
def c5, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c6, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c7, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
add r0.x, c4, c4.y
add r0.x, r0, c4.z
mov r0.z, c5.x
mov r0.w, c5.x
mul r1.z, r0.x, c5.y
loop aL, i0
add r0.w, r0, c5.z
mul r0.x, r0.w, c5.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c6.x
mov r0.y, r2.x
mad r0.x, r2.z, c1, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c1, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c1, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c6.y, c6.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c6.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c7.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c5.x
mul r0.x, r0, c7.y
texld r0.x, r0, s0
mul r0.x, r0, c3
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c7.z, r0.x
mov r0.x, c5
texld r0.x, r0, s0
mul r0.w, r0, c2.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c5.z
mul r0.x, r0.z, r0
mul r1.xyz, r0.x, c4
dp3_pp r0.y, v3, v3
rsq_pp r0.y, r0.y
mul_pp r0.xyz, r0.y, v3
dp3_pp r0.y, v2, r0
dp3 r0.x, v4, v4
max_pp r0.y, r0, c5.x
mul_pp r1.xyz, r1, c0
texld r0.w, v4, s2
texld r0.x, r0.x, s1
mul r0.x, r0, r0.w
mul_pp r0.x, r0.y, r0
mul_pp r0.xyz, r0.x, r1
mul_pp oC0.xyz, r0, c6.y
mov_pp oC0.w, c5.x
"
}

SubProgram "gles " {
Keywords { "POINT_COOKIE" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "POINT_COOKIE" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTexture0] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 138 ALU, 18 TEX
PARAM c[9] = { program.local[0..4],
		{ 0.2, 0, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 9.9999997e-05 },
		{ 0.001, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[6].w;
MAD R0.z, R1, c[1].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[1].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[1], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[5].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[1].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[1].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[1].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[6].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[5];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[6].x;
ADD R0.w, R0.z, c[5];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[4], c[4].y;
MUL R2.xyz, fragment.texcoord[1], c[7].x;
ADD R0.w, R1.x, c[4].z;
MUL R0.z, R0.y, c[6].y;
MUL R0.y, R0.w, c[6].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[6].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[5].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[6].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[5];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[6].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[1].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[1].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[1].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[6].x;
ADD R1.x, R1.y, c[5].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[8];
MOV R1.y, c[5];
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[6].y;
MUL R0.x, R0, c[3];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[2].x;
MAD R1.y, R2, c[7].w, R0.x;
MOV R1.x, c[5].y;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[8];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R0.xyz, R0.x, c[4];
MUL R0.xyz, R0, c[5].x;
MOV R1.xyz, fragment.texcoord[3];
DP3 R1.x, fragment.texcoord[2], R1;
MUL R0.xyz, R0, c[0];
TEX R0.w, fragment.texcoord[4], texture[1], 2D;
MAX R1.x, R1, c[5].y;
MUL R0.w, R1.x, R0;
MUL R0.xyz, R0.w, R0;
MUL result.color.xyz, R0, c[6].x;
MOV result.color.w, c[5].y;
END
# 138 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL_COOKIE" }
Vector 0 [_LightColor0]
Float 1 [_Tilt]
Float 2 [_BandsIntensity]
Float 3 [_BandsShift]
Vector 4 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightTexture0] 2D
"ps_3_0
; 49 ALU, 6 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
def c5, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c6, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c7, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xy
add r0.x, c4, c4.y
add r0.x, r0, c4.z
mov r0.z, c5.x
mov r0.w, c5.x
mul r1.z, r0.x, c5.y
loop aL, i0
add r0.w, r0, c5.z
mul r0.x, r0.w, c5.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c6.x
mov r0.y, r2.x
mad r0.x, r2.z, c1, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c1, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c1, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c6.y, c6.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c6.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c7.x, r0
endloop
add r0.x, r2, r2.z
mov_pp r1.xyz, v3
dp3_pp r1.x, v2, r1
mov r0.y, c5.x
mul r0.x, r0, c7.y
texld r0.x, r0, s0
mul r0.x, r0, c3
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c7.z, r0.x
mov r0.x, c5
texld r0.x, r0, s0
mul r0.w, r0, c2.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c5.z
mul r0.x, r0.z, r0
mul r0.xyz, r0.x, c4
mul_pp r0.xyz, r0, c0
texld r0.w, v4, s1
max_pp r1.x, r1, c5
mul_pp r0.w, r1.x, r0
mul_pp r0.xyz, r0.w, r0
mul_pp oC0.xyz, r0, c6.y
mov_pp oC0.w, c5.x
"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL_COOKIE" }
"!!GLES"
}

}
	}
	Pass {
		Name "PREPASS"
		Tags { "LightMode" = "PrePassBase" }
		Fog {Mode Off}
Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 8 to 8
//   d3d9 - ALU: 8 to 8
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [unity_Scale]
Matrix 5 [_Object2World]
"3.0-!!ARBvp1.0
# 8 ALU
PARAM c[10] = { program.local[0],
		state.matrix.mvp,
		program.local[5..9] };
TEMP R0;
MUL R0.xyz, vertex.normal, c[9].w;
DP3 result.texcoord[0].z, R0, c[7];
DP3 result.texcoord[0].y, R0, c[6];
DP3 result.texcoord[0].x, R0, c[5];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 8 instructions, 1 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [unity_Scale]
Matrix 4 [_Object2World]
"vs_3_0
; 8 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_position0 v0
dcl_normal0 v1
mul r0.xyz, v1, c8.w
dp3 o1.z, r0, c6
dp3 o1.y, r0, c5
dp3 o1.x, r0, c4
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_3;
  tmpvar_3 = (tmpvar_2 * (normalize (_glesNormal) * unity_Scale.w));
  tmpvar_1 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
void main ()
{
  lowp vec4 res;
  highp vec3 tmpvar_1;
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c;
  c = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_2;
  tmpvar_2 = (tmpvar_1 * 1.5);
  highp vec2 tmpvar_3;
  tmpvar_3.x = (tmpvar_2.x + (tmpvar_2.y * _Tilt));
  tmpvar_3.y = tmpvar_2.z;
  lowp float tmpvar_4;
  tmpvar_4 = texture2D (_PlasmaTex, tmpvar_3).x;
  cx = tmpvar_4;
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_2.y + (tmpvar_2.z * _Tilt));
  tmpvar_5.y = tmpvar_2.x;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cy = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_2.z + (tmpvar_2.x * _Tilt));
  tmpvar_7.y = tmpvar_2.y;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cz = tmpvar_8;
  highp float tmpvar_9;
  tmpvar_9 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_9;
  if ((tmpvar_9 < 0.0)) {
    features = featureCorrection;
  };
  c = (features * 0.2);
  highp vec3 tmpvar_10;
  tmpvar_10 = (tmpvar_1 * 0.75);
  highp vec2 tmpvar_11;
  tmpvar_11.x = (tmpvar_10.x + (tmpvar_10.y * _Tilt));
  tmpvar_11.y = tmpvar_10.z;
  lowp float tmpvar_12;
  tmpvar_12 = texture2D (_PlasmaTex, tmpvar_11).x;
  cx = tmpvar_12;
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_10.y + (tmpvar_10.z * _Tilt));
  tmpvar_13.y = tmpvar_10.x;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cy = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_10.z + (tmpvar_10.x * _Tilt));
  tmpvar_15.y = tmpvar_10.y;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cz = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_17;
  if ((tmpvar_17 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  highp vec3 tmpvar_18;
  tmpvar_18 = (tmpvar_1 * 0.5);
  highp vec2 tmpvar_19;
  tmpvar_19.x = (tmpvar_18.x + (tmpvar_18.y * _Tilt));
  tmpvar_19.y = tmpvar_18.z;
  lowp float tmpvar_20;
  tmpvar_20 = texture2D (_PlasmaTex, tmpvar_19).x;
  cx = tmpvar_20;
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_18.y + (tmpvar_18.z * _Tilt));
  tmpvar_21.y = tmpvar_18.x;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cy = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_18.z + (tmpvar_18.x * _Tilt));
  tmpvar_23.y = tmpvar_18.y;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cz = tmpvar_24;
  highp float tmpvar_25;
  tmpvar_25 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_25;
  if ((tmpvar_25 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  highp vec3 tmpvar_26;
  tmpvar_26 = (tmpvar_1 * 0.375);
  highp vec2 tmpvar_27;
  tmpvar_27.x = (tmpvar_26.x + (tmpvar_26.y * _Tilt));
  tmpvar_27.y = tmpvar_26.z;
  lowp float tmpvar_28;
  tmpvar_28 = texture2D (_PlasmaTex, tmpvar_27).x;
  cx = tmpvar_28;
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_26.y + (tmpvar_26.z * _Tilt));
  tmpvar_29.y = tmpvar_26.x;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cy = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_26.z + (tmpvar_26.x * _Tilt));
  tmpvar_31.y = tmpvar_26.y;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cz = tmpvar_32;
  highp float tmpvar_33;
  tmpvar_33 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_33;
  if ((tmpvar_33 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  highp vec3 tmpvar_34;
  tmpvar_34 = (tmpvar_1 * 0.3);
  highp vec2 tmpvar_35;
  tmpvar_35.x = (tmpvar_34.x + (tmpvar_34.y * _Tilt));
  tmpvar_35.y = tmpvar_34.z;
  lowp float tmpvar_36;
  tmpvar_36 = texture2D (_PlasmaTex, tmpvar_35).x;
  cx = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_34.y + (tmpvar_34.z * _Tilt));
  tmpvar_37.y = tmpvar_34.x;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cy = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_34.z + (tmpvar_34.x * _Tilt));
  tmpvar_39.y = tmpvar_34.y;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cz = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_41;
  if ((tmpvar_41 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  res.xyz = ((xlv_TEXCOORD0 * 0.5) + 0.5);
  res.w = 0.0;
  gl_FragData[0] = res;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;

uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  mat3 tmpvar_2;
  tmpvar_2[0] = _Object2World[0].xyz;
  tmpvar_2[1] = _Object2World[1].xyz;
  tmpvar_2[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_3;
  tmpvar_3 = (tmpvar_2 * (normalize (_glesNormal) * unity_Scale.w));
  tmpvar_1 = tmpvar_3;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform highp vec4 _Color;
void main ()
{
  lowp vec4 res;
  highp vec3 tmpvar_1;
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c;
  c = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_2;
  tmpvar_2 = (tmpvar_1 * 1.5);
  highp vec2 tmpvar_3;
  tmpvar_3.x = (tmpvar_2.x + (tmpvar_2.y * _Tilt));
  tmpvar_3.y = tmpvar_2.z;
  lowp float tmpvar_4;
  tmpvar_4 = texture2D (_PlasmaTex, tmpvar_3).x;
  cx = tmpvar_4;
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_2.y + (tmpvar_2.z * _Tilt));
  tmpvar_5.y = tmpvar_2.x;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cy = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_2.z + (tmpvar_2.x * _Tilt));
  tmpvar_7.y = tmpvar_2.y;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cz = tmpvar_8;
  highp float tmpvar_9;
  tmpvar_9 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_9;
  if ((tmpvar_9 < 0.0)) {
    features = featureCorrection;
  };
  c = (features * 0.2);
  highp vec3 tmpvar_10;
  tmpvar_10 = (tmpvar_1 * 0.75);
  highp vec2 tmpvar_11;
  tmpvar_11.x = (tmpvar_10.x + (tmpvar_10.y * _Tilt));
  tmpvar_11.y = tmpvar_10.z;
  lowp float tmpvar_12;
  tmpvar_12 = texture2D (_PlasmaTex, tmpvar_11).x;
  cx = tmpvar_12;
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_10.y + (tmpvar_10.z * _Tilt));
  tmpvar_13.y = tmpvar_10.x;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cy = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_10.z + (tmpvar_10.x * _Tilt));
  tmpvar_15.y = tmpvar_10.y;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cz = tmpvar_16;
  highp float tmpvar_17;
  tmpvar_17 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_17;
  if ((tmpvar_17 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  highp vec3 tmpvar_18;
  tmpvar_18 = (tmpvar_1 * 0.5);
  highp vec2 tmpvar_19;
  tmpvar_19.x = (tmpvar_18.x + (tmpvar_18.y * _Tilt));
  tmpvar_19.y = tmpvar_18.z;
  lowp float tmpvar_20;
  tmpvar_20 = texture2D (_PlasmaTex, tmpvar_19).x;
  cx = tmpvar_20;
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_18.y + (tmpvar_18.z * _Tilt));
  tmpvar_21.y = tmpvar_18.x;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cy = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_18.z + (tmpvar_18.x * _Tilt));
  tmpvar_23.y = tmpvar_18.y;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cz = tmpvar_24;
  highp float tmpvar_25;
  tmpvar_25 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_25;
  if ((tmpvar_25 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  highp vec3 tmpvar_26;
  tmpvar_26 = (tmpvar_1 * 0.375);
  highp vec2 tmpvar_27;
  tmpvar_27.x = (tmpvar_26.x + (tmpvar_26.y * _Tilt));
  tmpvar_27.y = tmpvar_26.z;
  lowp float tmpvar_28;
  tmpvar_28 = texture2D (_PlasmaTex, tmpvar_27).x;
  cx = tmpvar_28;
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_26.y + (tmpvar_26.z * _Tilt));
  tmpvar_29.y = tmpvar_26.x;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cy = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_26.z + (tmpvar_26.x * _Tilt));
  tmpvar_31.y = tmpvar_26.y;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cz = tmpvar_32;
  highp float tmpvar_33;
  tmpvar_33 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_33;
  if ((tmpvar_33 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  highp vec3 tmpvar_34;
  tmpvar_34 = (tmpvar_1 * 0.3);
  highp vec2 tmpvar_35;
  tmpvar_35.x = (tmpvar_34.x + (tmpvar_34.y * _Tilt));
  tmpvar_35.y = tmpvar_34.z;
  lowp float tmpvar_36;
  tmpvar_36 = texture2D (_PlasmaTex, tmpvar_35).x;
  cx = tmpvar_36;
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_34.y + (tmpvar_34.z * _Tilt));
  tmpvar_37.y = tmpvar_34.x;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cy = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_34.z + (tmpvar_34.x * _Tilt));
  tmpvar_39.y = tmpvar_34.y;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cz = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_41;
  if ((tmpvar_41 < 0.0)) {
    features = featureCorrection;
  };
  c = (c + (features * 0.2));
  res.xyz = ((xlv_TEXCOORD0 * 0.5) + 0.5);
  res.w = 0.0;
  gl_FragData[0] = res;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 2 to 2, TEX: 0 to 0
//   d3d9 - ALU: 2 to 2, FLOW: 5 to 5
SubProgram "opengl " {
Keywords { }
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 2 ALU, 0 TEX
PARAM c[2] = { program.local[0],
		{ 0, 0.5 } };
MAD result.color.xyz, fragment.texcoord[0], c[1].y, c[1].y;
MOV result.color.w, c[1].x;
END
# 2 instructions, 0 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
"ps_3_0
; 2 ALU, 5 FLOW
defi i0, 5, 1, 1, 0
def c0, 0.50000000, 0.00000000, 0, 0
dcl_texcoord0 v0.xyz
loop aL, i0
endloop
mad_pp oC0.xyz, v0, c0.x, c0.x
mov_pp oC0.w, c0.y
"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

}
	}
	Pass {
		Name "PREPASS"
		Tags { "LightMode" = "PrePassFinal" }
		ZWrite Off
Program "vp" {
// Vertex combos: 6
//   opengl - ALU: 16 to 30
//   d3d9 - ALU: 16 to 30
SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [_ProjectionParams]
Vector 10 [unity_Scale]
Matrix 5 [_Object2World]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
"3.0-!!ARBvp1.0
# 30 ALU
PARAM c[18] = { { 0.5, 1 },
		state.matrix.mvp,
		program.local[5..17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R0.w, c[0].y;
DP3 R1.z, vertex.normal, c[7];
DP3 R1.x, vertex.normal, c[5];
DP3 R1.y, vertex.normal, c[6];
MUL R0.xyz, R1, c[10].w;
MUL R1.w, R0.y, R0.y;
MUL R2, R0.xyzz, R0.yzzx;
DP4 R3.z, R0, c[13];
DP4 R3.y, R0, c[12];
DP4 R3.x, R0, c[11];
MAD R1.w, R0.x, R0.x, -R1;
DP4 R0.z, R2, c[16];
DP4 R0.x, R2, c[14];
DP4 R0.y, R2, c[15];
ADD R4.xyz, R3, R0;
MUL R3.xyz, R1.w, c[17];
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R2.xyz, R0.xyww, c[0].x;
MUL R2.y, R2, c[9].x;
ADD result.texcoord[3].xyz, R4, R3;
ADD result.texcoord[2].xy, R2, R2.z;
MOV result.position, R0;
MOV result.texcoord[2].zw, R0;
MOV result.texcoord[0].xyz, R1;
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 30 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Vector 10 [unity_Scale]
Matrix 4 [_Object2World]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
"vs_3_0
; 30 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c18, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
mov r0.w, c18.y
dp3 r1.z, v1, c6
dp3 r1.x, v1, c4
dp3 r1.y, v1, c5
mul r0.xyz, r1, c10.w
mul r1.w, r0.y, r0.y
mul r2, r0.xyzz, r0.yzzx
dp4 r3.z, r0, c13
dp4 r3.y, r0, c12
dp4 r3.x, r0, c11
mad r1.w, r0.x, r0.x, -r1
dp4 r0.z, r2, c16
dp4 r0.x, r2, c14
dp4 r0.y, r2, c15
add r4.xyz, r3, r0
mul r3.xyz, r1.w, c17
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r2.xyz, r0.xyww, c18.x
mul r2.y, r2, c8.x
add o4.xyz, r4, r3
mad o3.xy, r2.z, c9.zwzw, r2
mov o0, r0
mov o3.zw, r0
mov o1.xyz, r1
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec3 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = (tmpvar_1 * unity_Scale.w);
  mediump vec3 tmpvar_9;
  mediump vec4 normal;
  normal = tmpvar_8;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_10;
  tmpvar_10 = dot (unity_SHAr, normal);
  x1.x = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAg, normal);
  x1.y = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAb, normal);
  x1.z = tmpvar_12;
  mediump vec4 tmpvar_13;
  tmpvar_13 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHBr, tmpvar_13);
  x2.x = tmpvar_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBg, tmpvar_13);
  x2.y = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBb, tmpvar_13);
  x2.z = tmpvar_16;
  mediump float tmpvar_17;
  tmpvar_17 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_17;
  highp vec3 tmpvar_18;
  tmpvar_18 = (unity_SHC.xyz * vC);
  x3 = tmpvar_18;
  tmpvar_9 = ((x1 + x2) + x3);
  tmpvar_2 = tmpvar_9;
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = -(log2 (max (light, vec4(0.001, 0.001, 0.001, 0.001))));
  light = tmpvar_51;
  highp vec3 tmpvar_52;
  tmpvar_52 = (tmpvar_51.xyz + xlv_TEXCOORD3);
  light.xyz = tmpvar_52;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_53;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec3 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = (tmpvar_1 * unity_Scale.w);
  mediump vec3 tmpvar_9;
  mediump vec4 normal;
  normal = tmpvar_8;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_10;
  tmpvar_10 = dot (unity_SHAr, normal);
  x1.x = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAg, normal);
  x1.y = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAb, normal);
  x1.z = tmpvar_12;
  mediump vec4 tmpvar_13;
  tmpvar_13 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHBr, tmpvar_13);
  x2.x = tmpvar_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBg, tmpvar_13);
  x2.y = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBb, tmpvar_13);
  x2.z = tmpvar_16;
  mediump float tmpvar_17;
  tmpvar_17 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_17;
  highp vec3 tmpvar_18;
  tmpvar_18 = (unity_SHC.xyz * vC);
  x3 = tmpvar_18;
  tmpvar_9 = ((x1 + x2) + x3);
  tmpvar_2 = tmpvar_9;
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = -(log2 (max (light, vec4(0.001, 0.001, 0.001, 0.001))));
  light = tmpvar_51;
  highp vec3 tmpvar_52;
  tmpvar_52 = (tmpvar_51.xyz + xlv_TEXCOORD3);
  light.xyz = tmpvar_52;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_53;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Vector 13 [_ProjectionParams]
Matrix 9 [_Object2World]
Vector 14 [unity_LightmapST]
Vector 15 [unity_ShadowFadeCenterAndType]
"3.0-!!ARBvp1.0
# 23 ALU
PARAM c[16] = { { 0.5, 1 },
		state.matrix.modelview[0],
		state.matrix.mvp,
		program.local[9..15] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[8];
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
MUL R1.xyz, R0.xyww, c[0].x;
MOV result.position, R0;
MUL R1.y, R1, c[13].x;
MOV result.texcoord[2].zw, R0;
DP4 R0.x, vertex.position, c[9];
DP4 R0.y, vertex.position, c[10];
DP4 R0.z, vertex.position, c[11];
ADD result.texcoord[2].xy, R1, R1.z;
ADD R1.xyz, R0, -c[15];
MOV result.texcoord[1].xyz, R0;
MOV R0.x, c[0].y;
ADD R0.y, R0.x, -c[15].w;
DP4 R0.x, vertex.position, c[3];
MUL result.texcoord[4].xyz, R1, c[15].w;
MAD result.texcoord[3].xy, vertex.texcoord[1], c[14], c[14].zwzw;
MUL result.texcoord[4].w, -R0.x, R0.y;
DP3 result.texcoord[0].z, vertex.normal, c[11];
DP3 result.texcoord[0].y, vertex.normal, c[10];
DP3 result.texcoord[0].x, vertex.normal, c[9];
END
# 23 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_modelview0]
Matrix 4 [glstate_matrix_mvp]
Vector 12 [_ProjectionParams]
Vector 13 [_ScreenParams]
Matrix 8 [_Object2World]
Vector 14 [unity_LightmapST]
Vector 15 [unity_ShadowFadeCenterAndType]
"vs_3_0
; 23 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c16, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dp4 r0.w, v0, c7
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mul r1.xyz, r0.xyww, c16.x
mov o0, r0
mul r1.y, r1, c12.x
mov o3.zw, r0
dp4 r0.x, v0, c8
dp4 r0.y, v0, c9
dp4 r0.z, v0, c10
mad o3.xy, r1.z, c13.zwzw, r1
add r1.xyz, r0, -c15
mov o2.xyz, r0
mov r0.x, c15.w
add r0.y, c16, -r0.x
dp4 r0.x, v0, c2
mul o5.xyz, r1, c15.w
mad o4.xy, v2, c14, c14.zwzw
mul o5.w, -r0.x, r0.y
dp3 o1.z, v1, c10
dp3 o1.y, v1, c9
dp3 o1.x, v1, c8
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 unity_LightmapST;


uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  tmpvar_2.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_2.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec3 lmIndirect;
  mediump vec3 lmFull;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = -(log2 (max (light, vec4(0.001, 0.001, 0.001, 0.001))));
  light = tmpvar_51;
  lowp vec3 tmpvar_52;
  tmpvar_52 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz);
  lmFull = tmpvar_52;
  lowp vec3 tmpvar_53;
  tmpvar_53 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD3).xyz);
  lmIndirect = tmpvar_53;
  highp vec3 tmpvar_54;
  tmpvar_54 = vec3(clamp (((length (xlv_TEXCOORD4) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0));
  light.xyz = (tmpvar_51.xyz + mix (lmIndirect, lmFull, tmpvar_54));
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_55;
  tmpvar_55 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_55;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 unity_LightmapST;


uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  tmpvar_2.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_2.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec3 lmIndirect;
  mediump vec3 lmFull;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = -(log2 (max (light, vec4(0.001, 0.001, 0.001, 0.001))));
  light = tmpvar_51;
  lowp vec4 tmpvar_52;
  tmpvar_52 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  lowp vec3 tmpvar_53;
  tmpvar_53 = ((8.0 * tmpvar_52.w) * tmpvar_52.xyz);
  lmFull = tmpvar_53;
  lowp vec4 tmpvar_54;
  tmpvar_54 = texture2D (unity_LightmapInd, xlv_TEXCOORD3);
  lowp vec3 tmpvar_55;
  tmpvar_55 = ((8.0 * tmpvar_54.w) * tmpvar_54.xyz);
  lmIndirect = tmpvar_55;
  highp vec3 tmpvar_56;
  tmpvar_56 = vec3(clamp (((length (xlv_TEXCOORD4) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0));
  light.xyz = (tmpvar_51.xyz + mix (lmIndirect, lmFull, tmpvar_56));
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_57;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Vector 9 [_ProjectionParams]
Matrix 5 [_Object2World]
Vector 10 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 16 ALU
PARAM c[11] = { { 0.5 },
		state.matrix.mvp,
		program.local[5..10] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R1.xyz, R0.xyww, c[0].x;
MUL R1.y, R1, c[9].x;
ADD result.texcoord[2].xy, R1, R1.z;
MOV result.position, R0;
MOV result.texcoord[2].zw, R0;
MAD result.texcoord[3].xy, vertex.texcoord[1], c[10], c[10].zwzw;
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 16 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Matrix 4 [_Object2World]
Vector 10 [unity_LightmapST]
"vs_3_0
; 16 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c11, 0.50000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r1.xyz, r0.xyww, c11.x
mul r1.y, r1, c8.x
mad o3.xy, r1.z, c9.zwzw, r1
mov o0, r0
mov o3.zw, r0
mad o4.xy, v2, c10, c10.zwzw
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_51;
  tmpvar_51 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz);
  lm_i0 = tmpvar_51;
  mediump vec4 tmpvar_52;
  tmpvar_52.w = 0.0;
  tmpvar_52.xyz = lm_i0;
  mediump vec4 tmpvar_53;
  tmpvar_53 = (-(log2 (max (light, vec4(0.001, 0.001, 0.001, 0.001)))) + tmpvar_52);
  light = tmpvar_53;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_54;
  tmpvar_54 = (tmpvar_3 * tmpvar_53.xyz);
  c_i0_i1.xyz = tmpvar_54;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  lowp vec4 tmpvar_51;
  tmpvar_51 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_52;
  tmpvar_52 = ((8.0 * tmpvar_51.w) * tmpvar_51.xyz);
  lm_i0 = tmpvar_52;
  mediump vec4 tmpvar_53;
  tmpvar_53.w = 0.0;
  tmpvar_53.xyz = lm_i0;
  mediump vec4 tmpvar_54;
  tmpvar_54 = (-(log2 (max (light, vec4(0.001, 0.001, 0.001, 0.001)))) + tmpvar_53);
  light = tmpvar_54;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_55;
  tmpvar_55 = (tmpvar_3 * tmpvar_54.xyz);
  c_i0_i1.xyz = tmpvar_55;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Vector 9 [_ProjectionParams]
Vector 10 [unity_Scale]
Matrix 5 [_Object2World]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
"3.0-!!ARBvp1.0
# 30 ALU
PARAM c[18] = { { 0.5, 1 },
		state.matrix.mvp,
		program.local[5..17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R0.w, c[0].y;
DP3 R1.z, vertex.normal, c[7];
DP3 R1.x, vertex.normal, c[5];
DP3 R1.y, vertex.normal, c[6];
MUL R0.xyz, R1, c[10].w;
MUL R1.w, R0.y, R0.y;
MUL R2, R0.xyzz, R0.yzzx;
DP4 R3.z, R0, c[13];
DP4 R3.y, R0, c[12];
DP4 R3.x, R0, c[11];
MAD R1.w, R0.x, R0.x, -R1;
DP4 R0.z, R2, c[16];
DP4 R0.x, R2, c[14];
DP4 R0.y, R2, c[15];
ADD R4.xyz, R3, R0;
MUL R3.xyz, R1.w, c[17];
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R2.xyz, R0.xyww, c[0].x;
MUL R2.y, R2, c[9].x;
ADD result.texcoord[3].xyz, R4, R3;
ADD result.texcoord[2].xy, R2, R2.z;
MOV result.position, R0;
MOV result.texcoord[2].zw, R0;
MOV result.texcoord[0].xyz, R1;
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 30 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Vector 10 [unity_Scale]
Matrix 4 [_Object2World]
Vector 11 [unity_SHAr]
Vector 12 [unity_SHAg]
Vector 13 [unity_SHAb]
Vector 14 [unity_SHBr]
Vector 15 [unity_SHBg]
Vector 16 [unity_SHBb]
Vector 17 [unity_SHC]
"vs_3_0
; 30 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c18, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
mov r0.w, c18.y
dp3 r1.z, v1, c6
dp3 r1.x, v1, c4
dp3 r1.y, v1, c5
mul r0.xyz, r1, c10.w
mul r1.w, r0.y, r0.y
mul r2, r0.xyzz, r0.yzzx
dp4 r3.z, r0, c13
dp4 r3.y, r0, c12
dp4 r3.x, r0, c11
mad r1.w, r0.x, r0.x, -r1
dp4 r0.z, r2, c16
dp4 r0.x, r2, c14
dp4 r0.y, r2, c15
add r4.xyz, r3, r0
mul r3.xyz, r1.w, c17
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r2.xyz, r0.xyww, c18.x
mul r2.y, r2, c8.x
add o4.xyz, r4, r3
mad o3.xy, r2.z, c9.zwzw, r2
mov o0, r0
mov o3.zw, r0
mov o1.xyz, r1
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec3 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = (tmpvar_1 * unity_Scale.w);
  mediump vec3 tmpvar_9;
  mediump vec4 normal;
  normal = tmpvar_8;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_10;
  tmpvar_10 = dot (unity_SHAr, normal);
  x1.x = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAg, normal);
  x1.y = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAb, normal);
  x1.z = tmpvar_12;
  mediump vec4 tmpvar_13;
  tmpvar_13 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHBr, tmpvar_13);
  x2.x = tmpvar_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBg, tmpvar_13);
  x2.y = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBb, tmpvar_13);
  x2.z = tmpvar_16;
  mediump float tmpvar_17;
  tmpvar_17 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_17;
  highp vec3 tmpvar_18;
  tmpvar_18 = (unity_SHC.xyz * vC);
  x3 = tmpvar_18;
  tmpvar_9 = ((x1 + x2) + x3);
  tmpvar_2 = tmpvar_9;
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = max (light, vec4(0.001, 0.001, 0.001, 0.001));
  light = tmpvar_51;
  highp vec3 tmpvar_52;
  tmpvar_52 = (tmpvar_51.xyz + xlv_TEXCOORD3);
  light.xyz = tmpvar_52;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_53;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_Scale;
uniform highp vec4 unity_SHC;
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec3 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = (tmpvar_1 * unity_Scale.w);
  mediump vec3 tmpvar_9;
  mediump vec4 normal;
  normal = tmpvar_8;
  mediump vec3 x3;
  highp float vC;
  mediump vec3 x2;
  mediump vec3 x1;
  highp float tmpvar_10;
  tmpvar_10 = dot (unity_SHAr, normal);
  x1.x = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = dot (unity_SHAg, normal);
  x1.y = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = dot (unity_SHAb, normal);
  x1.z = tmpvar_12;
  mediump vec4 tmpvar_13;
  tmpvar_13 = (normal.xyzz * normal.yzzx);
  highp float tmpvar_14;
  tmpvar_14 = dot (unity_SHBr, tmpvar_13);
  x2.x = tmpvar_14;
  highp float tmpvar_15;
  tmpvar_15 = dot (unity_SHBg, tmpvar_13);
  x2.y = tmpvar_15;
  highp float tmpvar_16;
  tmpvar_16 = dot (unity_SHBb, tmpvar_13);
  x2.z = tmpvar_16;
  mediump float tmpvar_17;
  tmpvar_17 = ((normal.x * normal.x) - (normal.y * normal.y));
  vC = tmpvar_17;
  highp vec3 tmpvar_18;
  tmpvar_18 = (unity_SHC.xyz * vC);
  x3 = tmpvar_18;
  tmpvar_9 = ((x1 + x2) + x3);
  tmpvar_2 = tmpvar_9;
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = max (light, vec4(0.001, 0.001, 0.001, 0.001));
  light = tmpvar_51;
  highp vec3 tmpvar_52;
  tmpvar_52 = (tmpvar_51.xyz + xlv_TEXCOORD3);
  light.xyz = tmpvar_52;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_53;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Vector 13 [_ProjectionParams]
Matrix 9 [_Object2World]
Vector 14 [unity_LightmapST]
Vector 15 [unity_ShadowFadeCenterAndType]
"3.0-!!ARBvp1.0
# 23 ALU
PARAM c[16] = { { 0.5, 1 },
		state.matrix.modelview[0],
		state.matrix.mvp,
		program.local[9..15] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[8];
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
MUL R1.xyz, R0.xyww, c[0].x;
MOV result.position, R0;
MUL R1.y, R1, c[13].x;
MOV result.texcoord[2].zw, R0;
DP4 R0.x, vertex.position, c[9];
DP4 R0.y, vertex.position, c[10];
DP4 R0.z, vertex.position, c[11];
ADD result.texcoord[2].xy, R1, R1.z;
ADD R1.xyz, R0, -c[15];
MOV result.texcoord[1].xyz, R0;
MOV R0.x, c[0].y;
ADD R0.y, R0.x, -c[15].w;
DP4 R0.x, vertex.position, c[3];
MUL result.texcoord[4].xyz, R1, c[15].w;
MAD result.texcoord[3].xy, vertex.texcoord[1], c[14], c[14].zwzw;
MUL result.texcoord[4].w, -R0.x, R0.y;
DP3 result.texcoord[0].z, vertex.normal, c[11];
DP3 result.texcoord[0].y, vertex.normal, c[10];
DP3 result.texcoord[0].x, vertex.normal, c[9];
END
# 23 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_modelview0]
Matrix 4 [glstate_matrix_mvp]
Vector 12 [_ProjectionParams]
Vector 13 [_ScreenParams]
Matrix 8 [_Object2World]
Vector 14 [unity_LightmapST]
Vector 15 [unity_ShadowFadeCenterAndType]
"vs_3_0
; 23 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c16, 0.50000000, 1.00000000, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dp4 r0.w, v0, c7
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mul r1.xyz, r0.xyww, c16.x
mov o0, r0
mul r1.y, r1, c12.x
mov o3.zw, r0
dp4 r0.x, v0, c8
dp4 r0.y, v0, c9
dp4 r0.z, v0, c10
mad o3.xy, r1.z, c13.zwzw, r1
add r1.xyz, r0, -c15
mov o2.xyz, r0
mov r0.x, c15.w
add r0.y, c16, -r0.x
dp4 r0.x, v0, c2
mul o5.xyz, r1, c15.w
mad o4.xy, v2, c14, c14.zwzw
mul o5.w, -r0.x, r0.y
dp3 o1.z, v1, c10
dp3 o1.y, v1, c9
dp3 o1.x, v1, c8
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 unity_LightmapST;


uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  tmpvar_2.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_2.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec3 lmIndirect;
  mediump vec3 lmFull;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = max (light, vec4(0.001, 0.001, 0.001, 0.001));
  light = tmpvar_51;
  lowp vec3 tmpvar_52;
  tmpvar_52 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz);
  lmFull = tmpvar_52;
  lowp vec3 tmpvar_53;
  tmpvar_53 = (2.0 * texture2D (unity_LightmapInd, xlv_TEXCOORD3).xyz);
  lmIndirect = tmpvar_53;
  highp vec3 tmpvar_54;
  tmpvar_54 = vec3(clamp (((length (xlv_TEXCOORD4) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0));
  light.xyz = (tmpvar_51.xyz + mix (lmIndirect, lmFull, tmpvar_54));
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_55;
  tmpvar_55 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_55;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;
#define gl_ModelViewMatrix glstate_matrix_modelview0
uniform mat4 glstate_matrix_modelview0;

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp vec4 unity_LightmapST;


uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  highp vec4 tmpvar_3;
  tmpvar_3 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_4;
  tmpvar_4[0] = _Object2World[0].xyz;
  tmpvar_4[1] = _Object2World[1].xyz;
  tmpvar_4[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_5;
  tmpvar_5 = (tmpvar_4 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_5;
  highp vec4 o_i0;
  highp vec4 tmpvar_6;
  tmpvar_6 = (tmpvar_3 * 0.5);
  o_i0 = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = tmpvar_6.x;
  tmpvar_7.y = (tmpvar_6.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_7 + tmpvar_6.w);
  o_i0.zw = tmpvar_3.zw;
  tmpvar_2.xyz = (((_Object2World * _glesVertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w);
  tmpvar_2.w = (-((gl_ModelViewMatrix * _glesVertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w));
  gl_Position = tmpvar_3;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  xlv_TEXCOORD4 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD4;
varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_LightmapInd;
uniform highp vec4 unity_LightmapFade;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec3 lmIndirect;
  mediump vec3 lmFull;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec4 tmpvar_51;
  tmpvar_51 = max (light, vec4(0.001, 0.001, 0.001, 0.001));
  light = tmpvar_51;
  lowp vec4 tmpvar_52;
  tmpvar_52 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  lowp vec3 tmpvar_53;
  tmpvar_53 = ((8.0 * tmpvar_52.w) * tmpvar_52.xyz);
  lmFull = tmpvar_53;
  lowp vec4 tmpvar_54;
  tmpvar_54 = texture2D (unity_LightmapInd, xlv_TEXCOORD3);
  lowp vec3 tmpvar_55;
  tmpvar_55 = ((8.0 * tmpvar_54.w) * tmpvar_54.xyz);
  lmIndirect = tmpvar_55;
  highp vec3 tmpvar_56;
  tmpvar_56 = vec3(clamp (((length (xlv_TEXCOORD4) * unity_LightmapFade.z) + unity_LightmapFade.w), 0.0, 1.0));
  light.xyz = (tmpvar_51.xyz + mix (lmIndirect, lmFull, tmpvar_56));
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_3 * light.xyz);
  c_i0_i1.xyz = tmpvar_57;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Vector 9 [_ProjectionParams]
Matrix 5 [_Object2World]
Vector 10 [unity_LightmapST]
"3.0-!!ARBvp1.0
# 16 ALU
PARAM c[11] = { { 0.5 },
		state.matrix.mvp,
		program.local[5..10] };
TEMP R0;
TEMP R1;
DP4 R0.w, vertex.position, c[4];
DP4 R0.z, vertex.position, c[3];
DP4 R0.x, vertex.position, c[1];
DP4 R0.y, vertex.position, c[2];
MUL R1.xyz, R0.xyww, c[0].x;
MUL R1.y, R1, c[9].x;
ADD result.texcoord[2].xy, R1, R1.z;
MOV result.position, R0;
MOV result.texcoord[2].zw, R0;
MAD result.texcoord[3].xy, vertex.texcoord[1], c[10], c[10].zwzw;
DP3 result.texcoord[0].z, vertex.normal, c[7];
DP3 result.texcoord[0].y, vertex.normal, c[6];
DP3 result.texcoord[0].x, vertex.normal, c[5];
DP4 result.texcoord[1].z, vertex.position, c[7];
DP4 result.texcoord[1].y, vertex.position, c[6];
DP4 result.texcoord[1].x, vertex.position, c[5];
END
# 16 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_ProjectionParams]
Vector 9 [_ScreenParams]
Matrix 4 [_Object2World]
Vector 10 [unity_LightmapST]
"vs_3_0
; 16 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
def c11, 0.50000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord1 v2
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r1.xyz, r0.xyww, c11.x
mul r1.y, r1, c8.x
mad o3.xy, r1.z, c9.zwzw, r1
mov o0, r0
mov o3.zw, r0
mad o4.xy, v2, c10, c10.zwzw
dp3 o1.z, v1, c6
dp3 o1.y, v1, c5
dp3 o1.x, v1, c4
dp4 o2.z, v0, c6
dp4 o2.y, v0, c5
dp4 o2.x, v0, c4
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_51;
  tmpvar_51 = (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD3).xyz);
  lm_i0 = tmpvar_51;
  mediump vec4 tmpvar_52;
  tmpvar_52.w = 0.0;
  tmpvar_52.xyz = lm_i0;
  mediump vec4 tmpvar_53;
  tmpvar_53 = (max (light, vec4(0.001, 0.001, 0.001, 0.001)) + tmpvar_52);
  light = tmpvar_53;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_54;
  tmpvar_54 = (tmpvar_3 * tmpvar_53.xyz);
  c_i0_i1.xyz = tmpvar_54;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform highp vec4 unity_LightmapST;

uniform highp vec4 _ProjectionParams;
uniform highp mat4 _Object2World;
attribute vec4 _glesMultiTexCoord1;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  lowp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * _glesVertex);
  mat3 tmpvar_3;
  tmpvar_3[0] = _Object2World[0].xyz;
  tmpvar_3[1] = _Object2World[1].xyz;
  tmpvar_3[2] = _Object2World[2].xyz;
  highp vec3 tmpvar_4;
  tmpvar_4 = (tmpvar_3 * normalize (_glesNormal));
  tmpvar_1 = tmpvar_4;
  highp vec4 o_i0;
  highp vec4 tmpvar_5;
  tmpvar_5 = (tmpvar_2 * 0.5);
  o_i0 = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6.x = tmpvar_5.x;
  tmpvar_6.y = (tmpvar_5.y * _ProjectionParams.x);
  o_i0.xy = (tmpvar_6 + tmpvar_5.w);
  o_i0.zw = tmpvar_2.zw;
  gl_Position = tmpvar_2;
  xlv_TEXCOORD0 = tmpvar_1;
  xlv_TEXCOORD1 = (_Object2World * _glesVertex).xyz;
  xlv_TEXCOORD2 = o_i0;
  xlv_TEXCOORD3 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD3;
varying highp vec4 xlv_TEXCOORD2;
varying highp vec3 xlv_TEXCOORD1;
varying lowp vec3 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform highp float _Tilt;
uniform sampler2D _PlasmaTex;
uniform sampler2D _LightBuffer;
uniform highp vec4 _Color;
uniform highp float _BandsShift;
uniform highp float _BandsIntensity;
void main ()
{
  lowp vec4 tmpvar_1;
  mediump vec4 c;
  mediump vec4 light;
  highp vec3 tmpvar_2;
  tmpvar_2 = xlv_TEXCOORD0;
  lowp vec3 tmpvar_3;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  highp float features;
  highp float cz;
  highp float cy;
  highp float cx;
  highp float featureCorrection;
  highp float c_i0;
  c_i0 = 0.0;
  featureCorrection = (((_Color.x + _Color.y) + _Color.z) * 0.33);
  highp vec3 tmpvar_4;
  tmpvar_4 = (xlv_TEXCOORD1 * 1.5);
  highp vec2 tmpvar_5;
  tmpvar_5.x = (tmpvar_4.x + (tmpvar_4.y * _Tilt));
  tmpvar_5.y = tmpvar_4.z;
  lowp float tmpvar_6;
  tmpvar_6 = texture2D (_PlasmaTex, tmpvar_5).x;
  cx = tmpvar_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = (tmpvar_4.y + (tmpvar_4.z * _Tilt));
  tmpvar_7.y = tmpvar_4.x;
  lowp float tmpvar_8;
  tmpvar_8 = texture2D (_PlasmaTex, tmpvar_7).x;
  cy = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = (tmpvar_4.z + (tmpvar_4.x * _Tilt));
  tmpvar_9.y = tmpvar_4.y;
  lowp float tmpvar_10;
  tmpvar_10 = texture2D (_PlasmaTex, tmpvar_9).x;
  cz = tmpvar_10;
  highp float tmpvar_11;
  tmpvar_11 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_11;
  if ((tmpvar_11 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (features * 0.2);
  highp vec3 tmpvar_12;
  tmpvar_12 = (xlv_TEXCOORD1 * 0.75);
  highp vec2 tmpvar_13;
  tmpvar_13.x = (tmpvar_12.x + (tmpvar_12.y * _Tilt));
  tmpvar_13.y = tmpvar_12.z;
  lowp float tmpvar_14;
  tmpvar_14 = texture2D (_PlasmaTex, tmpvar_13).x;
  cx = tmpvar_14;
  highp vec2 tmpvar_15;
  tmpvar_15.x = (tmpvar_12.y + (tmpvar_12.z * _Tilt));
  tmpvar_15.y = tmpvar_12.x;
  lowp float tmpvar_16;
  tmpvar_16 = texture2D (_PlasmaTex, tmpvar_15).x;
  cy = tmpvar_16;
  highp vec2 tmpvar_17;
  tmpvar_17.x = (tmpvar_12.z + (tmpvar_12.x * _Tilt));
  tmpvar_17.y = tmpvar_12.y;
  lowp float tmpvar_18;
  tmpvar_18 = texture2D (_PlasmaTex, tmpvar_17).x;
  cz = tmpvar_18;
  highp float tmpvar_19;
  tmpvar_19 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_19;
  if ((tmpvar_19 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_20;
  tmpvar_20 = (xlv_TEXCOORD1 * 0.5);
  highp vec2 tmpvar_21;
  tmpvar_21.x = (tmpvar_20.x + (tmpvar_20.y * _Tilt));
  tmpvar_21.y = tmpvar_20.z;
  lowp float tmpvar_22;
  tmpvar_22 = texture2D (_PlasmaTex, tmpvar_21).x;
  cx = tmpvar_22;
  highp vec2 tmpvar_23;
  tmpvar_23.x = (tmpvar_20.y + (tmpvar_20.z * _Tilt));
  tmpvar_23.y = tmpvar_20.x;
  lowp float tmpvar_24;
  tmpvar_24 = texture2D (_PlasmaTex, tmpvar_23).x;
  cy = tmpvar_24;
  highp vec2 tmpvar_25;
  tmpvar_25.x = (tmpvar_20.z + (tmpvar_20.x * _Tilt));
  tmpvar_25.y = tmpvar_20.y;
  lowp float tmpvar_26;
  tmpvar_26 = texture2D (_PlasmaTex, tmpvar_25).x;
  cz = tmpvar_26;
  highp float tmpvar_27;
  tmpvar_27 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_27;
  if ((tmpvar_27 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_28;
  tmpvar_28 = (xlv_TEXCOORD1 * 0.375);
  highp vec2 tmpvar_29;
  tmpvar_29.x = (tmpvar_28.x + (tmpvar_28.y * _Tilt));
  tmpvar_29.y = tmpvar_28.z;
  lowp float tmpvar_30;
  tmpvar_30 = texture2D (_PlasmaTex, tmpvar_29).x;
  cx = tmpvar_30;
  highp vec2 tmpvar_31;
  tmpvar_31.x = (tmpvar_28.y + (tmpvar_28.z * _Tilt));
  tmpvar_31.y = tmpvar_28.x;
  lowp float tmpvar_32;
  tmpvar_32 = texture2D (_PlasmaTex, tmpvar_31).x;
  cy = tmpvar_32;
  highp vec2 tmpvar_33;
  tmpvar_33.x = (tmpvar_28.z + (tmpvar_28.x * _Tilt));
  tmpvar_33.y = tmpvar_28.y;
  lowp float tmpvar_34;
  tmpvar_34 = texture2D (_PlasmaTex, tmpvar_33).x;
  cz = tmpvar_34;
  highp float tmpvar_35;
  tmpvar_35 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_35;
  if ((tmpvar_35 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec3 tmpvar_36;
  tmpvar_36 = (xlv_TEXCOORD1 * 0.3);
  highp vec2 tmpvar_37;
  tmpvar_37.x = (tmpvar_36.x + (tmpvar_36.y * _Tilt));
  tmpvar_37.y = tmpvar_36.z;
  lowp float tmpvar_38;
  tmpvar_38 = texture2D (_PlasmaTex, tmpvar_37).x;
  cx = tmpvar_38;
  highp vec2 tmpvar_39;
  tmpvar_39.x = (tmpvar_36.y + (tmpvar_36.z * _Tilt));
  tmpvar_39.y = tmpvar_36.x;
  lowp float tmpvar_40;
  tmpvar_40 = texture2D (_PlasmaTex, tmpvar_39).x;
  cy = tmpvar_40;
  highp vec2 tmpvar_41;
  tmpvar_41.x = (tmpvar_36.z + (tmpvar_36.x * _Tilt));
  tmpvar_41.y = tmpvar_36.y;
  lowp float tmpvar_42;
  tmpvar_42 = texture2D (_PlasmaTex, tmpvar_41).x;
  cz = tmpvar_42;
  highp float tmpvar_43;
  tmpvar_43 = ((mix (cx, cy, cz) + smoothstep (cx, cy, cz)) * 0.25);
  features = tmpvar_43;
  if ((tmpvar_43 < 0.0)) {
    features = featureCorrection;
  };
  c_i0 = (c_i0 + (features * 0.2));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = ((tmpvar_36.x + tmpvar_36.z) * 0.001);
  lowp vec4 tmpvar_45;
  tmpvar_45 = texture2D (_PlasmaTex, tmpvar_44);
  highp float tmpvar_46;
  tmpvar_46 = (clamp ((abs (tmpvar_2.x) + abs (tmpvar_2.z)), 0.0, 1.0) * _BandsIntensity);
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = ((tmpvar_36.y * 0.0001) + (tmpvar_45.x * _BandsShift));
  lowp vec4 tmpvar_48;
  tmpvar_48 = texture2D (_PlasmaTex, tmpvar_47);
  highp vec3 tmpvar_49;
  tmpvar_49 = ((c_i0 * ((tmpvar_48.x * tmpvar_46) + (1.0 - tmpvar_46))) * _Color.xyz);
  tmpvar_3 = tmpvar_49;
  lowp vec4 tmpvar_50;
  tmpvar_50 = texture2DProj (_LightBuffer, xlv_TEXCOORD2);
  light = tmpvar_50;
  lowp vec4 tmpvar_51;
  tmpvar_51 = texture2D (unity_Lightmap, xlv_TEXCOORD3);
  mediump vec3 lm_i0;
  lowp vec3 tmpvar_52;
  tmpvar_52 = ((8.0 * tmpvar_51.w) * tmpvar_51.xyz);
  lm_i0 = tmpvar_52;
  mediump vec4 tmpvar_53;
  tmpvar_53.w = 0.0;
  tmpvar_53.xyz = lm_i0;
  mediump vec4 tmpvar_54;
  tmpvar_54 = (max (light, vec4(0.001, 0.001, 0.001, 0.001)) + tmpvar_53);
  light = tmpvar_54;
  lowp vec4 c_i0_i1;
  mediump vec3 tmpvar_55;
  tmpvar_55 = (tmpvar_3 * tmpvar_54.xyz);
  c_i0_i1.xyz = tmpvar_55;
  c_i0_i1.w = 1.0;
  c = c_i0_i1;
  tmpvar_1 = c;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 6
//   opengl - ALU: 133 to 147, TEX: 18 to 20
//   d3d9 - ALU: 44 to 56, TEX: 6 to 8, FLOW: 5 to 5
SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 136 ALU, 18 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[5].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[5].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
ADD R0.x, R0.z, R0;
MUL R0.w, R0.x, R0.y;
TXP R0.xyz, fragment.texcoord[2], texture[1], 2D;
MUL R1.xyz, R0.w, c[3];
LG2 R0.x, R0.x;
LG2 R0.z, R0.z;
LG2 R0.y, R0.y;
ADD R0.xyz, -R0, fragment.texcoord[3];
MUL R1.xyz, R1, c[4].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[4].y;
END
# 136 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
"ps_3_0
; 47 ALU, 6 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.z, c4.x
mov r0.w, c4.x
mul r1.z, r0.x, c4.y
loop aL, i0
add r0.w, r0, c4.z
mul r0.x, r0.w, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c6.x, r0
endloop
add r0.x, r2, r2.z
texldp r1.xyz, v2, s1
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.w, r0, c1.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c4.z
mul r0.w, r0.z, r0.x
log_pp r0.x, r1.x
log_pp r0.z, r1.z
log_pp r0.y, r1.y
add_pp r0.xyz, -r0, v3
mul r1.xyz, r0.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
Vector 4 [unity_LightmapFade]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
SetTexture 3 [unity_LightmapInd] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 147 ALU, 20 TEX
PARAM c[9] = { program.local[0..4],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[6].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[5].z;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
RCP R1.z, R1.y;
MUL_SAT R2.y, R1.w, R1.z;
MAD R0.x, R0, R1.y, R1;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R2.z, R0.y, c[0].x, R0.w;
ADD R1.z, -R2.x, R3.x;
MOV R2.w, R0.z;
TEX R3.x, R2.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[6].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R1.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[5];
MAD R1.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[6].x;
MUL R0.x, R0.y, R0.y;
MAD R0.y, R3.x, R1.z, R2.x;
MUL R2.xyz, fragment.texcoord[1], c[7].x;
ADD R0.z, R0, c[5].w;
MAD R0.x, R0, R0.z, R0.y;
ADD R0.w, c[3].x, c[3].y;
ADD R0.y, R0.w, c[3].z;
MUL R0.y, R0, c[6].z;
MUL R0.x, R0, c[6].y;
CMP R0.z, R0.x, R0.y, R0.x;
MUL R0.x, R1, c[6].y;
CMP R0.w, R0.x, R0.y, R0.x;
ADD R0.z, R0, R0.w;
MOV R1.y, R2.x;
MAD R1.x, R2.z, c[0], R2.y;
TEX R1.x, R1, texture[0], 2D;
MOV R1.w, R2.z;
MAD R1.z, R2.y, c[0].x, R2.x;
TEX R0.x, R1.zwzw, texture[0], 2D;
ADD R1.y, -R0.x, R1.x;
MOV R1.w, R2.y;
MAD R1.z, R2.x, c[0].x, R2;
TEX R1.x, R1.zwzw, texture[0], 2D;
ADD R1.w, R1.x, -R0.x;
RCP R1.z, R1.y;
MUL_SAT R1.z, R1.w, R1;
MUL R2.xyz, fragment.texcoord[1], c[7].y;
MUL R0.w, R1.z, R1.z;
MAD R0.x, R1, R1.y, R0;
MUL R1.z, -R1, c[6].x;
ADD R1.x, R1.z, c[5].w;
MAD R0.x, R0.w, R1, R0;
MUL R0.w, R0.x, c[6].y;
CMP R0.w, R0, R0.y, R0;
MOV R1.y, R2.x;
MAD R1.x, R2.z, c[0], R2.y;
TEX R1.x, R1, texture[0], 2D;
MOV R1.w, R2.z;
MAD R1.z, R2.y, c[0].x, R2.x;
TEX R0.x, R1.zwzw, texture[0], 2D;
ADD R1.y, -R0.x, R1.x;
MOV R1.w, R2.y;
MAD R1.z, R2.x, c[0].x, R2;
TEX R1.x, R1.zwzw, texture[0], 2D;
ADD R1.w, R1.x, -R0.x;
RCP R1.z, R1.y;
MUL_SAT R1.z, R1.w, R1;
MUL R1.w, R1.z, R1.z;
MAD R0.x, R1, R1.y, R0;
MUL R1.z, -R1, c[6].x;
ADD R1.x, R1.z, c[5].w;
MAD R0.x, R1.w, R1, R0;
MUL R0.x, R0, c[6].y;
MUL R2.xyz, fragment.texcoord[1], c[7].z;
ADD R1.y, R0.z, R0.w;
CMP R1.z, R0.x, R0.y, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
ADD R0.z, R1.y, R1;
MUL R1.y, R0.w, R0.w;
MUL R0.w, -R0, c[6].x;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[5];
MAD R0.w, R1.y, R0, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[8].y;
MOV R1.y, c[7].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[6].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[8].x, R0.x;
MOV R1.x, c[7].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[5];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R2.xyz, R0.x, c[3];
TEX R0, fragment.texcoord[3], texture[3], 2D;
MUL R0.xyz, R0.w, R0;
TEX R1, fragment.texcoord[3], texture[2], 2D;
DP4 R0.w, fragment.texcoord[4], fragment.texcoord[4];
RSQ R0.w, R0.w;
RCP R0.w, R0.w;
MUL R1.xyz, R1.w, R1;
MUL R0.xyz, R0, c[8].z;
MAD R3.xyz, R1, c[8].z, -R0;
TXP R1.xyz, fragment.texcoord[2], texture[1], 2D;
MAD_SAT R0.w, R0, c[4].z, c[4];
LG2 R1.x, R1.x;
LG2 R1.y, R1.y;
LG2 R1.z, R1.z;
MAD R0.xyz, R0.w, R3, R0;
ADD R0.xyz, -R1, R0;
MUL R1.xyz, R2, c[5].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[5].y;
END
# 147 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
Vector 4 [unity_LightmapFade]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
SetTexture 3 [unity_LightmapInd] 2D
"ps_3_0
; 56 ALU, 8 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c5, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c6, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c7, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
dcl_texcoord4 v4
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r2.w, c5.x
mov r0.z, c5.x
mul r0.w, r0.x, c5.y
loop aL, i0
add r0.z, r0, c5
mul r0.x, r0.z, c5.w
rcp r0.x, r0.x
mul r1.xyz, r0.x, v1
mul r2.xyz, r1, c6.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.z, r1.x, -r0.x
mul_sat r1.z, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.z, r1.z
mad r0.x, -r1.z, c6.y, c6.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c6.w
cmp r0.x, r0, r0, r0.w
mad r2.w, r0.x, c7.x, r2
endloop
texld r0, v3, s2
mul_pp r0.yzw, r0.w, r0.xxyz
add r0.x, r2, r2.z
texld r1, v3, s3
mul_pp r1.xyz, r1.w, r1
mul r3.x, r0, c7.y
mov r3.y, c5.x
texld r0.x, r3, s0
mul_pp r1.xyz, r1, c7.w
mad_pp r3.xyz, r0.yzww, c7.w, -r1
mul r0.x, r0, c2
mad r0.y, r2, c7.z, r0.x
mov r0.x, c5
texld r0.x, r0, s0
dp4 r0.w, v4, v4
abs r0.z, v0
abs r0.y, v0.x
add_sat r0.y, r0, r0.z
rsq r0.z, r0.w
mul r0.y, r0, c1.x
mad r0.x, r0, r0.y, -r0.y
rcp r0.z, r0.z
mad_sat r0.y, r0.z, c4.z, c4.w
add r0.w, r0.x, c5.z
mad_pp r1.xyz, r0.y, r3, r1
texldp r0.xyz, v2, s1
mul r0.w, r2, r0
log_pp r0.x, r0.x
log_pp r0.y, r0.y
log_pp r0.z, r0.z
add_pp r0.xyz, -r0, r1
mul r1.xyz, r0.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c5.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 138 ALU, 19 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[5].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[5].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
TXP R1.xyz, fragment.texcoord[2], texture[1], 2D;
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R2.xyz, R0.x, c[3];
TEX R0, fragment.texcoord[3], texture[2], 2D;
LG2 R1.x, R1.x;
LG2 R1.z, R1.z;
LG2 R1.y, R1.y;
MUL R0.xyz, R0.w, R0;
MAD R0.xyz, R0, c[7].z, -R1;
MUL R1.xyz, R2, c[4].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[4].y;
END
# 138 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
"ps_3_0
; 48 ALU, 7 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.z, c4.x
mov r0.w, c4.x
mul r1.z, r0.x, c4.y
loop aL, i0
add r0.w, r0, c4.z
mul r0.x, r0.w, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c6.x, r0
endloop
texldp r1.xyz, v2, s1
add r0.x, r2, r2.z
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.w, r0, c1.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c4.z
mul r1.w, r0.z, r0.x
texld r0, v3, s2
log_pp r1.x, r1.x
log_pp r1.z, r1.z
log_pp r1.y, r1.y
mul_pp r0.xyz, r0.w, r0
mad_pp r0.xyz, r0, c6.w, -r1
mul r1.xyz, r1.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_OFF" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 133 ALU, 18 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[5].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[5].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
ADD R0.x, R0.z, R0;
MUL R0.w, R0.x, R0.y;
TXP R0.xyz, fragment.texcoord[2], texture[1], 2D;
MUL R1.xyz, R0.w, c[3];
ADD R0.xyz, R0, fragment.texcoord[3];
MUL R1.xyz, R1, c[4].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[4].y;
END
# 133 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
"ps_3_0
; 44 ALU, 6 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 0
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xyz
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.z, c4.x
mov r0.w, c4.x
mul r1.z, r0.x, c4.y
loop aL, i0
add r0.w, r0, c4.z
mul r0.x, r0.w, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c6.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.w, r0, c1.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c4.z
texldp r1.xyz, v2, s1
mul r0.w, r0.z, r0.x
add_pp r0.xyz, r1, v3
mul r1.xyz, r0.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
Vector 4 [unity_LightmapFade]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
SetTexture 3 [unity_LightmapInd] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 144 ALU, 20 TEX
PARAM c[9] = { program.local[0..4],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[6].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[5].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[6].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[5];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[6].x;
ADD R0.w, R0.z, c[5];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[7].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[6].y;
MUL R0.y, R0.w, c[6].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[6].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[5].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[6].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[6].x;
MUL R2.xyz, fragment.texcoord[1], c[7].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[5];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[6].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[6].x;
ADD R1.x, R1.y, c[5].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[8].y;
MOV R1.y, c[7].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[6].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[8].x, R0.x;
MOV R1.x, c[7].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[5];
ADD R0.x, R0.z, R0;
MUL R1.x, R0, R0.y;
TEX R0, fragment.texcoord[3], texture[2], 2D;
MUL R2.xyz, R0.w, R0;
TEX R0, fragment.texcoord[3], texture[3], 2D;
MUL R0.xyz, R0.w, R0;
MUL R0.xyz, R0, c[8].z;
MUL R1.xyz, R1.x, c[3];
DP4 R1.w, fragment.texcoord[4], fragment.texcoord[4];
RSQ R0.w, R1.w;
RCP R0.w, R0.w;
MAD R2.xyz, R2, c[8].z, -R0;
MAD_SAT R0.w, R0, c[4].z, c[4];
MAD R2.xyz, R0.w, R2, R0;
TXP R0.xyz, fragment.texcoord[2], texture[1], 2D;
ADD R0.xyz, R0, R2;
MUL R1.xyz, R1, c[5].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[5].y;
END
# 144 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
Vector 4 [unity_LightmapFade]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
SetTexture 3 [unity_LightmapInd] 2D
"ps_3_0
; 53 ALU, 8 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c5, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c6, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c7, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
dcl_texcoord4 v4
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r2.w, c5.x
mov r0.z, c5.x
mul r0.w, r0.x, c5.y
loop aL, i0
add r0.z, r0, c5
mul r0.x, r0.z, c5.w
rcp r0.x, r0.x
mul r1.xyz, r0.x, v1
mul r2.xyz, r1, c6.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.z, r1.x, -r0.x
mul_sat r1.z, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.z, r1.z
mad r0.x, -r1.z, c6.y, c6.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c6.w
cmp r0.x, r0, r0, r0.w
mad r2.w, r0.x, c7.x, r2
endloop
texld r0, v3, s2
mul_pp r0.yzw, r0.w, r0.xxyz
add r0.x, r2, r2.z
texld r1, v3, s3
mul_pp r1.xyz, r1.w, r1
mul r3.x, r0, c7.y
mov r3.y, c5.x
texld r0.x, r3, s0
mul_pp r1.xyz, r1, c7.w
mad_pp r3.xyz, r0.yzww, c7.w, -r1
mul r0.x, r0, c2
mad r0.y, r2, c7.z, r0.x
mov r0.x, c5
texld r0.x, r0, s0
abs r0.z, v0
abs r0.y, v0.x
add_sat r0.y, r0, r0.z
mul r0.y, r0, c1.x
mad r0.x, r0, r0.y, -r0.y
add r0.x, r0, c5.z
dp4 r0.z, v4, v4
rsq r0.z, r0.z
rcp r0.y, r0.z
mad_sat r0.y, r0, c4.z, c4.w
mad_pp r1.xyz, r0.y, r3, r1
mul r0.w, r2, r0.x
texldp r0.xyz, v2, s1
add_pp r0.xyz, r0, r1
mul r1.xyz, r0.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c5.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_OFF" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 135 ALU, 19 TEX
PARAM c[8] = { program.local[0..3],
		{ 0.2, 1, 1.5, 3 },
		{ 2, 0.25, 0.33000001, 0.75 },
		{ 0.5, 0.375, 0.30000001, 0 },
		{ 9.9999997e-05, 0.001, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R1.xyz, fragment.texcoord[1], c[5].w;
MAD R0.z, R1, c[0].x, R1.y;
MOV R0.w, R1.x;
TEX R2.x, R0.zwzw, texture[0], 2D;
MAD R0.z, R1.y, c[0].x, R1.x;
MOV R0.y, R1;
MAD R0.x, R1, c[0], R1.z;
MOV R0.w, R1.z;
TEX R1.x, R0.zwzw, texture[0], 2D;
TEX R0.x, R0, texture[0], 2D;
ADD R1.y, -R1.x, R2.x;
ADD R1.w, R0.x, -R1.x;
MAD R0.x, R0, R1.y, R1;
RCP R1.z, R1.y;
MUL R0.yzw, fragment.texcoord[1].xxyz, c[4].z;
MUL_SAT R2.y, R1.w, R1.z;
MAD R1.z, R0.w, c[0].x, R0;
MOV R1.w, R0.y;
TEX R3.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0, c[0].x, R0.y;
MOV R1.w, R0;
TEX R2.x, R1.zwzw, texture[0], 2D;
MAD R1.z, R0.y, c[0].x, R0.w;
ADD R2.z, -R2.x, R3.x;
MOV R1.w, R0.z;
TEX R3.x, R1.zwzw, texture[0], 2D;
MUL R0.w, -R2.y, c[5].x;
ADD R0.z, R3.x, -R2.x;
RCP R0.y, R2.z;
MUL_SAT R0.y, R0.z, R0;
MUL R0.z, R2.y, R2.y;
ADD R0.w, R0, c[4];
MAD R0.x, R0.z, R0.w, R0;
MUL R0.z, -R0.y, c[5].x;
ADD R0.w, R0.z, c[4];
MAD R0.z, R3.x, R2, R2.x;
MUL R0.y, R0, R0;
MAD R0.y, R0, R0.w, R0.z;
ADD R1.x, c[3], c[3].y;
MUL R2.xyz, fragment.texcoord[1], c[6].x;
ADD R0.w, R1.x, c[3].z;
MUL R0.z, R0.y, c[5].y;
MUL R0.y, R0.w, c[5].z;
CMP R1.y, R0.z, R0, R0.z;
MUL R0.x, R0, c[5].y;
CMP R1.z, R0.x, R0.y, R0.x;
ADD R1.y, R1, R1.z;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.z, R0.w, R0;
MUL R0.w, R0.z, R0.z;
MUL R0.z, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].y;
MAD R0.x, R1, R1.w, R0;
ADD R0.z, R0, c[4].w;
MAD R0.x, R0.w, R0.z, R0;
MUL R1.z, R0.x, c[5].y;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R0.w, R0, R0.z;
CMP R0.z, R1, R0.y, R1;
MUL R1.z, R0.w, R0.w;
MUL R0.w, -R0, c[5].x;
MUL R2.xyz, fragment.texcoord[1], c[6].z;
MAD R0.x, R1, R1.w, R0;
ADD R0.w, R0, c[4];
MAD R0.x, R1.z, R0.w, R0;
ADD R1.z, R1.y, R0;
MUL R0.x, R0, c[5].y;
CMP R1.y, R0.x, R0, R0.x;
MOV R0.w, R2.x;
MAD R0.z, R2, c[0].x, R2.y;
TEX R1.x, R0.zwzw, texture[0], 2D;
MOV R0.w, R2.z;
MAD R0.z, R2.y, c[0].x, R2.x;
TEX R0.x, R0.zwzw, texture[0], 2D;
ADD R1.w, -R0.x, R1.x;
MOV R0.w, R2.y;
MAD R0.z, R2.x, c[0].x, R2;
TEX R1.x, R0.zwzw, texture[0], 2D;
ADD R0.w, R1.x, -R0.x;
RCP R0.z, R1.w;
MUL_SAT R2.w, R0, R0.z;
ADD R0.z, R1, R1.y;
MAD R0.x, R1, R1.w, R0;
MUL R1.y, -R2.w, c[5].x;
ADD R1.x, R1.y, c[4].w;
MUL R0.w, R2, R2;
MAD R0.w, R0, R1.x, R0.x;
ADD R0.x, R2, R2.z;
MUL R1.x, R0, c[7].y;
MOV R1.y, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MUL R0.w, R0, c[5].y;
MUL R0.x, R0, c[2];
ABS R1.y, fragment.texcoord[0].z;
ABS R1.x, fragment.texcoord[0];
ADD_SAT R1.x, R1, R1.y;
MUL R1.z, R1.x, c[1].x;
MAD R1.y, R2, c[7].x, R0.x;
MOV R1.x, c[6].w;
TEX R0.x, R1, texture[0], 2D;
MAD R1.x, R0, R1.z, -R1.z;
CMP R0.x, R0.w, R0.y, R0.w;
ADD R0.y, R1.x, c[4];
ADD R0.x, R0.z, R0;
MUL R0.x, R0, R0.y;
MUL R2.xyz, R0.x, c[3];
TEX R0, fragment.texcoord[3], texture[2], 2D;
TXP R1.xyz, fragment.texcoord[2], texture[1], 2D;
MUL R0.xyz, R0.w, R0;
MAD R0.xyz, R0, c[7].z, R1;
MUL R1.xyz, R2, c[4].x;
MUL result.color.xyz, R1, R0;
MOV result.color.w, c[4].y;
END
# 135 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
Float 0 [_Tilt]
Float 1 [_BandsIntensity]
Float 2 [_BandsShift]
Vector 3 [_Color]
SetTexture 0 [_PlasmaTex] 2D
SetTexture 1 [_LightBuffer] 2D
SetTexture 2 [unity_Lightmap] 2D
"ps_3_0
; 45 ALU, 7 TEX, 5 FLOW
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c4, 0.00000000, 0.33000001, 1.00000000, 6.00000000
defi i0, 5, 1, 1, 0
def c5, 9.00000000, 2.00000000, 3.00000000, 0.25000000
def c6, 0.20000000, 0.00100000, 0.00010000, 8.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2
dcl_texcoord3 v3.xy
add r0.x, c3, c3.y
add r0.x, r0, c3.z
mov r0.z, c4.x
mov r0.w, c4.x
mul r1.z, r0.x, c4.y
loop aL, i0
add r0.w, r0, c4.z
mul r0.x, r0.w, c4.w
rcp r0.x, r0.x
mul r2.xyz, r0.x, v1
mul r2.xyz, r2, c5.x
mov r0.y, r2.x
mad r0.x, r2.z, c0, r2.y
texld r1.x, r0, s0
mov r0.y, r2.z
mad r0.x, r2.y, c0, r2
texld r0.x, r0, s0
add r0.y, -r0.x, r1.x
mov r1.y, r2
mad r1.x, r2, c0, r2.z
texld r1.x, r1, s0
rcp r1.y, r0.y
add r1.w, r1.x, -r0.x
mul_sat r1.w, r1, r1.y
mad r0.y, r1.x, r0, r0.x
mul r1.y, r1.w, r1.w
mad r0.x, -r1.w, c5.y, c5.z
mad r0.x, r1.y, r0, r0.y
mul r0.x, r0, c5.w
cmp r0.x, r0, r0, r1.z
mad r0.z, r0.x, c6.x, r0
endloop
add r0.x, r2, r2.z
mov r0.y, c4.x
mul r0.x, r0, c6.y
texld r0.x, r0, s0
mul r0.x, r0, c2
abs r0.y, v0.x
abs r0.w, v0.z
add_sat r0.w, r0.y, r0
mad r0.y, r2, c6.z, r0.x
mov r0.x, c4
texld r0.x, r0, s0
mul r0.w, r0, c1.x
mad r0.x, r0, r0.w, -r0.w
add r0.x, r0, c4.z
mul r1.w, r0.z, r0.x
texld r0, v3, s2
texldp r1.xyz, v2, s1
mul_pp r0.xyz, r0.w, r0
mad_pp r0.xyz, r0, c6.w, r1
mul r1.xyz, r1.w, c3
mul_pp oC0.xyz, r1, r0
mov_pp oC0.w, c4.z
"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" "DIRLIGHTMAP_ON" "HDR_LIGHT_PREPASS_ON" }
"!!GLES"
}

}
	}

#LINE 99


    }

    Fallback "Diffuse"

}

