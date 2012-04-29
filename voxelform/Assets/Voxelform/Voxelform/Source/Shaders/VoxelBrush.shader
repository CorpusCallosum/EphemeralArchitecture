/*  Author: Mark Davis
 *
 *  This is used for a the voxel brush in the editor extension.
 *
 */

Shader "Voxelform/Voxel Brush" {

    SubShader {
		
		Blend One OneMinusSrcAlpha

		Tags { "Queue" = "Transparent" }

		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Lambert
		
		struct Input {
			float2 uv_Texture;
			float3 worldPos;
			float3 worldNormal;
		};
		
		float4 _Color;
		
		void surf (Input IN, inout SurfaceOutput o)
		{
			/* Lantern style...
			float3 c = frac(normalize(IN.worldNormal) * 2.3 * .5 - .0775);
			c = ((c.r < .85 ? 0.0 : 1.0) + (c.g < .85 ? 0.0 : 1.0) + (c.b < .85 ? 0.0 : 1.0));
			o.Alpha = (c.r + c.g + c.b) > 0 ? 1.0 : 0.5;
			o.Albedo = o.Alpha < 1.0 ? float3(.5, .2, 0.0) : float3(.45,0,0);
			*/

			o.Alpha = .614;
			o.Albedo = float3(.5, .2, 0.0);

		}

      ENDCG

    }

    Fallback "Diffuse"

}

