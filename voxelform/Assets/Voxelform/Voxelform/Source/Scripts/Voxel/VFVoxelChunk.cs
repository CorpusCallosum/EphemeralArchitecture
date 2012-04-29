/*  Author: Mark Davis
 *  
 *  Implements and manages voxel terrain chunks using the marching cubes algorithm.
 *  As of version 2.0, multimaterial chunks are supported.
 *  
 *  Marching cubes is an algorithm commonly used for MRI visualization,
 *  and also for metaballs rendering in popular 3D modeling packages.
 * 
 *  Some of this source is based on Paul Bourke's marching cubes example.
 *  While not required, it would be helpful to understand the marching cubes algorithm.
 *  
 *  I highly recommend reading his paper at:
 *  http://local.wasp.uwa.edu.au/~pbourke/geometry/polygonise/
 *  
 *  See also:
 *  http://en.wikipedia.org/wiki/Marching_cubes
 *  http://http.developer.nvidia.com/GPUGems3/gpugems3_ch01.html
 *  
 */

using CyclopsFramework.Core;
using CyclopsFramework.Actions.Flow;
using CyclopsFramework.Core.Easing;

using System.Collections;
using System.Collections.Generic;
using System.Linq;

using UnityEngine;

using Voxelform2.VoxelData;

/// <summary>
/// Used to cleanly pass voxel information for interpolation to <see cref="VertexInterp"/>.
/// </summary>
internal struct VoxelInterpolationInfo
{
	public int X;
	public int Y;
	public int Z;
	public float Volume;
	public ushort VType;
	
	public VoxelInterpolationInfo(int x, int y, int z, float volume, ushort vtype)
	{
		X = x;
		Y = y;
		Z = z;
		Volume = volume;
		VType = vtype;
	}
	
}

/// <summary>
/// Implements and manages voxel terrain chunks using the Marching Cubes algorithm. 
/// </summary>
[ExecuteInEditMode()]
public class VFVoxelChunk : MonoBehaviour
{
	// Stores the number of voxels per axis.
	int _numVoxelsXAxis;
	int _numVoxelsYAxis;
	int _numVoxelsZAxis;
		
	// Position within the VFVoxelTerrain chunk coordinate system, not the world.
	Vector3 _position;
	
	// Provides position within the VFVoxelTerrain chunk coordinate system, not the world.
	// See Position Property.
	int _positionX;
	int _positionY;
	int _positionZ;
			
	/// <summary>
	/// Provides position within the VFVoxelTerrain chunk coordinate system, not the world.
	/// </summary>
	public Vector3 Position
	{
		get
		{
			return _position;
		}
		
		set
		{
			_position = value;
			_positionX = Mathf.FloorToInt(_position.x);
			_positionY = Mathf.FloorToInt(_position.y);
			_positionZ = Mathf.FloorToInt(_position.z);
		}
	}
	
	// Used to create a unique ID for each chunk.
	// This used for the chunk's name.
	static int _nextChunkID = 0;
	
	// Need to know if this object has already been destroyed,
	// because certain methods could still be called.
	private bool _wasDestroyed = false;

	// Used to calculate vertex location.
	float _scale;
	
	// Parenting VoxelTerrain.
	VFVoxelTerrain _terrain;
	public VFVoxelTerrain Terrain { get { return _terrain; } }
	
	// The full set of voxels from parenting VFVoxelTerrain.
	// This contains voxels for all chunks.
	// In addition to being used for voxels within this chunk,
	// it's also used for calculations involving voxels in neighboring chunks.
	IVFVoxelDataSource _voxels;

	// The mesh used by this chunk.
	Mesh _mesh;
	
	// Active status for each submesh used within the mesh.
	bool[] _activeSubmeshes;
	
	// Number of submeshes within the mesh.
	int _numSubmeshes = 0;
	
	// Indices for each submesh.
	List<int[]> _subindices = new List<int[]>();
	
	// Arrays for used for rebuilding the mesh.
	Vector3[] _vertices;
    Vector3[] _normals;
	Vector2[] _uv;
    int[] _indices;
	
	// Lists used for rebuilding the mesh.
	List<Vector3> _normalList = new List<Vector3>();
	List<Vector3> _vertexList = new List<Vector3>();
	List<Vector2> _uvList = new List<Vector2>();
	List<int> _indexList = new List<int>();
	List<Material> _materials = new List<Material>();
	
	// Used by GetTriangles to reduce vertex count.
	// Only incremented if a vertex is unique.
	int _baseIndex = 0;
	
	// Used and reused by GetTriangles to build a group of triangles.
	Vector3[] _tmpVertices = new Vector3[12];
	Vector3[] _tmpNormals = new Vector3[12];
	
	/// <summary>
	/// A chunk becomes dirty when changes occur to it or a neighbor and this is a signal to enable a rebuild.
	/// </summary>
	/// <remarks>
	/// A neighbor can cause a chunk to become dirty because vertex normals need to be recalculated
	/// when a neighbor changes.  Rebuild time is dependant on chunk size,
	/// and it's important to remember that neighbors are included in that process.
	/// </remarks>
	public bool IsDirty { get; set; }
	
