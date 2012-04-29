/* Author: Mark Davis
 * 
 * Provides functions that will generate noise for a given coordinate and return a voxel.
 * There's nothing special about these functions... they're just examples, so feel free to make your own.
 * These can be used with: VFVoxelTerrain.GenerateVoxels
 * 
 */

using UnityEngine;
using Voxelform2.VoxelData;

namespace Voxelform2.Noise
{
	/// <summary>
	/// Provides functions that will generate noise for a given coordinate and return a voxel.
	/// </summary>
	/// <remarks>
	/// There's nothing special about these functions... they're just examples, so feel free to make your own.
	/// They can be used with: VFVoxelTerrain.GenerateVoxels
	/// </remarks>
	public class VFVoxelNoise
	{
		private VFVoxelNoise ()
		{
			
		}

		/// <summary>
		/// Returns empty voxels regardless of coordinates.
		/// </summary>
		public static VFVoxel EmptySpace (Vector3 p)
		{
			return new VFVoxel (0f, 0);
		}

		/// <summary>
		/// Returns a voxel based on Improved Perlin Noise for a point in voxel space.
		/// </summary>
		public static VFVoxel ModifiedPerlin1 (Vector3 p)
		{
			float noise = (VFImprovedPerlinNoise.Noise (p.x * .1f, p.y * .1f, p.z * .1f));
			noise += (VFImprovedPerlinNoise.Noise (p.x * .025f, p.y * .025f, p.z * .025f));
			noise = Mathf.Clamp (noise * .5f + .5f, 0f, .99f);
			
			var v = new VFVoxel (noise);
			
			return v;
		}

		/// <summary>
		/// Returns a voxel based on an Improved Perlin Noise fractal for a point in voxel space.
		/// </summary>
		public static VFVoxel ModifiedPerlinFractalBasic (Vector3 p)
		{
			float noise = 0f;
			
			p *= .25f;
			
			for (float s = 1f; s < 32f; s *= 2f) {
				noise += s * VFImprovedPerlinNoise.Noise (p.x, p.y, p.z);
				p *= .5f;
				
			}
			
			noise = Mathf.Pow (1f - (noise / 31f), 5f) * .5f;
			
			VFVoxel v = new VFVoxel (noise);
			
			return v;
		}

		/// <summary>
		/// Returns a voxel based on a Simplex Noise fractal for a point in voxel space.
		/// </summary>
		public static VFVoxel SimplexFractalBasic (Vector3 p)
		{
			float noise = 0f;
			
			p *= .1f;
			
			for (float s = 1f; s < 32f; s *= 2f) {
				noise += s * VFSimplexNoise.Noise (p.x, p.y, p.z);
				p *= .5f;
				
			}
			
			noise = Mathf.Pow ((noise / 31f) - 1f, 5f) * .5f + .5f;
			
			VFVoxel v = new VFVoxel (noise);
			
			return v;
			
		}

		/// <summary>
		/// Returns a voxel based on a Simplex Noise fractal for a point in voxel space.
		/// </summary>
		public static VFVoxel SimplexFractalBasic2 (Vector3 p)
		{
			float noise = 0f;
			
			p *= .1f;
			
			for (float s = 1f; s < 16f; s *= 4f) {
				noise += s * VFSimplexNoise.Noise (p.x, p.y, p.z);
				p *= .25f;
				
			}
			
			noise = Mathf.Pow ((noise / 15f) - 1f, 5f) + 1f;
			
			VFVoxel v = new VFVoxel (noise);
			
			return v;
			
		}

		/// <summary>
		/// Returns a voxel based on a Simplex Noise fractal with terracing for a point in voxel space.
		/// </summary>
		public static VFVoxel SimplexFractalTerraced (Vector3 p)
		{
			float noise = 0f;
			
			p *= .1f;
			
			for (float s = 1f; s < 32f; s *= 2f) {
				float px = p.x + Mathf.Sin ((p.y * 4f) - Mathf.Ceil (p.y * 4f)) * .1f;
				float py = Mathf.Ceil (p.y * 4f);
				float pz = p.z - Mathf.Cos (Mathf.Ceil (p.y * 2f)) * .1f;
				
				noise += s * VFSimplexNoise.Noise (px, py, pz);
				p *= .5f;
				
			}
			
			noise = Mathf.Pow ((noise / 31f) - 1f, 5f) + 1f;
			
			VFVoxel v = new VFVoxel (noise);
			
			return v;
			
		}

		/// <summary>
		/// Returns a voxel based on a Simplex Noise fractal with terracing for a point in voxel space.
		/// </summary>
		public static VFVoxel SimplexFractalTerraced2 (Vector3 p)
		{
			float noise = 0f;
			
			p *= .1f;
			
			for (float s = 1f; s < 16f; s *= 2f) {
				float px = p.x + Mathf.Sin ((p.y * 4f) - Mathf.Ceil (p.y * 4f)) * .1f;
				float py = Mathf.Ceil ((p.y) * 4f);
				float pz = p.z - Mathf.Cos (Mathf.Ceil (p.y * 8f)) * .1f;
				
				noise += s * VFSimplexNoise.Noise (px, py, pz);
				p *= .5f;
				
			}
			
			noise = Mathf.Pow ((noise / 15f) - 1f, 5f) + 1f;
			
			VFVoxel v = new VFVoxel (noise);
			
			return v;
			
		}
	}
}


