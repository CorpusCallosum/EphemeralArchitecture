/* Author: Mark Davis
 * 
 * This wizard simplifies the process of creating and setuping up voxel terrain.
 * The feature to generate terrain from a heightmap was cut, and will be added back later.
 * 
 */

using UnityEditor;
using UnityEngine;
using System.Collections;

/// <summary>
/// This wizard simplifies the process of creating and setuping up voxel terrain.
/// </summary>
public class VFVoxelTerrainWizard : ScriptableWizard
{
	public string _systemTypeName = "VFVoxelTerrainExampleGenerateVoxels";
	//string _name = "Voxel Terrain";
	public VFMaterialPalette _materialPalette;
	
	// todo: reimplement this
	Texture2D _optionalHeightmapTexture = null;
	
	public int _terrainWidthInVoxels = 64;
	public int _terrainHeightInVoxels = 24;
	public int _terrainDepthInVoxels = 64;
	public int _chunkWidthInVoxels = 8;
	public int _chunkHeightInVoxels = 8;
	public int _chunkDepthInVoxels = 8;
	public float _scale = 2f;
	
	void OnWizardUpdate()
	{
		this.minSize = new Vector2(544, 280);
		
		this.helpString = ((_optionalHeightmapTexture == null)
			? "Create an empty voxel Terrain object."
			: "Create a voxel terrain object from a heightmap texture.")
			+ "\nNote: Total voxel dimensions will be truncated to fit within chunk dimensions.";
		
		_terrainWidthInVoxels = Mathf.Clamp(_terrainWidthInVoxels, 4, 512);
		_terrainHeightInVoxels = Mathf.Clamp(_terrainHeightInVoxels, 4, 512);
		_terrainDepthInVoxels = Mathf.Clamp(_terrainDepthInVoxels, 4, 512);
		
		_chunkWidthInVoxels = Mathf.Clamp(_chunkWidthInVoxels, 4, 16);
		_chunkHeightInVoxels = Mathf.Clamp(_chunkHeightInVoxels, 4, 16);
		_chunkDepthInVoxels = Mathf.Clamp(_chunkDepthInVoxels, 4, 16);
		
		if (_chunkWidthInVoxels > 0) _terrainWidthInVoxels = (_terrainWidthInVoxels / _chunkWidthInVoxels) * _chunkWidthInVoxels;
		if (_chunkHeightInVoxels > 0) _terrainHeightInVoxels = (_terrainHeightInVoxels / _chunkHeightInVoxels) * _chunkHeightInVoxels;
		if (_chunkDepthInVoxels > 0) _terrainDepthInVoxels = (_terrainDepthInVoxels / _chunkDepthInVoxels) * _chunkDepthInVoxels;
		
		this.isValid = (_materialPalette != null);
		
		this.errorString = this.isValid ? "" : "Material Palette must be set.";
		
	}
	
	void OnWizardCreate()
	{
		GameObject terrainGameObject = new GameObject("Voxel Terrain"); //_name);
		VFVoxelTerrain terrain = (VFVoxelTerrain)terrainGameObject.AddComponent(_systemTypeName);
		
		terrain._enableQueuing = true;
		terrain._enableSingleFrameLoading = true;
		terrain._isolevel = .5f;
		terrain._observer = Camera.main;
		terrain._observerViewingDistance = _scale * 250f;
		
		terrain._numVoxelsPerXAxis = _chunkWidthInVoxels;
		terrain._numVoxelsPerYAxis = _chunkHeightInVoxels;
		terrain._numVoxelsPerZAxis = _chunkDepthInVoxels;
		
		terrain._xChunkCount = _terrainWidthInVoxels / _chunkWidthInVoxels;
		terrain._yChunkCount = _terrainHeightInVoxels / _chunkHeightInVoxels;
		terrain._zChunkCount = _terrainDepthInVoxels / _chunkDepthInVoxels;
		
		terrain._materialPalette = _materialPalette;
		terrain._scale = _scale;
	}
	
}

