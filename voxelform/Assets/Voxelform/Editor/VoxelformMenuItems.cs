/* Author: Mark Davis
 * 
 * This is the main Voxelform menu available in the editor.
 * 
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;
using UnityEditor;

/// <summary>
/// This is the main Voxelform menu available in the editor. 
/// </summary>
class VoxelformMenuItems : Editor
{
	static string _fullPath = null;
	
	[MenuItem("Voxelform/Create Voxel Terrain")]
	static void CreateVoxelTerrain()
	{
		ScriptableWizard.DisplayWizard<VFVoxelTerrainWizard>("Create Voxel Terrain");
	}
	
	[MenuItem("Voxelform/Create Material Palette")]
	static void CreateMaterialPalette()
	{
		GameObject palette = new GameObject("Material Palette");
		palette.AddComponent<VFMaterialPalette>();
	}
	
	[MenuItem("Voxelform/Edit Voxel Terrain (Requires Unity Pro)")]
	static void EditVoxelTerrain()
	{
		VFProEditor.ShowWindow();
	}
	
	[MenuItem ("Voxelform/Load Voxel Terrain")]
	static void LoadVoxelTerrain()
	{
		var terrain = GameObject.Find("Voxel Terrain").GetComponent<VFVoxelTerrain>();
		
		_fullPath = EditorUtility.OpenFilePanel("Load Voxel Terrain", "", "voxelform");

		if (_fullPath.Length > 0)
		{
			terrain.LoadVoxels(_fullPath);
		}

	}

	[MenuItem("Voxelform/Save Voxel Terrain")]
	static void SaveVoxelTerrain()
	{
		var terrain = GameObject.Find("Voxel Terrain").GetComponent<VFVoxelTerrain>();

		if (_fullPath == null)
		{
			SaveVoxelTerrainAs();
		}
		else
		{
			terrain.SaveRawVoxels(_fullPath);
		}
	}

	[MenuItem("Voxelform/Save Voxel Terrain as...")]
	static void SaveVoxelTerrainAs()
	{
		var terrain = GameObject.Find("Voxel Terrain").GetComponent<VFVoxelTerrain>();
		
		_fullPath = EditorUtility.SaveFilePanel("Save Voxel Terrain", "", "terrain", "voxelform");
		
		if (_fullPath.Length > 0)
		{
			terrain.SaveRawVoxels(_fullPath);
		}
	}

}
