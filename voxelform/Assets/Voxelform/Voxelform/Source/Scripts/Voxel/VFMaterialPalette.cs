/* Author: Mark Davis
 * 
 * The material palette is used by VFVoxelTerrain and VFVoxelTerrainChunks
 * to store and provide volumetric materials for the various voxel types.
 * These materials are standard Unity Material objects with an attached shader
 * that supports volumetric texturing of some sort.  The materials and shaders
 * included with this package can be used as a reference for your own
 * custom materials and shaders.  Perhaps someone not affiliated with Voxelform
 * will release shaders/materials that would work well with this package.  Feel
 * free to use them.
 * 
 */

using UnityEngine;
using System.Collections;

/// <summary>
/// The material palette is used by VFVoxelTerrain and VFVoxelTerrainChunks
/// to store and provide volumetric materials for the various voxel types.
/// </summary>
/// <remarks>
/// These materials are standard Unity Material objects with an attached shader
/// that supports volumetric texturing of some sort.  The materials and shaders
/// included with this package can be used as a reference for your own
/// custom materials and shaders.  Perhaps someone not affiliated with Voxelform
/// will release shaders/materials that would work well with this package.  Feel
/// free to use them.
/// </remarks>
public class VFMaterialPalette : MonoBehaviour
{
	/// <summary>
	/// Indexed materials used to render the various voxel types. 
	/// </summary>
	/// <remarks>
	/// Any Unity Material written to correctly support volumetric texturing is acceptable.
	/// </remarks>
	public Material[] _materials;
}