	/// <summary>
	/// Use to initalize a VFVoxelChunk one time only as the VFVoxelTerrain is being built. 
	/// </summary>
	public void Init(VFVoxelTerrain terrain, Vector3 position, int numVoxelsXAxis, int numVoxelsYAxis, int numVoxelsZAxis, float scale)
	{
		_terrain = terrain;
		
		_voxels = terrain.Voxels;

		_numVoxelsXAxis = numVoxelsXAxis;
		_numVoxelsYAxis = numVoxelsYAxis;
		_numVoxelsZAxis = numVoxelsZAxis;
		
		_scale = scale;

		Reposition(position);
		
		// Note: _nextChunkID is a unique static ID.
		gameObject.name = "Chunk" + _nextChunkID++;
		
		_mesh = new Mesh();
		gameObject.GetComponent<MeshFilter>().sharedMesh = null;
		gameObject.GetComponent<MeshFilter>().sharedMesh = _mesh;
		
		_activeSubmeshes = new bool[terrain.Materials.Length];
		
		/*
		 * Checks visibility based on VFVoxelTerrain's _observerViewingDistance.
		 * The random values help to distribute load across frames.
		 * Load is also balanced by the queues.
		 * 
		 * Note the use of the Cyclops Framework.  It provides functionality similar to co-routines,
		 * but without the restrictions (like use within the editor), and a LOT more functionality.
		 * This is the first public release of the C# version of this framework.
		 * A "batteries included" AS3 version has been available since 2010, and used in commercial games.
		 * The C# version is bare bones, but will likely pick up some "batteries" in the future.
		 * 
		 * Starts an action that calls CheckVisibility with period of .25f seconds or more, and is set to repeat forever.
		 * It carries a tag of "CheckVisibility" and can be messaged/controlled via that tag.
		 */
		
		_terrain.Engine.Add(new CFFunction(.25f + Random.value * .125f, float.MaxValue, CheckVisibility)).AddTag("CheckVisibility");
		
	}
	
	/// <summary>
	/// Re/positions the chunk to new coordinates.
	/// Used internally, and may be used for more tasks in the future... or not.
	/// </summary>
	public void Reposition(Vector3 position)
	{
		_position = position;

		Vector3 nv = new Vector3(_numVoxelsXAxis, _numVoxelsYAxis, _numVoxelsZAxis);

		nv.x *= _position.x;
		nv.y *= _position.y;
		nv.z *= _position.z;

		_positionX = (int)nv.x;
		_positionY = (int)nv.y;
		_positionZ = (int)nv.z;

		transform.localPosition = nv * _scale;

	}
	
	/// <summary>
	/// Rebuilds a mesh.  Called when it's dirty.
	/// </summary>
	public void RebuildMesh()
	{
		if (_wasDestroyed) return;
		
		// This was split into two steps for potential future use.
		// Note that in step 1, data manipulation doesn't rely on the Unity API.
		// In step 2, the Unity API is essential.
		// There is some optimization potential here, but whether it makes
		// enough of a difference to justify complication will have to be seen.
		// I prefer to error on the side of readability and flexible use.
		
		RebuildMeshStep1();
		RebuildMeshStep2();
		
	}
	
	/// <summary>
	/// Rebuilds a mesh (Step 1).  Called when it's dirty.
	/// In this step, the Unity API is not relied upon.
	/// </summary>
	void RebuildMeshStep1()
	{
		if (_wasDestroyed) return;

		// Hook this back up in case it's changed due to a load.
		// Retaining direct reference for speed.
		_voxels = _terrain.Voxels;

		_numSubmeshes = 0;
		
		if (_activeSubmeshes.Length	!= _terrain.Materials.Length)
		{
			_activeSubmeshes = new bool[_terrain.Materials.Length];
		}

		for (int i = 0; i < _activeSubmeshes.Length; ++i)
		{
			_activeSubmeshes[i] = false;
		}

		_materials.Clear();

		List<ushort> materialOrder = new List<ushort>();
		
		// Check material types.
		for (int pz = -1; pz <= _numVoxelsZAxis; ++pz)
		{
			for (int py = -1; py <= _numVoxelsYAxis; ++py)
			{
				for (int px = -1; px <= _numVoxelsXAxis; ++px)
				{
					VFVoxel voxel = _terrain.Voxels.SafeRead(_positionX + px, _positionY + py, _positionZ + pz);
					ushort typeIndex = voxel.Type;
					if (!_activeSubmeshes[typeIndex])
					{
						_activeSubmeshes[typeIndex] = true;
						_materials.Add(_terrain.Materials[typeIndex]);
						materialOrder.Add(typeIndex); 
						++_numSubmeshes;
					}
				}
			}
		}
				
		_vertexList.Clear();
		_uvList.Clear();
		_normalList.Clear();

		_baseIndex = 0;
		
		_subindices.Clear();
		
		foreach (int meshIndex in materialOrder)
		{
			// The normalized minimum voxel volume required to create the surface.
			float isolevel = Mathf.Clamp(_terrain._isolevel, .01f, .99f);

			for (int pz = 0; pz < _numVoxelsZAxis; ++pz)
			{
				for (int py = 0; py < _numVoxelsYAxis; ++py)
				{
					for (int px = 0; px < _numVoxelsXAxis; ++px)
					{
						// This is the core of the Marching Cubes algorithm.
						GetTriangles(px, py, pz, isolevel, meshIndex);
					}
				}
			}

			_subindices.Add(_indexList.ToArray());
			_indexList.Clear();
		}
	}
	
