/* Author: Mark Davis
 * 
 * This structure contains all the data comprising a voxel in Voxelform.
 * It's used extensively by both VFVoxelTerrain (Fabrication) and VFVoxelChunk.
 * 
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Voxelform2.VoxelData
{
	
	/// <summary>
	/// This structure contains voxel volume information which is compared against the isolevel to create surfaces.
	/// It's also used to calculate vertex normals. 
	/// </summary>
	public struct VFVoxel
	{
		/// <summary>
		/// Normalized floating point volume compared against isolevel to create surfaces and calculate vertex normals.
		/// </summary>
		public float Volume;
		
		/// <summary>
		/// Voxel material type used for multi-material support.
		/// </summary>
		public ushort Type;
		
		/// <summary>
		/// Bit flags used for neighbor status and custom functionality.
		/// Bits 0-26 are used to store neighboring voxels' visibility to determine enclosure status.
		/// Bits 27-28 are reserved for future use.
		/// Bits 29-31 are free for any use.
		/// </summary>
		public uint Flags;
		
		/// <summary>
		/// Creates a Voxel with volume data. 
		/// </summary>
		public VFVoxel(float volume)
		{
			Volume = volume;
			Type = 0;
			Flags = 0;
		}

		/// <summary>
		/// Creates a Voxel with volume data. 
		/// </summary>
		public VFVoxel(float volume, ushort type)
		{
			Volume = volume;
			Type = type;
			Flags = 0;
		}
		
		/// <summary>
		/// Determines whether or not a voxel is fully enclosed by neighbors with
		/// a volume greater than or equal to the isolevel.
		/// </summary>
		public bool FullyEnclosed()
		{
			uint mask = ((uint)((1 << 27) - 1)) << 5;
			return ((Flags << 5) & mask) == mask;
		}
		
		/// <summary>
		/// Determines whether or not a voxel is completely free of any neighbors with
		/// a volume greater than or equal to the isolevel.
		/// </summary>
		public bool FullyUnenclosed()
		{
			return (Flags << 5) == 0;
		}

	}
}