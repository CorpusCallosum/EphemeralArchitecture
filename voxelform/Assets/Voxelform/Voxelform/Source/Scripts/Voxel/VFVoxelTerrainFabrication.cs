/* Author: Mark Davis
 * 
 * This is the main voxel terrain class.  It should be used as a base class for your voxel terrain scripts.
 * Please notice that this is a partial class.  This file contains the core workings of the voxel terrain.
 * Fabrication related code resides in VFVoxelTerrainFabrication.cs, the other part of this class.
 * To get started, take a look at an example in the Examples folder.
 * 
 */

using CyclopsFramework.Actions.Flow;
using CyclopsFramework.Core;
using CyclopsFramework.Core.Easing;

using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

using UnityEngine;

using Voxelform2.Noise;
using Voxelform2.VoxelData;

/// <summary>
/// Fabrication option enum flags. 
/// </summary>
[System.Flags]
public enum VFFabOptions
{
	None = 0,
	UseExistingType = 1,
	UseExistingVolume = 2,
	EnableVolumeSubtraction = 4
}

/// <summary>
/// This is the main voxel terrain class.  It should be used as a base class for your voxel terrain scripts.
/// </summary>
/// <remarks>
/// Please notice that this is a partial class.  This file contains code for voxel fabrication. 
/// The core voxel terrain code resides in VFVoxelTerrain.cs, the other part of this class.
/// To get started, take a look at an example in the Examples folder.
/// </remarks>
public abstract partial class VFVoxelTerrain : MonoBehaviour
{
	/// <summary>
	/// Sets each voxel to: {Volume:0, Type:0, Flags:0}
	/// </summary>
	public void Clear()
	{
		for (int px = 0; px < _voxels.Width; ++px)
		{
			for (int py = 0; py < _voxels.Height; ++py)
			{
				for (int pz = 0; pz < _voxels.Depth; ++pz)
				{
					_voxels.Write(px, py, pz, new VFVoxel(0f));
				}
			}
		}
	}
	
	/// <summary>
	/// Applies f to each voxel coordinate and writes the result to the voxel at that coordinate.
	/// Note that edges are skipped in order to allow the surfaces to close on the edges.
	/// </summary>
	public void AlterAllVoxels(System.Func<Vector3, VFVoxel> f)
	{
		int nvx = _voxels.Width - 1;
		int nvy = _voxels.Height - 1;
		int nvz = _voxels.Depth - 1;
		
		for (int px = 1; px < nvx; ++px)
		{
			for (int py = 1; py < nvy; ++py)
			{
				for (int pz = 1; pz < nvz; ++pz)
				{
					VFVoxel v = f(new Vector3(px, py, pz));
					_voxels.Write(px, py, pz, v);
				}
			}
		}
	}
	
	/// <summary>
	/// Manipulates a voxel and updates neighbor chunks if the voxel lies on a border.
	/// Please note that even invisible volumes in neighboring voxels can cause unwanted distortion.
	/// </summary>
	public void AlterVoxel(Vector3 position, VFVoxel voxel, VFFabOptions options)
	{
		AlterVoxel((int)position.x, (int)position.y, (int)position.z, voxel, options);
	}
	
	/// <summary>
	/// Manipulates a voxel and updates neighbor chunks if the voxel lies on a border.
	/// Please note that even invisible volumes in neighboring voxels can cause unwanted distortion.
	/// </summary>
	public void AlterVoxel(float vx, float vy, float vz, VFVoxel voxel, VFFabOptions options)
	{
		AlterVoxel((int)vx, (int)vy, (int)vz, voxel, options);
	}
	
	/// <summary>
	/// Manipulates a voxel and updates neighbor chunks if the voxel lies on a border.
	/// Please note that even invisible volumes in neighboring voxels can cause unwanted distortion.
	/// </summary>
	public void AlterVoxel(int vx, int vy, int vz, VFVoxel voxel, VFFabOptions options)
	{
		VFVoxel existingVoxel = _voxels.SafeRead(vx, vy, vz);
		
		if ((options & VFFabOptions.UseExistingVolume) != 0)
		{
			voxel.Volume = existingVoxel.Volume;
		}
		
		if ((options & VFFabOptions.UseExistingType) != 0)
		{
			voxel.Type = existingVoxel.Type;
		}
		
		if ((options & VFFabOptions.EnableVolumeSubtraction) != 0)
		{
			voxel.Volume *= -1f;
			voxel.Type = existingVoxel.Type;
			
		}
		
		voxel.Volume += existingVoxel.Volume;
		
		_voxels.SafeWrite(vx, vy, vz, voxel);
				
		int nvx = _numVoxelsPerXAxis;
		int nvy = _numVoxelsPerYAxis;
		int nvz = _numVoxelsPerZAxis;

		int cx = vx / nvx;
		int cy = vy / nvy;
		int cz = vz / nvz;

		Vector3 cvKey = new Vector3(cx, cy, cz);
		
		VFVoxelChunk chunk;

		if (_chunks.TryGetValue(cvKey, out chunk))
		{
			if (chunk != null)
			{
				chunk.IsDirty = true;
			}
		}

		for (int dx = -1; dx <= 0; ++dx)
		{
			for (int dy = -1; dy <= 0; ++dy)
			{
				for (int dz = -1; dz <= 0; ++dz)
				{
					int px = cx + dx;
					if ((px < 0) || (px >= _xChunkCount)) continue;

					int py = cy + dy;
					if ((py < 0) || (py >= _yChunkCount)) continue;

					int pz = cz + dz;
					if ((pz < 0) || (pz >= _zChunkCount)) continue;
					
					if (((vx % nvx) == 0) || (((vy % nvy) == 0) || ((vz % nvz) == 0)))
					{
						cvKey = new Vector3(px, py, pz);
						if (_chunks.TryGetValue(cvKey, out chunk))
						{
							if (chunk != null)
							{
								chunk.IsDirty = true;
							}
						}
					}
					
				}
			}
		}

	}
	
