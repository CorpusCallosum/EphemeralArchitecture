/* Author: Mark Davis
 * 
 * This is the base class of the example scripts that you would attach to a voxel terrain object in your scene.
 * 
 */

using UnityEngine;
using System.Collections;

/// <summary>
/// This is the base class of the example scripts that you would attach to a voxel terrain object in your scene.
/// </summary>
public abstract class VFVoxelTerrainBaseExample : VFVoxelTerrain
{
	
	void OnApplicationFocus(bool focus)
	{
		if (focus)
		{
			StartCoroutine(LockCursor());
		}
	}

	IEnumerator LockCursor()
	{
		yield return new WaitForSeconds(0.25f);
		Screen.lockCursor = true;
	}
	
}