	/// <summary>
	/// Rebuilds a mesh (Step 2).  Called when it's dirty.
	/// In this step, use of the Unity API is essential.
	/// </summary>
	void RebuildMeshStep2()
	{
		if (_wasDestroyed) return;
				
		_mesh.Clear();
		
		_mesh.vertices = _vertexList.ToArray();
		_mesh.uv = _uvList.ToArray();
		
		gameObject.renderer.materials = _materials.ToArray();

		_mesh.subMeshCount = _numSubmeshes;

		for (int i = 0; i < _subindices.Count; ++i)
		{
			_mesh.SetTriangles(_subindices[i], i);
		}
		
		// Here we have Unity recalculating normals even though we've already calculated them
		// using the isosurface... why?  The isosurface normals are usually correct, but not always.
		// Unity however, does a nice job of calculating normals for us, but with individual triangles,
		// this shading is flat, and that doesn't look good either.
		//
		// To work around this, the calculations are blended.  If you don't like the weighting or easing,
		// feel free to change it, or rip this out completely.
		//
		// If you're wondering why what you're working with is essentially an indexed triangle list where
		// vertices aren't shared, it has to do with the shading along chunk edges.
		// Seams would be visible as lighting calculations would be off on the edges.
		
		// If you would prefer the quicker, less accurate, but smoothly shaded functionality,
		// then enable the next line below, and disable the rest of the normal calculation code that follows:
		//_mesh.normals = _normalList.ToArray();
		
		_mesh.RecalculateNormals();
		
		var normals = _mesh.normals;
		int numNormals = _mesh.normals.Length;
		
		for (int i = 0; i < numNormals; ++i)
		{
			Vector3 n1 = _normalList[i].normalized;
			Vector3 n2 = normals[i].normalized;
			Vector3 n3 = n1 - n2;

			float dx = Mathf.Abs(n3.x);
			float dy = Mathf.Abs(n3.y);
			float dz = Mathf.Abs(n3.z);

			Vector3 result;
			
			// Please feel free to change this setting.
			// 0 will produce smooth shaded surfaces with some dark shading artifacts.
			// 1 will produce flat shaded surfaces with no shading artifacts.
			const float smoothShadingWeight = .3f; // range: 0..1

			result.x = Mathf.Lerp(n1.x, n2.x, CFBias.EaseOut(dx - smoothShadingWeight));
			result.y = Mathf.Lerp(n1.y, n2.y, CFBias.EaseOut(dy - smoothShadingWeight));
			result.z = Mathf.Lerp(n1.z, n2.z, CFBias.EaseOut(dz - smoothShadingWeight));
			
			normals[i] = result;

		}

		_mesh.normals = normals;
		
#if UNITY_EDITOR
		if (Application.isPlaying)
		{
			GetComponent<MeshCollider>().sharedMesh = null;
			GetComponent<MeshCollider>().sharedMesh = _mesh;
		}
#else
		GetComponent<MeshCollider>().sharedMesh = null;
		GetComponent<MeshCollider>().sharedMesh = _mesh;
#endif

	}
	