	/// <summary>
	/// Alters voxels contained within the region of a box.
	/// Please note that even invisible volumes in neighboring voxels can cause unwanted distortion.
	/// </summary>
	public void AlterVoxelBox(Vector3 p, float width, float height, float depth, float volume, ushort voxelType, VFFabOptions options)
	{
		float x1 = p.x - width / 2;
		float y1 = p.y - height / 2;
		float z1 = p.z - depth / 2;
		float x2 = p.x + width / 2;
		float y2 = p.y + height / 2;
		float z2 = p.z + depth / 2;

		for (float px = x1; px < x2; ++px)
		{
			for (float py = y1; py < y2; ++py)
			{
				for (float pz = z1; pz < z2; ++pz)
				{
					VFVoxel voxel = new VFVoxel(volume, voxelType);
					AlterVoxel(px, py, pz, voxel, options);
				}
			}
		}
		
		_voxels.Flush();

	}
	
	/// <summary>
	/// Alters voxels contain within the region of a sphere.
	/// Please note that even invisible volumes in neighboring voxels can cause unwanted distortion.
	/// </summary>
	public void AlterVoxelSphere(Vector3 p, float radius, float coreVolume, ushort voxelType, VFFabOptions options)
	{
		float x1 = p.x - radius;
		float y1 = p.y - radius;
		float z1 = p.z - radius;
		float x2 = p.x + radius;
		float y2 = p.y + radius;
		float z2 = p.z + radius;
		
		for (float px = x1; px < x2; ++px)
		{
			for (float py = y1; py < y2; ++py)
			{
				for (float pz = z1; pz < z2; ++pz)
				{
					Vector3 v = new Vector3(px - p.x, py - p.y, pz - p.z);
					float bpos = radius - v.magnitude;
					if (bpos > 0f)
					{
						VFVoxel voxel = new VFVoxel((bpos >= 1f) ? coreVolume : ((bpos % 1f) * coreVolume), voxelType);
						float volume = _voxels.SafeRead((int)px, (int)py, (int)pz).Volume;
						if ((volume + voxel.Volume) < bpos * (1f - _voxels.Isolevel))
						{
							AlterVoxel(px, py, pz, voxel, options);
						}
						else if ((volume + voxel.Volume * .05f) < bpos * (1f - _voxels.Isolevel))
						{
							voxel.Volume *= .05f;
							AlterVoxel(px, py, pz, voxel, options);
						}
					}
				}
			}
		}

		_voxels.Flush();
		
	}
	
	/// <summary>
	/// Processes a custom function to generate voxel data.
	/// </summary>
	/// <remarks> 
	/// This is intended for use in Start.  Subsequent manipulation should use AlterVoxel.
	/// Note: It's a good idea to leave a buffer along the edges of the world.
	/// It keeps the chunk meshes solid at the edges as it allows the surface to close.
	/// </remarks>
	public void GenerateVoxels(System.Func<Vector3, VFVoxel> noiseFunc, int groundPlaneHeight, ushort groundType)
	{
		int nvx = (_xChunkCount * _numVoxelsPerXAxis) - 1;
		int nvy = (_yChunkCount * _numVoxelsPerYAxis) - 1;
		int nvz = (_zChunkCount * _numVoxelsPerZAxis) - 1;
		
		VFImprovedPerlinNoise.Initialize();
		VFSimplexNoise.Initialize();
		
		for (int px = 1; px < nvx; ++px)
		{
			for (int py = 1; py < nvy; ++py)
			{
				for (int pz = 1; pz < nvz; ++pz)
				{
					VFVoxel v = noiseFunc(new Vector3(px, py, pz));
					
					// Just in case... prevents a crash when materials go out of bounds.
					// This is mostly here for when you're experimenting with voxel generation functions.
					// If you feel that this should actually throw an error, feel free to make it do so.
					if (v.Type >= Materials.Length) v.Type = (ushort)(Materials.Length - 1);
					
					// This helps prevent unwanted distortion.
					// If the condition is set to (v.Volume < _isolevel), then some edges may lose their curved form.
					// If this line is removed altogether, form may be improved, but unwanted distortion may occur
					// when using AlterVoxel.
					if (v.Volume < _isolevel * .75f) v.Volume = 0f;
					
					_voxels.Write(px, py, pz, v);
				}
			}
		}
		
		// Provides solid ground.
		if (groundPlaneHeight > 0)
		{
			for (int px = 1; px <= nvx; ++px)
			{
				for (int pz = 1; pz <= nvz; ++pz)
				{
					for (int py = 1; py < groundPlaneHeight; ++py)
					{
						_voxels.Write(px, py, pz, new VFVoxel(1f, groundType));
					}
				}
			}
		}

		_voxels.Flush();
		
	}
	
