/* Author: Mark Davis
 * 
 * This is an example script to attach to a voxel terrain object in your scene.
 * This class subclasses VFVoxelTerrain via VFVoxelTerrainBaseExample.
 * 
 */

using UnityEngine;
using Voxelform2.Noise;
using Voxelform2.VoxelData;

/// <summary>
/// This is an example script to attach to a voxel terrain object in your scene.
/// It loads a raw voxel file into the voxel data store.
/// This class subclasses VFVoxelTerrain via VFVoxelTerrainBaseExample. 
/// </summary>
public class VFVoxelTerrainExampleLoadFromFile : VFVoxelTerrainBaseExample
{
	// Use this for initialization.
	public override void Start ()
	{
		// Call this first!
		base.Start();
		
		// This loads a raw voxel file into the voxel data store.
		// Be sure to replace the filename with something that will actually work!
		LoadVoxels("terrain.voxelform");
		
		// Note: All voxels need to be generated before any chunks are generated.
		// The reason for this is that the chunks require information from their neighbors.
		
		// Start the world.
		InitChunks();
				
	}
	
	// Not required, but here to demonstrate that you can override this if required.
	protected override void Update ()
	{
		// Call this first!
		base.Update();
	}
	
	// Not required, but here to demonstrate that you can override this if required.
	// Override this method to return a custom voxel data source... only if you feel like it.
	protected override IVFVoxelDataSource CreateDataSource(int width, int height, int depth, float isolevel)
	{
		// base.CreateDataSource(...) would do the same thing.
		return new VFSimpleVoxelDataSource(width, height, depth, isolevel);
	}
	
}