	/// <summary>
	/// Adds triangle information to the appropriate lists using the marching cubes algorithm. 
	/// </summary>
	void GetTriangles(int x, int y, int z, float isolevel, int vtype)
	{
		int px = _positionX + x;
		int py = _positionY + y;
		int pz = _positionZ + z;

		if (px < 0) px = 0;
		if (py < 0) py = 0;
		if (pz < 0) pz = 0;
		
		// Exit if surrounded by (and is) either all solid or all empty.
		
		VFVoxel voxel0 = _voxels.Read(px, py, pz);
		VFVoxel voxel6 = _voxels.Read(px + 1, py + 1, pz + 1);
		
		// Take a look at VFSimpleVoxelDataSource.Flush to get a better idea of how this works.
		if (voxel0.FullyUnenclosed() && voxel6.FullyUnenclosed()) return;
		if (voxel0.FullyEnclosed() && voxel6.FullyEnclosed()) return;
		
		// Otherwise, continue...
		
		VFVoxel voxel1 = _voxels.Read(px + 1, py, pz);
		VFVoxel voxel2 = _voxels.Read(px + 1, py + 1, pz);
		VFVoxel voxel3 = _voxels.Read(px, py + 1, pz);
		VFVoxel voxel4 = _voxels.Read(px, py, pz + 1);
		VFVoxel voxel5 = _voxels.Read(px + 1, py, pz + 1);
		VFVoxel voxel7 = _voxels.Read(px, py + 1, pz + 1);
		
		// Setup data for use by VertexInterp.
		
		VoxelInterpolationInfo val0 = new VoxelInterpolationInfo(px, py, pz, voxel0.Volume, voxel0.Type);
		VoxelInterpolationInfo val1 = new VoxelInterpolationInfo(px + 1, py, pz, voxel1.Volume, voxel1.Type);
		VoxelInterpolationInfo val2 = new VoxelInterpolationInfo(px + 1, py + 1, pz, voxel2.Volume, voxel2.Type);
		VoxelInterpolationInfo val3 = new VoxelInterpolationInfo(px, py + 1, pz, voxel3.Volume, voxel3.Type);
		VoxelInterpolationInfo val4 = new VoxelInterpolationInfo(px, py, pz + 1, voxel4.Volume, voxel4.Type);
		VoxelInterpolationInfo val5 = new VoxelInterpolationInfo(px + 1, py, pz + 1, voxel5.Volume, voxel5.Type);
		VoxelInterpolationInfo val6 = new VoxelInterpolationInfo(px + 1, py + 1, pz + 1, voxel6.Volume, voxel6.Type);
		VoxelInterpolationInfo val7 = new VoxelInterpolationInfo(px, py + 1, pz + 1, voxel7.Volume, voxel7.Type);

		// Each corner is mapped to 1 bit in an 8-bit value.
		// This creates 256 possibilities, which are stored in a lookup table (EOF).

		int cubeindex = 0;
		
		// This value is used to tighten up graphics a little bit.
		// Had to say that... actually it tightens up the gap between submeshes.
		float isofix = isolevel * .95f;
		
		if (val0.VType != vtype)
		{
			if (val0.Volume >= isofix) val0.Volume = isofix;
		}
		else if (val0.Volume >= isolevel)
		{
			cubeindex |= 1;
		}
		
		if (val1.VType != vtype)
		{
			if (val1.Volume >= isofix) val1.Volume = isofix;
		}
		else if (val1.Volume >= isolevel)
		{
			cubeindex |= 2;
		}
		
		if (val2.VType != vtype)
		{
			if (val2.Volume >= isofix) val2.Volume = isofix;
		}
		else if (val2.Volume >= isolevel)
		{
			cubeindex |= 4;
		}
		
		if (val3.VType != vtype)
		{
			if (val3.Volume >= isofix) val3.Volume = isofix;
		}
		else if (val3.Volume >= isolevel)
		{
			cubeindex |= 8;
		}
		
		if (val4.VType != vtype)
		{
			if (val4.Volume >= isofix) val4.Volume = isofix;
		}
		else if (val4.Volume >= isolevel)
		{
			cubeindex |= 16;
		}
		
		if (val5.VType != vtype)
		{
			if (val5.Volume >= isofix) val5.Volume = isofix;
		}
		else if (val5.Volume >= isolevel)
		{
			cubeindex |= 32;
		}
		
		if (val6.VType != vtype)
		{
			if (val6.Volume >= isofix) val6.Volume = isofix;
		}
		else if (val6.Volume >= isolevel)
		{
			cubeindex |= 64;
		}
		
		if (val7.VType != vtype)
		{
			if (val7.Volume >= isofix) val7.Volume = isofix;
		}
		else if (val7.Volume >= isolevel)
		{
			cubeindex |= 128;
		}
						
		// If there's nothing to build, then exit.

		if (_edgeTable[cubeindex] == 0)
		{
			return;
		}

		// 8 corners of the cube.
		
		float fx = (float)x;
		float fy = (float)y;
		float fz = (float)z;
		
		Vector3 p0 = new Vector3(fx, fy, fz);
		Vector3 p1 = new Vector3(fx + 1, fy, fz);
		Vector3 p2 = new Vector3(fx + 1, fy + 1, fz);
		Vector3 p3 = new Vector3(fx, fy + 1, fz);
		Vector3 p4 = new Vector3(fx, fy, fz + 1);
		Vector3 p5 = new Vector3(fx + 1, fy, fz + 1);
		Vector3 p6 = new Vector3(fx + 1, fy + 1, fz + 1);
		Vector3 p7 = new Vector3(fx, fy + 1, fz + 1);
		
		// Begin building the triangles from the lookup tables.

		if ((_edgeTable[cubeindex] & 1) > 0)
		{
			_tmpVertices[0] = VertexInterp(isolevel, p0, p1, val0, val1, 0);
		}
		if ((_edgeTable[cubeindex] & 2) > 0)
		{
			_tmpVertices[1] = VertexInterp(isolevel, p1, p2, val1, val2, 1);
		}
		if ((_edgeTable[cubeindex] & 4) > 0)
		{
			_tmpVertices[2] = VertexInterp(isolevel, p2, p3, val2, val3, 2);
		}
		if ((_edgeTable[cubeindex] & 8) > 0)
		{
			_tmpVertices[3] = VertexInterp(isolevel, p3, p0, val3, val0, 3);
		}
		if ((_edgeTable[cubeindex] & 16) > 0)
		{
			_tmpVertices[4] = VertexInterp(isolevel, p4, p5, val4, val5, 4);
		}
		if ((_edgeTable[cubeindex] & 32) > 0)
		{
			_tmpVertices[5] = VertexInterp(isolevel, p5, p6, val5, val6, 5);
		}
		if ((_edgeTable[cubeindex] & 64) > 0)
		{
			_tmpVertices[6] = VertexInterp(isolevel, p6, p7, val6, val7, 6);
		}
		if ((_edgeTable[cubeindex] & 128) > 0)
		{
			_tmpVertices[7] = VertexInterp(isolevel, p7, p4, val7, val4, 7);
		}
		if ((_edgeTable[cubeindex] & 256) > 0)
		{
			_tmpVertices[8] = VertexInterp(isolevel, p0, p4, val0, val4, 8);
		}
		if ((_edgeTable[cubeindex] & 512) > 0)
		{
			_tmpVertices[9] = VertexInterp(isolevel, p1, p5, val1, val5, 9);
		}
		if ((_edgeTable[cubeindex] & 1024) > 0)
		{
			_tmpVertices[10] = VertexInterp(isolevel, p2, p6, val2, val6, 10);
		}
		if ((_edgeTable[cubeindex] & 2048) > 0)
		{
			_tmpVertices[11] = VertexInterp(isolevel, p3, p7, val3, val7, 11);
		}
		
		for (int i = 0; _triTable[cubeindex, i] != -1; i += 3)
		{
			// Even though u,v coordinates aren't really required for this, they are still required by Unity.
			_uvList.Add(Vector2.zero);
			_uvList.Add(Vector2.zero);
			_uvList.Add(Vector2.zero);
			
			// Notice that the winding order is: 0, 2, 1
			
			_normalList.Add(_tmpNormals[_triTable[cubeindex, i]]);
			_normalList.Add(_tmpNormals[_triTable[cubeindex, i + 2]]);
			_normalList.Add(_tmpNormals[_triTable[cubeindex, i + 1]]);
			
			_vertexList.Add(_tmpVertices[_triTable[cubeindex, i]]);
			_vertexList.Add(_tmpVertices[_triTable[cubeindex, i + 2]]);
			_vertexList.Add(_tmpVertices[_triTable[cubeindex, i + 1]]);
			
			// This might seem silly, but there isn't an option to use a triangle list without indices.
			// Read up on the normal calculations to understand why vertices aren't shared.
			_indexList.Add(_baseIndex++);
			_indexList.Add(_baseIndex++);
			_indexList.Add(_baseIndex++);
		}

	}
	