	/// <summary>
	/// Loads a raw voxel file into the voxel array.
	/// </summary>
	public void LoadVoxels(string fullPath)
	{
		using (FileStream stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read))
		{
			using (BinaryReader reader = new BinaryReader(stream))
			{
				Debug.Log("Loading: " + fullPath);
				
				var fileFormat = new string(reader.ReadChars(8));
				
				Debug.Log("File format: " + fileFormat);

				int fileFormatVersion = (fileFormat == "VFRAW001") ? 1 : (fileFormat == "VFRAW002") ? 2 : 0;

				if ((fileFormatVersion == 1) || (fileFormatVersion == 2))
				{
					_xChunkCount = reader.ReadInt32();
					_yChunkCount = reader.ReadInt32();
					_zChunkCount = reader.ReadInt32();
					
					Debug.Log("Chunk counts: x: "
						+ _xChunkCount + " y: " + _yChunkCount + " z: " + _zChunkCount);
					
					_numVoxelsPerXAxis = reader.ReadInt32();
					_numVoxelsPerYAxis = reader.ReadInt32();
					_numVoxelsPerZAxis = reader.ReadInt32();
										
					Debug.Log("Voxels per axis: "
						+ _numVoxelsPerXAxis + "," + _numVoxelsPerYAxis + "," + _numVoxelsPerXAxis);
					
					int numVoxelsX = _xChunkCount * _numVoxelsPerXAxis;
					int numVoxelsY = _yChunkCount * _numVoxelsPerYAxis;
					int numVoxelsZ = _zChunkCount * _numVoxelsPerZAxis;
					
					_scale = reader.ReadSingle();
					_isolevel = reader.ReadSingle();
					
					Debug.Log("Scale: " + _scale + "\nIsolevel: " + _isolevel);
					
					Debug.Log("Creating voxel array.");
					_voxels = new VFSimpleVoxelDataSource(numVoxelsX + 2, numVoxelsY + 2, numVoxelsZ + 2, _isolevel);
					
					Debug.Log("Loading voxels.");
					
					for (int px = 0; px < numVoxelsX; ++px)
					{
						for (int py = 0; py < numVoxelsY; ++py)
						{
							for (int pz = 0; pz < numVoxelsZ; ++pz)
							{
								float voxelVolume = reader.ReadSingle();
								ushort voxelType = (fileFormatVersion == 2) ? reader.ReadUInt16() : (ushort)0;
								VFVoxel voxel = new VFVoxel(voxelVolume, voxelType);
								_voxels.Write(px, py, pz, voxel);
							}
						}
					}
				}

				_voxels.Flush();
				
				Debug.Log("Finished.");
				
				reader.Close();
				
				RebuildChunks();

			}
		}
		
	}
	
	/// <summary>
	/// Saves a file to disk from the voxel array, including current settings.
	/// </summary>
	public void SaveRawVoxels(string fullPath)
	{
		print("Beginning Save: " + fullPath);
		using (FileStream stream = new FileStream(fullPath, FileMode.Create, FileAccess.Write))
		{
		    using (BinaryWriter writer = new BinaryWriter(stream))
		    {
				Debug.Log("Saving: " + fullPath);
				
				writer.Write("VFRAW002".ToCharArray());
				
				writer.Write(_xChunkCount);
				writer.Write(_yChunkCount);
				writer.Write(_zChunkCount);
				
				writer.Write(_numVoxelsPerXAxis);
				writer.Write(_numVoxelsPerYAxis);
				writer.Write(_numVoxelsPerZAxis);
				
				writer.Write(_scale);
				writer.Write(_isolevel);
				
				int numVoxelsX = _xChunkCount * _numVoxelsPerXAxis;
				int numVoxelsY = _yChunkCount * _numVoxelsPerYAxis;
				int numVoxelsZ = _zChunkCount * _numVoxelsPerZAxis;
				
				for (int px = 0; px < numVoxelsX; ++px)
				{
					for (int py = 0; py < numVoxelsY; ++py)
					{
						for (int pz = 0; pz < numVoxelsZ; ++pz)
						{
							VFVoxel voxel = _voxels.Read(px, py, pz);
							writer.Write(voxel.Volume);
							writer.Write(voxel.Type);
						}
					}
				}
		        
				writer.Flush();
		        writer.Close();
				
				Debug.Log("Saved.");
		    }
		}
	}
	
}