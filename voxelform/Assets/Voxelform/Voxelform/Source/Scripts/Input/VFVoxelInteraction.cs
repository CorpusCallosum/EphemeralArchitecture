/* Author: Mark Davis
 *
 * This example script can be used to provide interaction with the voxel terrain.
 * Feel free to either use this for your game or just as an example.
 * Perhaps you'll want to write your voxel alteration code and use that instead.
 * 
 * This script can be attached to any game object.
 * 
 * EditVoxels is the only method that really matters if you want to rewrite this
 * for your own purposes.  There's nothing sacred there, but it provides an
 * example for altering voxels in voxel space while raycasting in world space.
 * Everything else is just input or UI code and may not be appropriate for your game.
 * 
 */

using UnityEngine;
using System.Collections;
using Voxelform2.VoxelData;

/// <summary>
/// This example script can be used to provide interaction with the voxel terrain.
/// Feel free to either use this for your game or just as an example.
/// Perhaps you'll want to write your voxel alteration code and use that instead.
/// This script can be attached to any game object.
/// </summary>
/// <remarks>
/// EditVoxels is the only method that really matters if you want to rewrite this
/// for your own purposes.  There's nothing sacred there, but it provides an
/// example for altering voxels in voxel space while raycasting in world space.
/// Everything else is just input or UI code and may not be appropriate for your game.
/// </remarks>
public class VFVoxelInteraction : MonoBehaviour
{
	/// <summary>
	/// For the purposes of this example, a voxel brush can either be a box or a sphere. 
	/// </summary>
	public enum VoxelBrushType { Box, Sphere };
	
	/// <summary>
	/// The voxel terrain that this script will alter.  This value must be set to a valid object.
	/// </summary>
	public VFVoxelTerrain _terrain;
	
	/// <summary>
	/// Rate at which to alter voxels while digging.
	/// </summary>
	public float _diggingPower = .0225f;
	
	/// <summary>
	/// Rate at which to alter voxels while building. 
	/// </summary>
	public float _buildingPower = .0225f;
	
	/// <summary>
	/// Distance to cast ray (for voxel alteration) in world space. 
	/// </summary>
	public float _raycastDistance = 256f;
	
	/// <summary>
	/// Indexed material type.  Refers to materials indexed in the material palette. 
	/// </summary>
	public int _voxelType = 0;
	
	/// <summary>
	/// For the purposes of this example, a voxel brush can either be a box or a sphere.
	/// </summary>
	public VoxelBrushType _voxelBrushType = VoxelBrushType.Sphere;
	
	/// <summary>
	/// Used for scroll wheel support, to allow variable shaping power.
	/// </summary>
	float _voxrayPower = 2f;
	
	/// <summary>
	/// Reference to an object containing the material palette script.
	/// Set internally.
	/// </summary>
	VFMaterialPalette _materialPalette;
	
	/// <summary>
	/// Reference to the "Palette Objects" game object in at least one example.
	/// This is the container object for the visible material spheres in the example.
	/// </summary>
	GameObject _paletteObjects;
	
	/// <summary>
	/// Visible material spheres in at least one example.
	/// </summary>
	GameObject[] _materialObjects;
	
	/// <summary>
	/// Use this for initialization
	/// </summary>
	void Start()
	{
		if (_terrain == null)
		{
			Debug.LogError("VFVoxelInteraction Voxel Terrain property must be set.");
			return;
		}
		
		_materialPalette = _terrain._materialPalette;
		
		// Used in an example demo, but not required.
		_paletteObjects = GameObject.Find("Palette Objects");
		var paletteObject0 = GameObject.Find("Palette Object");
		
		if ((_paletteObjects != null) && (paletteObject0 != null))
		{	
			_materialObjects = new GameObject[_materialPalette._materials.Length];
			
			for (int i = 0; i < _materialObjects.Length; ++i)
			{
				_materialObjects[i] = (i == 0) ? paletteObject0 : (GameObject)Instantiate(paletteObject0);
				_materialObjects[i].renderer.material = _materialPalette._materials[i];
				_materialObjects[i].transform.parent = _paletteObjects.transform;
				_materialObjects[i].transform.localPosition = new Vector3(i * .2f, -.5f, 1f);
				float scale = 1f / (Mathf.Abs(_materialObjects[i].transform.position.x * .25f) + .01f);
				_materialObjects[i].transform.localScale = new Vector3(scale, scale, scale);
			}
		}
		
	}

	/// <summary>
	/// Update is called once per frame.
	/// Handles queue processing and mouse button input.
	/// </summary>
	void Update()
	{
		if (_terrain == null) return;
		if (_materialPalette == null) return;
		if (_materialPalette._materials.Length == 0) return;
		
		// Scrollwheel support, for variable shaping power.
		float wheelDelta = Input.GetAxis("Mouse ScrollWheel");
		
		if (wheelDelta != 0f)
		{
			AdjustRayPower(Mathf.Sign(wheelDelta));
		}

		// Mouse buttons allow terrain manipulation.

		bool md0 = Input.GetMouseButton(0);
		bool md1 = Input.GetMouseButton(1);

		if (md0 || md1)
		{
			// Ensure a valid voxel type in case this has been inappropriately adjusted in the inspector.
			_voxelType = Mathf.Clamp(_voxelType, 0, _materialPalette._materials.Length - 1);
			
			EditVoxels(md0);
		}
		
		if (_paletteObjects != null)
		{
			_paletteObjects.transform.localPosition = new Vector3(-(float)_voxelType * .2f, -.5f, 1f);
		
			if (_materialObjects != null)
			{
				for (int i = 0; i < _materialObjects.Length; ++i)
				{
					float scale = 1f / ((Mathf.Abs(_materialObjects[i].transform.localPosition.x
						+ _paletteObjects.transform.localPosition.x) + 1f) * _materialObjects.Length / 4);
					_materialObjects[i].transform.localScale = new Vector3(scale, scale, scale);
				}
			}
		}
		
	}
	