	/// <summary>
	/// As a core part of the Marching Cubes aglorithm, this function calculates triangle information.
	/// </summary>
	/// <remarks>
	/// The normal calculations are customized for voxel terrain.
	/// </remarks>
	Vector3 VertexInterp(float isolevel, Vector3 p1, Vector3 p2, VoxelInterpolationInfo val1, VoxelInterpolationInfo val2, int index)
	{
		float mu = (isolevel - val1.Volume) / (val2.Volume - val1.Volume);
		
		Vector3 p = Vector3.Lerp(p1, p2, mu);
		
		int x1 = Mathf.Max(0, val1.X - 1);
		int y1 = Mathf.Max(0, val1.Y - 1);
		int z1 = Mathf.Max(0, val1.Z - 1);
		
		int x2 = Mathf.Max(0, val2.X - 1);
		int y2 = Mathf.Max(0, val2.Y - 1);
		int z2 = Mathf.Max(0, val2.Z - 1);
		
		// Calculates vertex normals from voxel volumes.
		
		// Note: This was improved in v1.1, but in order to do so,
		// this normal data is weighted, and blended with Unity's own
		// flat shaded normal calculations.  These calculations provide smooth shading
		// based on the isosurface, but with occasional inaccuracies.
		// Although these inaccuracies were tolerable for previous shaders,
		// with triplanar shaders, they cause obvious texture stretching,
		// and it's highly visible when it occurs.  The compromise is that,
		// the final shading may not be perfectly smooth, but it is weighted,
		// and so will be as smooth as possible, where ever possible.
		
		float n1x1 = _voxels.Read(x1+0,y1+1,z1+1).Volume;
		float n1x2 = _voxels.Read(x1+2,y1+1,z1+1).Volume;
		float n1y1 = _voxels.Read(x1+1,y1+0,z1+1).Volume;
		float n1y2 = _voxels.Read(x1+1,y1+2,z1+1).Volume;
		float n1z1 = _voxels.Read(x1+1,y1+1,z1+0).Volume;
		float n1z2 = _voxels.Read(x1+1,y1+1,z1+2).Volume;
		
		float n1dx = (n1x2 - n1x1);
		float n1dy = (n1y2 - n1y1);
		float n1dz = (n1z2 - n1z1);
				
		float gs = (n1dx * n1dx + n1dy * n1dy + n1dz * n1dz);
		gs = 1f / (gs * gs);
		
		n1dx = gs * (2f * (n1x1 - n1x2));
		n1dy = gs * (2f * (n1y1 - n1y2));
		n1dz = gs * (2f * (n1z1 - n1z2));
						
		Vector3 n1 = new Vector3(n1dx, n1dy, n1dz);
		
		float n2x1 = _voxels.Read(x2+0,y2+1,z2+1).Volume;
		float n2x2 = _voxels.Read(x2+2,y2+1,z2+1).Volume;
		float n2y1 = _voxels.Read(x2+1,y2+0,z2+1).Volume;
		float n2y2 = _voxels.Read(x2+1,y2+2,z2+1).Volume;
		float n2z1 = _voxels.Read(x2+1,y2+1,z2+0).Volume;
		float n2z2 = _voxels.Read(x2+1,y2+1,z2+2).Volume;
				
		float n2dx = (n2x2 - n2x1);
		float n2dy = (n2y2 - n2y1);
		float n2dz = (n2z2 - n2z1);
		
		gs = (n2dx * n2dx + n2dy * n2dy + n2dz * n2dz);
		gs = 1f / (gs * gs);
		
		n2dx = gs * (2f * (n2x1 - n2x2));
		n2dy = gs * (2f * (n2y1 - n2y2));
		n2dz = gs * (2f * (n2z1 - n2z2));
		
		Vector3 n2 = new Vector3(n2dx, n2dy, n2dz);
		
		_tmpNormals[index] = Vector3.Lerp(n1, n2, mu).normalized;
		
		return(p * _scale);
		
	}
	
	/// <summary>
	/// Called via a CFAction, this performs periodic visibility checks and allows culling of distant VFVoxelChunks.
	/// </summary>
	/// <remarks>
	/// This can provide a nice performance boost and allows for larger terrain sizes than would otherwise be possible.
	/// Note: Both the calling of CheckVisibility and the subsequent queueing are load balanced across frames.
	/// Also: OnBecameVisible and OnBecameInvisible aren't suited to this task in a general purpose way.
	/// </remarks>
	void CheckVisibility()
	{
		if (_wasDestroyed)
		{
			_terrain.Engine.Context.Stop();
			return;
		}
		
		if (_terrain == null) return;
		if (_terrain.Observer == null) return;
		
		// In case you're wondering as I was, Vector3.Distance should be faster than a custom fast distance function.
		
		if (Vector3.Distance(_terrain.Observer.transform.position, gameObject.transform.position) > _terrain._observerViewingDistance)
		{
			if (gameObject.active)
			{
				_terrain.EnqueueDeactivation(gameObject);
			}
			return;
		}
		
		if(!gameObject.active)
		{
			_terrain.EnqueueActivation(gameObject);
		}
		
	}
		
	/// <summary>
	/// Called every frame, this updates dirty chunks. 
	/// </summary>
	/// <remarks>
	/// This doesn't live in a coroutine due to sync issues with a coroutine implementation.
	/// </remarks>
	
	void Update()
	{
		if (IsDirty)
		{
			IsDirty = false;
			RebuildMesh();
		}
	}
	
	/// <summary>
	/// Used in edit mode.
	/// </summary>
	public void UpdateChunkManually()
	{
		Update();
	}

	/// <summary>
	/// Enables _mesh cleanup. 
	/// </summary>
	void OnDestroy()
	{
		_wasDestroyed = true;
		
		if (_mesh != null)
		{
			if (Application.isEditor)
			{
				Object.DestroyImmediate(_mesh);
			}
			else
			{
				Object.Destroy(_mesh);
			}
		}
	}
	
