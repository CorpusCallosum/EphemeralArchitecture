/* Author: Mark Davis
 * 
 * VFVoxelTerrain requires a data source that is an implementation of this interface.
 * The implemented interface is used by VFVoxelTerrain to perform voxel I/O.
 * For an example implementation, take a look at: VFSimpleVoxelDataSource 
 * If you create a new implementation, you will need to override: VFVoxelTerrain.CreateDataSource 
 * 
 */

using System;

namespace Voxelform2.VoxelData
{
	/// <summary>
	/// VFVoxelTerrain requires a data source that is an implementation of this interface.
	/// The implemented interface is used by VFVoxelTerrain to perform voxel I/O.
	/// </summary>
	/// <remarks>
	/// For an example implementation, take a look at: VFSimpleVoxelDataSource 
	/// If you create a new implementation, you will need to override: VFVoxelTerrain.CreateDataSource 
	/// </remarks>
	public interface IVFVoxelDataSource
	{
		/// <summary>
		/// Width in voxels. 
		/// </summary>
		int Width { get; }
		
		/// <summary>
		/// Height in voxels. 
		/// </summary>
		int Height { get; }
		
		/// <summary>
		/// Depth in voxels. 
		/// </summary>
		int Depth { get; }
		
		/// <summary>
		/// The normalized minimum voxel volume required to create a surface.
		/// </summary>
		float Isolevel { get; }
		
		/// <summary>
		/// Reads a voxel in voxel space.
		/// </summary>
		VFVoxel Read(int x, int y, int z);
		
		/// <summary>
		/// Writes a voxel in voxel space.
		/// Implementation may require a flush.
		/// </summary>
		void Write(int x, int y, int z, VFVoxel voxel);
		
		/// <summary>
		/// Flushes indirect voxel writes where a queue or a buffer may reside behind the scenes.
		/// This may be a good place to update enclosure information.
		/// </summary>
		void Flush();
		
		/// <summary>
		/// Performs a bounds checked read in voxel space.
		/// </summary>
		VFVoxel SafeRead(int x, int y, int z);
		
		/// <summary>
		/// Performs a bounds checked write in voxel space.
		/// Implementation may require a flush.
		/// </summary>
		bool SafeWrite(int x, int y, int z, VFVoxel voxel);

	}
}