	/// <summary>
	/// Adjusts the power used for alteration activities such as digging and building.
	/// </summary>
	private void AdjustRayPower(float power)
	{
		if (power != 0f)
		{
			_voxrayPower += power;
			_voxrayPower = Mathf.Clamp(_voxrayPower, 1f, 10f);
			float invAspectRatio = (float)Screen.height / (float)Screen.width;
			
			// The cursor isn't required, but is part of a demo.
			var cursor = GameObject.Find("Voxel Cursor");

			if (cursor != null)
			{
				cursor.transform.localScale = new Vector3(invAspectRatio, 1f, 1f) * _voxrayPower * .2f;
			}

		}
	}
	
	/// <summary>
	/// This is an example of how you might edit voxels within your game, but it's not the only way to do things.
	/// You can create your own methods either using AlterVoxel or write your own low level manipulation code.
	/// </summary>
	private void EditVoxels(bool digMode)
	{
		RaycastHit hitInfo;
		var v = new Vector3(Screen.width / 2, Screen.height / 2);
		var ray = Camera.main.ScreenPointToRay(v);
		
		// Cast a ray in world space, and if it hits a terrain chunk, then further below,
		// the world space coordinate stored in hitInfo.point will be transformed to voxel space.
		// Once it's in voxel space, the coordinates can be used to alter voxels in the data source.
		
		if (Physics.Raycast(ray, out hitInfo, _raycastDistance))
		{
			var chunk = hitInfo.collider.gameObject.GetComponent<VFVoxelChunk>();
			
			if (chunk != null)
			{
				var terrain = chunk.Terrain;
				
				if (terrain != null)
				{
					// The distance test prevents new terrain from bumping into the character.
					// This value may need adjusting.
					if (digMode || (hitInfo.distance > terrain._scale * 1.5f))
					{
						float vrp = _voxrayPower + 2f;

						// This code has been modified to keep a reasonably constant
						// alteration rate at different isolevels.
						// Note that Mesh updates are batched for efficiency.
						// Because the collision detection (using a ray)
						// is a factor in the alteration rate, and meshes only get updated
						// once per frame, that can factor into the speed of alteration.
						
						// hitInfo.point is transformed from world space to voxel space.
						Vector3 p = (hitInfo.point / terrain._scale) - terrain.transform.localPosition / terrain._scale;
						
						// Safely read the voxel from the data source using the voxel space coordinate.
						VFVoxel voxel = terrain.Voxels.SafeRead((int)p.x, (int)p.y, (int)p.z);
						
						// Set the voxel's material index, aka type.
						if (!digMode) voxel.Type = (ushort)_voxelType;
						
						// This is the amount to alter the voxel this frame in either direction.
						float alterationPower = ((Time.deltaTime + Time.deltaTime * terrain._isolevel)
							* (digMode ? _diggingPower : _buildingPower) / terrain._isolevel) * 5f;
						
						// If in diging mode, then AlterVoxel methods need to know to use subtraction.
						VFFabOptions fabOptions = digMode ? VFFabOptions.EnableVolumeSubtraction : VFFabOptions.None;
						
						// AlterVoxelBox, and AlterVoxelSphere use AlterVoxel internally.  Feel free to create
						// your own "brush" methods.
						
						if (_voxelBrushType == VoxelBrushType.Box)
						{
							vrp *= 2f;
							terrain.AlterVoxelBox(p, vrp, vrp, vrp, alterationPower, voxel.Type, fabOptions);
						}
						else if (_voxelBrushType == VoxelBrushType.Sphere)
						{
							terrain.AlterVoxelSphere(p, vrp, alterationPower, voxel.Type, fabOptions);
						}

					}
				}
			}
		}

	}
	
	/// <summary>
	/// Decrements the voxel type which is an index into an array of materials.
	/// May be called via external messaging.
	/// </summary>
	public void DecrementVoxelType()
	{
		if (_voxelType > 0) _voxelType -= 1;
	}
	
	/// <summary>
	/// Increments the voxel type which is an index into an array of materials.
	/// May be called via external messaging.
	/// </summary>
	public void IncrementVoxelType()
	{
		if (_voxelType < _materialPalette._materials.Length - 1) _voxelType += 1;
	}
	
	/// <summary>
	/// Sets the voxel type which is an index into an array of materials.
	/// May be called via external messaging.
	/// </summary>
	public void SetVoxelType(ushort type)
	{
		_voxelType = type;
	}

}