	/// <summary>
	/// Marching cubes lookup table for edges.
	/// </summary>
	static int[] _edgeTable = new int[]
	{
        0x0  , 0x109, 0x203, 0x30a, 0x406, 0x50f, 0x605, 0x70c,
        0x80c, 0x905, 0xa0f, 0xb06, 0xc0a, 0xd03, 0xe09, 0xf00,
        0x190, 0x99 , 0x393, 0x29a, 0x596, 0x49f, 0x795, 0x69c,
        0x99c, 0x895, 0xb9f, 0xa96, 0xd9a, 0xc93, 0xf99, 0xe90,
        0x230, 0x339, 0x33 , 0x13a, 0x636, 0x73f, 0x435, 0x53c,
        0xa3c, 0xb35, 0x83f, 0x936, 0xe3a, 0xf33, 0xc39, 0xd30,
        0x3a0, 0x2a9, 0x1a3, 0xaa , 0x7a6, 0x6af, 0x5a5, 0x4ac,
        0xbac, 0xaa5, 0x9af, 0x8a6, 0xfaa, 0xea3, 0xda9, 0xca0,
        0x460, 0x569, 0x663, 0x76a, 0x66 , 0x16f, 0x265, 0x36c,
        0xc6c, 0xd65, 0xe6f, 0xf66, 0x86a, 0x963, 0xa69, 0xb60,
        0x5f0, 0x4f9, 0x7f3, 0x6fa, 0x1f6, 0xff , 0x3f5, 0x2fc,
        0xdfc, 0xcf5, 0xfff, 0xef6, 0x9fa, 0x8f3, 0xbf9, 0xaf0,
        0x650, 0x759, 0x453, 0x55a, 0x256, 0x35f, 0x55 , 0x15c,
        0xe5c, 0xf55, 0xc5f, 0xd56, 0xa5a, 0xb53, 0x859, 0x950,
        0x7c0, 0x6c9, 0x5c3, 0x4ca, 0x3c6, 0x2cf, 0x1c5, 0xcc ,
        0xfcc, 0xec5, 0xdcf, 0xcc6, 0xbca, 0xac3, 0x9c9, 0x8c0,
        0x8c0, 0x9c9, 0xac3, 0xbca, 0xcc6, 0xdcf, 0xec5, 0xfcc,
        0xcc , 0x1c5, 0x2cf, 0x3c6, 0x4ca, 0x5c3, 0x6c9, 0x7c0,
        0x950, 0x859, 0xb53, 0xa5a, 0xd56, 0xc5f, 0xf55, 0xe5c,
        0x15c, 0x55 , 0x35f, 0x256, 0x55a, 0x453, 0x759, 0x650,
        0xaf0, 0xbf9, 0x8f3, 0x9fa, 0xef6, 0xfff, 0xcf5, 0xdfc,
        0x2fc, 0x3f5, 0xff , 0x1f6, 0x6fa, 0x7f3, 0x4f9, 0x5f0,
        0xb60, 0xa69, 0x963, 0x86a, 0xf66, 0xe6f, 0xd65, 0xc6c,
        0x36c, 0x265, 0x16f, 0x66 , 0x76a, 0x663, 0x569, 0x460,
        0xca0, 0xda9, 0xea3, 0xfaa, 0x8a6, 0x9af, 0xaa5, 0xbac,
        0x4ac, 0x5a5, 0x6af, 0x7a6, 0xaa , 0x1a3, 0x2a9, 0x3a0,
        0xd30, 0xc39, 0xf33, 0xe3a, 0x936, 0x83f, 0xb35, 0xa3c,
        0x53c, 0x435, 0x73f, 0x636, 0x13a, 0x33 , 0x339, 0x230,
        0xe90, 0xf99, 0xc93, 0xd9a, 0xa96, 0xb9f, 0x895, 0x99c,
        0x69c, 0x795, 0x49f, 0x596, 0x29a, 0x393, 0x99 , 0x190,
        0xf00, 0xe09, 0xd03, 0xc0a, 0xb06, 0xa0f, 0x905, 0x80c,
        0x70c, 0x605, 0x50f, 0x406, 0x30a, 0x203, 0x109, 0x0
	};
	
