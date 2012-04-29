/*  Author: Mark Davis
 *  
 *  This shader provides triplanar texturing with normal and specular support.
 *  
 *  Much of this code was inspired by the first chapter in GPU Gems 3.
 *  Lighting was inspired by Unity's own examples.
 *  
 *  I highly recommend experimenting with some of the textures from this site:
 *  http://www.filterforge.com/filters/category46-page1.html
 */

Shader "Voxelform/Triplanar 3/Diffuse Normal" {

    Properties {
		
		_CeilingDiffuse ("Ceiling Diffuse", 2D) = "white" {}
		_CeilingNormal ("Ceiling Normal", 2D) = "white" {}
		
		_WallDiffuse ("Wall Diffuse", 2D) = "white" {}
		_WallNormal ("Wall Normal", 2D) = "white" {}
		
		_FloorDiffuse ("Floor Diffuse", 2D) = "white" {}		
		_FloorNormal ("Floor Normal", 2D) = "white" {}
		
		_NormalPower ("Normal Power", Float) = 1
		_SpecularPower ("Specular Power", Float) = 1
		_TriplanarFrequency ("Triplanar Frequency", Float) = .2

    }

    SubShader {
		
		Tags { "RenderType" = "Opaque" }
		
		CGPROGRAM
		#pragma target 3.0
		#include "UnityCG.cginc"
		#pragma surface surf SimpleLambert

		float _NormalPower;
		float _SpecularPower;
		float _TriplanarFrequency;

		float4 _Rotation;

		sampler2D _CeilingDiffuse;
		sampler2D _WallDiffuse;
		sampler2D _FloorDiffuse;

		sampler2D _CeilingNormal;
		sampler2D _WallNormal;
		sampler2D _FloorNormal;
		
		sampler2D _CeilingSpecular;
		sampler2D _WallSpecular;
		sampler2D _FloorSpecular;
				
		struct CustomSurfaceOutput
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Alpha;
			half3 BumpNormal;
			half Specular;
		};

		half4 LightingSimpleLambert (CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half NdotL = dot(normalize(s.BumpNormal), normalize(lightDir));
			
			half3 h = normalize (lightDir + normalize(viewDir));
			
			half nh = max (0, dot (s.BumpNormal, h));
			half spec = smoothstep(0, 1.0, pow(nh, 32.0 * s.Specular)) * _SpecularPower;
			
			half4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * NdotL + _LightColor0.rgb * spec) * atten;
			c.a = s.Alpha;

			return c;
		}

		struct Input
		{
			float3 uv_Texture;
			float3 worldPos;
			float3 worldNormal;
		};
		
		void surf (Input IN, inout CustomSurfaceOutput o)
		{
			float3 blendingWeights = abs( normalize(IN.worldNormal) );
			blendingWeights = (blendingWeights - 0.2) * 7; 
			blendingWeights = max(blendingWeights, 0); 
			blendingWeights /= (blendingWeights.x + blendingWeights.y + blendingWeights.z ).xxx; 

			float4 blendedColor;
			float3 blendedNormal;
			float blendedSpec;
			
			float2 coord1 = IN.worldPos.zy * -_TriplanarFrequency;
			float2 coord2 = IN.worldPos.zx * _TriplanarFrequency;
			float2 coord3 = float2(IN.worldPos.x, -IN.worldPos.y) * -_TriplanarFrequency;
			
			float4 col1 = tex2D(_WallDiffuse, coord1);
			float4 col2a = tex2D(_CeilingDiffuse, coord2);
			float4 col2b = tex2D(_FloorDiffuse, coord2);
			float4 col2 = (IN.worldNormal.y < 0.0) ? col2a : col2b;
			float4 col3 = tex2D(_WallDiffuse, coord3);

			float2 bumpFetch1 = tex2D(_WallNormal, coord1).xy - 0.5; 
			float2 bumpFetch2a = tex2D(_CeilingNormal, coord2).xy - 0.5;
			float2 bumpFetch2b = tex2D(_FloorNormal, coord2).xy - 0.5;
			float2 bumpFetch2 = (IN.worldNormal.y < 0.0) ? bumpFetch2a : bumpFetch2b;
			float2 bumpFetch3 = tex2D(_WallNormal, coord3).xy - 0.5; 
			
			float3 bump1 = float3(0, -bumpFetch1.y, -bumpFetch1.x); 
			float3 bump2 = float3(bumpFetch2.y, 0, bumpFetch2.x); 
			float3 bump3 = float3(bumpFetch3.x, bumpFetch3.y, 0);
			
			blendedColor = col1.xyzw * blendingWeights.xxxx + 
			col2.xyzw * blendingWeights.yyyy + 
			col3.xyzw * blendingWeights.zzzz;

			blendedNormal = bump1.xyz * blendingWeights.xxx + 
			bump2.xyz * blendingWeights.yyy + 
			bump3.xyz * blendingWeights.zzz;
			
			float4 n = float4(blendedNormal.x, blendedNormal.y, -blendedNormal.z, 1);
			float4 camVec = normalize(n);
			
			o.BumpNormal = normalize(IN.worldNormal + (camVec) * -_NormalPower);
			o.Specular = _SpecularPower;
			o.Albedo = blendedColor;
			o.Alpha = 1.0;

		}

      ENDCG

    }

    Fallback "Diffuse"

}

