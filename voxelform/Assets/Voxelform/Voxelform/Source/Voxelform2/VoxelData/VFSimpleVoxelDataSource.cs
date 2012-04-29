/* Author: Mark Davis
 * 
 * This is a simple implementation of the IVFVoxelDataSource interface.
 * VFVoxelTerrain requires a datasource such as this, and will use this as a default.
 * If you create a new implementation, you will need to override: VFVoxelTerrain.CreateDataSource
 * 
 */

using System.Collections.Generic;
using UnityEngine;

namespace Voxelform2.VoxelData
{
	/// <summary>
	/// This is a simple implementation of the IVFVoxelDataSource interface.
	/// VFVoxelTerrain requires a datasource such as this, and will use this as a default.
	/// If you create a new implementation, you will need to override: VFVoxelTerrain.CreateDataSource
	/// </summary>
	public class VFSimpleVoxelDataSource : IVFVoxelDataSource
	{
		/// <summary>
		/// This structure contains the information required to queue voxel writes. 
		/// </summary>
		struct QueuedVoxelData
		{
			public int X;
			public int Y;
			public int Z;
			public VFVoxel Voxel;
	
			public QueuedVoxelData(int x, int y, int z, VFVoxel voxel)
			{
				X = x;
				Y = y;
				Z = z;
				Voxel = voxel;
			}
		}
		
		/// <summary>
		/// In this implementation, a 3D array is used to store all voxels.
		/// Other implementations may work differently.
		/// </summary>
		VFVoxel[, ,] _voxels;
		
		/// <summary>
		/// The write queue is used store voxel writes until a flush is performed.
		/// This allows voxel data to be read while being written to without unwanted side effects.
		/// A queue is not required for this.  Another data structure such as a 3D buffer could be used.
		/// </summary>
		Queue<QueuedVoxelData> _writeQueue;
		
		int _width;
		
		/// <summary>
		/// Width in voxels. 
		/// </summary>
		public int Width { get { return _width; } }
		
		int _height;
		
		/// <summary>
		/// Height in voxels. 
		/// </summary>
		public int Height { get { return _height; } }
	
		int _depth;
		
		/// <summary>
		/// Depth in voxels. 
		/// </summary>
		public int Depth { get { return _depth; } }
		
		float _isolevel;
		
		/// <summary>
		/// The normalized minimum voxel volume required to create a surface. 
		/// </summary>
		public float Isolevel { get { return _isolevel; } }
		
		/// <summary>
		/// This is a simple implementation of the IVFVoxelDataSource interface.
		/// VFVoxelTerrain requires a datasource such as this, and will use this as a default.
		/// If you create a new implementation, you will need to override: VFVoxelTerrain.CreateDataSource 
		/// </summary>
		public VFSimpleVoxelDataSource(int width, int height, int depth, float isolevel)
		{
			_width = width;
			_height = height;
			_depth = depth;
			_isolevel = isolevel;
			_voxels = new VFVoxel[_width, _height, _depth];
			_writeQueue = new Queue<QueuedVoxelData>();
		}
		
		/// <summary>
		/// Reads a voxel in voxel space.
		/// </summary>
		public VFVoxel Read(int x, int y, int z)
		{
			return _voxels[x, y, z];
		}
		
		/// <summary>
		/// Writes a voxel in voxel space.
		/// Requires a flush.
		/// </summary>
		public void Write(int x, int y, int z, VFVoxel voxel)
		{
			_writeQueue.Enqueue(new QueuedVoxelData(x, y, z, voxel));
		}
		
		/// <summary>
		/// Flushes indirect voxel writes where a queue or a buffer may reside behind the scenes.
		/// Enclosure information is updated here as well.  Bit fields that represent neighboring voxels'
		/// visibility are built up in a single pass for each voxel.  The enclosure information
		/// is used by VFVoxelChunk to ensure that triangles are not generated where they can't be seen.
		/// This prevents triangles from being generated inside welds between two different material types.
		/// Also, take a look at the following methods: VFVoxel.FullyEnclosed, VFVoxel.FullyUnenclosed
		/// </summary>
		public void Flush()
		{
			// Dequeue and process each voxel on the write queue.
			while (_writeQueue.Count > 0)
			{
				QueuedVoxelData qvData = _writeQueue.Dequeue();
				VFVoxel voxel = qvData.Voxel;
				
				int vx = qvData.X;
				int vy = qvData.Y;
				int vz = qvData.Z;
				
				// Write the basic voxel information.
				
				_voxels[vx, vy, vz].Type = voxel.Type;
				_voxels[vx, vy, vz].Volume = voxel.Volume;
				
				// Now compare volume against isolevel and then write the result
				// to all neighboring voxels, including self, using a bit field.
				
				// Note: By writing the result to neighbors rather than the slightly
				// more obvious method of comparing neighbors and writing the
				// result to self, this can be accomplished in a single pass.
				
				bool lessThanIsolevel = voxel.Volume < _isolevel;
				
				// Compute lower and upper bounds for x, y, and z.
				
				int lbx = vx > 0 ? -1 : 0;
				int ubx = (vx + 1) < (_width - 1) ? 2 : 1;
				
				int lby = vy > 0 ? -1 : 0;
				int uby = (vy + 1) < (_height - 1) ? 2 : 1;
				
				int lbz = vz > 0 ? -1 : 0;
				int ubz = (vz + 1) < (_depth - 1) ? 2 : 1;
				
				// Write to self and neighbors.
				
				for (int px = lbx; px < ubx; ++px)
				{
					int vix = (px + 1) * 9;
					
					for (int py = lby; py < uby; ++py)
					{
						int viy = (py + 1) * 3;
						
						for (int pz = lbz; pz < ubz; ++pz)
						{
							uint flag = (uint)(1 << (vix + viy + (pz + 1)));
							
							if (lessThanIsolevel)
							{
								_voxels[vx + px, vy + py, vz + pz].Flags &= ~flag;
							}
							else
							{
								_voxels[vx + px, vy + py, vz + pz].Flags |= flag;
							}
						}
					}
				}
			}
			
		}
		
		/// <summary>
		/// Performs a bounds checked read in voxel space.
		/// </summary>
		public VFVoxel SafeRead(int x, int y, int z)
		{
			if (x < 0) x = 0;
			if (x >= _voxels.GetUpperBound(0)) x = _voxels.GetUpperBound(0) - 1;
	
			if (y < 0) y = 0;
			if (y >= _voxels.GetUpperBound(1)) y = _voxels.GetUpperBound(1) - 1;
	
			if (z < 0) z = 0;
			if (z >= _voxels.GetUpperBound(2)) z = _voxels.GetUpperBound(2) - 1;
	
			return Read(x, y, z);
		}
		
		/// <summary>
		/// Performs a bounds checked write in voxel space.
		/// Requires a flush.
		/// </summary>
		public bool SafeWrite(int x, int y, int z, VFVoxel voxel)
		{
			
			if ((x < 1) || (x >= _voxels.GetUpperBound(0) - 1))
			{
				return false;
			}
	
			if ((y < 1) || (y >= _voxels.GetUpperBound(1) - 1))
			{
				return false;
			}
	
			if ((z < 1) || (z >= _voxels.GetUpperBound(2) - 1))
			{
				return false;
			}
			
			voxel.Volume = Mathf.Clamp(voxel.Volume, 0f, .99f);
			Write(x, y, z, voxel);
	
			return true;
		}
	
	}
}