	/// <summary>
	/// Marching Cubes lookup table for indices.
	/// Note: -1 is a terminator.
	/// </summary>
    static int[,]  _triTable = new int[,]
        {{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 8, 3, 9, 8, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 1, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 2, 10, 0, 2, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 8, 3, 2, 10, 8, 10, 9, 8, -1, -1, -1, -1, -1, -1, -1},
        {3, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 11, 2, 8, 11, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 9, 0, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 11, 2, 1, 9, 11, 9, 8, 11, -1, -1, -1, -1, -1, -1, -1},
        {3, 10, 1, 11, 10, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 10, 1, 0, 8, 10, 8, 11, 10, -1, -1, -1, -1, -1, -1, -1},
        {3, 9, 0, 3, 11, 9, 11, 10, 9, -1, -1, -1, -1, -1, -1, -1},
        {9, 8, 10, 10, 8, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 7, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 3, 0, 7, 3, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 1, 9, 4, 7, 1, 7, 3, 1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 4, 7, 3, 0, 4, 1, 2, 10, -1, -1, -1, -1, -1, -1, -1},
        {9, 2, 10, 9, 0, 2, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1},
        {2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4, -1, -1, -1, -1},
        {8, 4, 7, 3, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 4, 7, 11, 2, 4, 2, 0, 4, -1, -1, -1, -1, -1, -1, -1},
        {9, 0, 1, 8, 4, 7, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1},
        {4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1, -1, -1, -1, -1},
        {3, 10, 1, 3, 11, 10, 7, 8, 4, -1, -1, -1, -1, -1, -1, -1},
        {1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4, -1, -1, -1, -1},
        {4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3, -1, -1, -1, -1},
        {4, 7, 11, 4, 11, 9, 9, 11, 10, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 4, 0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 5, 4, 1, 5, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 5, 4, 8, 3, 5, 3, 1, 5, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 9, 5, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 8, 1, 2, 10, 4, 9, 5, -1, -1, -1, -1, -1, -1, -1},
        {5, 2, 10, 5, 4, 2, 4, 0, 2, -1, -1, -1, -1, -1, -1, -1},
        {2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8, -1, -1, -1, -1},
        {9, 5, 4, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 11, 2, 0, 8, 11, 4, 9, 5, -1, -1, -1, -1, -1, -1, -1},
        {0, 5, 4, 0, 1, 5, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1},
        {2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5, -1, -1, -1, -1},
        {10, 3, 11, 10, 1, 3, 9, 5, 4, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10, -1, -1, -1, -1},
        {5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3, -1, -1, -1, -1},
        {5, 4, 8, 5, 8, 10, 10, 8, 11, -1, -1, -1, -1, -1, -1, -1},
        {9, 7, 8, 5, 7, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 3, 0, 9, 5, 3, 5, 7, 3, -1, -1, -1, -1, -1, -1, -1},
        {0, 7, 8, 0, 1, 7, 1, 5, 7, -1, -1, -1, -1, -1, -1, -1},
        {1, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 7, 8, 9, 5, 7, 10, 1, 2, -1, -1, -1, -1, -1, -1, -1},
        {10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3, -1, -1, -1, -1},
        {8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2, -1, -1, -1, -1},
        {2, 10, 5, 2, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1},
        {7, 9, 5, 7, 8, 9, 3, 11, 2, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11, -1, -1, -1, -1},
        {2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7, -1, -1, -1, -1},
        {11, 2, 1, 11, 1, 7, 7, 1, 5, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11, -1, -1, -1, -1},
        {5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0, -1},
        {11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0, -1},
        {11, 10, 5, 7, 11, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {10, 6, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 0, 1, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 8, 3, 1, 9, 8, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1},
        {1, 6, 5, 2, 6, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 6, 5, 1, 2, 6, 3, 0, 8, -1, -1, -1, -1, -1, -1, -1},
        {9, 6, 5, 9, 0, 6, 0, 2, 6, -1, -1, -1, -1, -1, -1, -1},
        {5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8, -1, -1, -1, -1},
        {2, 3, 11, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 0, 8, 11, 2, 0, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, 2, 3, 11, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1},
        {5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11, -1, -1, -1, -1},
        {6, 3, 11, 6, 5, 3, 5, 1, 3, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6, -1, -1, -1, -1},
        {3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9, -1, -1, -1, -1},
        {6, 5, 9, 6, 9, 11, 11, 9, 8, -1, -1, -1, -1, -1, -1, -1},
        {5, 10, 6, 4, 7, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 3, 0, 4, 7, 3, 6, 5, 10, -1, -1, -1, -1, -1, -1, -1},
        {1, 9, 0, 5, 10, 6, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1},
        {10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4, -1, -1, -1, -1},
        {6, 1, 2, 6, 5, 1, 4, 7, 8, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7, -1, -1, -1, -1},
        {8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6, -1, -1, -1, -1},
        {7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9, -1},
        {3, 11, 2, 7, 8, 4, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1},
        {5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11, -1, -1, -1, -1},
        {0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6, -1, -1, -1, -1},
        {9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6, -1},
        {8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6, -1, -1, -1, -1},
        {5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11, -1},
        {0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7, -1},
        {6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9, -1, -1, -1, -1},
        {10, 4, 9, 6, 4, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 10, 6, 4, 9, 10, 0, 8, 3, -1, -1, -1, -1, -1, -1, -1},
        {10, 0, 1, 10, 6, 0, 6, 4, 0, -1, -1, -1, -1, -1, -1, -1},
        {8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10, -1, -1, -1, -1},
        {1, 4, 9, 1, 2, 4, 2, 6, 4, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4, -1, -1, -1, -1},
        {0, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 3, 2, 8, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1},
        {10, 4, 9, 10, 6, 4, 11, 2, 3, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6, -1, -1, -1, -1},
        {3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10, -1, -1, -1, -1},
        {6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1, -1},
        {9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3, -1, -1, -1, -1},
        {8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1, -1},
        {3, 11, 6, 3, 6, 0, 0, 6, 4, -1, -1, -1, -1, -1, -1, -1},
        {6, 4, 8, 11, 6, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 10, 6, 7, 8, 10, 8, 9, 10, -1, -1, -1, -1, -1, -1, -1},
        {0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10, -1, -1, -1, -1},
        {10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0, -1, -1, -1, -1},
        {10, 6, 7, 10, 7, 1, 1, 7, 3, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7, -1, -1, -1, -1},
        {2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9, -1},
        {7, 8, 0, 7, 0, 6, 6, 0, 2, -1, -1, -1, -1, -1, -1, -1},
        {7, 3, 2, 6, 7, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7, -1, -1, -1, -1},
        {2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7, -1},
        {1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11, -1},
        {11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1, -1, -1, -1, -1},
        {8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6, -1},
        {0, 9, 1, 11, 6, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0, -1, -1, -1, -1},
        {7, 11, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 8, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 1, 9, 8, 3, 1, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1},
        {10, 1, 2, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 3, 0, 8, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1},
        {2, 9, 0, 2, 10, 9, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1},
        {6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8, -1, -1, -1, -1},
        {7, 2, 3, 6, 2, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 0, 8, 7, 6, 0, 6, 2, 0, -1, -1, -1, -1, -1, -1, -1},
        {2, 7, 6, 2, 3, 7, 0, 1, 9, -1, -1, -1, -1, -1, -1, -1},
        {1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6, -1, -1, -1, -1},
        {10, 7, 6, 10, 1, 7, 1, 3, 7, -1, -1, -1, -1, -1, -1, -1},
        {10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8, -1, -1, -1, -1},
        {0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7, -1, -1, -1, -1},
        {7, 6, 10, 7, 10, 8, 8, 10, 9, -1, -1, -1, -1, -1, -1, -1},
        {6, 8, 4, 11, 8, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 6, 11, 3, 0, 6, 0, 4, 6, -1, -1, -1, -1, -1, -1, -1},
        {8, 6, 11, 8, 4, 6, 9, 0, 1, -1, -1, -1, -1, -1, -1, -1},
        {9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6, -1, -1, -1, -1},
        {6, 8, 4, 6, 11, 8, 2, 10, 1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6, -1, -1, -1, -1},
        {4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9, -1, -1, -1, -1},
        {10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3, -1},
        {8, 2, 3, 8, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1},
        {0, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8, -1, -1, -1, -1},
        {1, 9, 4, 1, 4, 2, 2, 4, 6, -1, -1, -1, -1, -1, -1, -1},
        {8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1, -1, -1, -1, -1},
        {10, 1, 0, 10, 0, 6, 6, 0, 4, -1, -1, -1, -1, -1, -1, -1},
        {4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3, -1},
        {10, 9, 4, 6, 10, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 5, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 4, 9, 5, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1},
        {5, 0, 1, 5, 4, 0, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1},
        {11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5, -1, -1, -1, -1},
        {9, 5, 4, 10, 1, 2, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1},
        {6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5, -1, -1, -1, -1},
        {7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2, -1, -1, -1, -1},
        {3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6, -1},
        {7, 2, 3, 7, 6, 2, 5, 4, 9, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7, -1, -1, -1, -1},
        {3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0, -1, -1, -1, -1},
        {6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8, -1},
        {9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7, -1, -1, -1, -1},
        {1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4, -1},
        {4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10, -1},
        {7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10, -1, -1, -1, -1},
        {6, 9, 5, 6, 11, 9, 11, 8, 9, -1, -1, -1, -1, -1, -1, -1},
        {3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5, -1, -1, -1, -1},
        {0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11, -1, -1, -1, -1},
        {6, 11, 3, 6, 3, 5, 5, 3, 1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6, -1, -1, -1, -1},
        {0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10, -1},
        {11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5, -1},
        {6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3, -1, -1, -1, -1},
        {5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2, -1, -1, -1, -1},
        {9, 5, 6, 9, 6, 0, 0, 6, 2, -1, -1, -1, -1, -1, -1, -1},
        {1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8, -1},
        {1, 5, 6, 2, 1, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6, -1},
        {10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0, -1, -1, -1, -1},
        {0, 3, 8, 5, 6, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {10, 5, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 5, 10, 7, 5, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 5, 10, 11, 7, 5, 8, 3, 0, -1, -1, -1, -1, -1, -1, -1},
        {5, 11, 7, 5, 10, 11, 1, 9, 0, -1, -1, -1, -1, -1, -1, -1},
        {10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1, -1, -1, -1, -1},
        {11, 1, 2, 11, 7, 1, 7, 5, 1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11, -1, -1, -1, -1},
        {9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7, -1, -1, -1, -1},
        {7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2, -1},
        {2, 5, 10, 2, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1},
        {8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5, -1, -1, -1, -1},
        {9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2, -1, -1, -1, -1},
        {9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2, -1},
        {1, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 7, 0, 7, 1, 1, 7, 5, -1, -1, -1, -1, -1, -1, -1},
        {9, 0, 3, 9, 3, 5, 5, 3, 7, -1, -1, -1, -1, -1, -1, -1},
        {9, 8, 7, 5, 9, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {5, 8, 4, 5, 10, 8, 10, 11, 8, -1, -1, -1, -1, -1, -1, -1},
        {5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0, -1, -1, -1, -1},
        {0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5, -1, -1, -1, -1},
        {10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4, -1},
        {2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8, -1, -1, -1, -1},
        {0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11, -1},
        {0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5, -1},
        {9, 4, 5, 2, 11, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4, -1, -1, -1, -1},
        {5, 10, 2, 5, 2, 4, 4, 2, 0, -1, -1, -1, -1, -1, -1, -1},
        {3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9, -1},
        {5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2, -1, -1, -1, -1},
        {8, 4, 5, 8, 5, 3, 3, 5, 1, -1, -1, -1, -1, -1, -1, -1},
        {0, 4, 5, 1, 0, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5, -1, -1, -1, -1},
        {9, 4, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 11, 7, 4, 9, 11, 9, 10, 11, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11, -1, -1, -1, -1},
        {1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11, -1, -1, -1, -1},
        {3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4, -1},
        {4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2, -1, -1, -1, -1},
        {9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3, -1},
        {11, 7, 4, 11, 4, 2, 2, 4, 0, -1, -1, -1, -1, -1, -1, -1},
        {11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4, -1, -1, -1, -1},
        {2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9, -1, -1, -1, -1},
        {9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7, -1},
        {3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10, -1},
        {1, 10, 2, 8, 7, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 1, 4, 1, 7, 7, 1, 3, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1, -1, -1, -1, -1},
        {4, 0, 3, 7, 4, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 8, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 10, 8, 10, 11, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 9, 3, 9, 11, 11, 9, 10, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 10, 0, 10, 8, 8, 10, 11, -1, -1, -1, -1, -1, -1, -1},
        {3, 1, 10, 11, 3, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 11, 1, 11, 9, 9, 11, 8, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9, -1, -1, -1, -1},
        {0, 2, 11, 8, 0, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 2, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 3, 8, 2, 8, 10, 10, 8, 9, -1, -1, -1, -1, -1, -1, -1},
        {9, 10, 2, 0, 9, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8, -1, -1, -1, -1},
        {1, 10, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 3, 8, 9, 1, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 9, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 3, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}};
	
}

