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
/// This is the main voxel terrain class.  It should be used as a base class for your voxel terrain scripts.
/// </summary>
/// <remarks>
/// Please notice that this is a partial class.  This file contains the core workings of voxel terrain.
/// Fabrication related code resides in VFVoxelTerrainFabrication.cs, the other part of this class.
/// To get started, take a look at an example in the Examples folder.
/// </remarks>
[ExecuteInEditMode()]
public abstract partial class VFVoxelTerrain : MonoBehaviour
{
	/// <summary>
	/// Number of chunks per terrain X Axis.
	/// </summary>
	public int _xChunkCount = 1;
	
	/// <summary>
	/// Number of chunks per terrain Y Axis.
	/// </summary>
	public int _yChunkCount = 1;
	
	/// <summary>
	/// Number of chunks per terrain Z Axis.
	/// </summary>
	public int _zChunkCount = 1;
	
	/// <summary>
	/// Number of Voxels per chunk X Axis.
	/// </summary>
	public int _numVoxelsPerXAxis = 8;
	
	/// <summary>
	/// Number of Voxels per chunk Y Axis.
	/// </summary>
	public int _numVoxelsPerYAxis = 8;
	
	/// <summary>
	/// Number of Voxels per chunk Z Axis.
	/// </summary>
	public int _numVoxelsPerZAxis = 8;

	/// <summary>
	/// Used to uniformly scale the terrain.
	/// </summary>
	public float _scale = 2f;
	
	/// <summary>
	/// The normalized minimum voxel volume required to create a surface.
	/// </summary>
	public float _isolevel = .5f;
	
	/// <summary>
	/// Usually the main camera.
	/// </summary>
	public Component _observer;
	
	/// <summary>
	/// Returns an observer (usually the main camera) or an aux observer while in edit mode. 
	/// </summary>
	public Component Observer {	get { return (AuxObserver == null) ? _observer : AuxObserver; } }
	
	// Used by the editor.
	private Component _auxObserver;
	
	/// <summary>
	/// Returns the aux observer, which is always either an object with the name "Pro Editor Camera",
	/// or null if the application is not in edit mode, or the Pro Editor Camera can't be found. 
	/// </summary>
	public Component AuxObserver
	{
		get
		{
			if (Application.isEditor)
			{
				if (_auxObserver == null)
				{
					var auxCam = GameObject.Find("Pro Editor Camera");
					
					if (auxCam != null)
					{
						_auxObserver = auxCam.GetComponent<Camera>();
					}
				}
			}
			else
			{
				_auxObserver = null;
			}
			
			return _auxObserver;
			
		}
	}
	
	/// <summary>
	/// Minimum distance at which to disable chunks.
	/// </summary>
	public float _observerViewingDistance = 400f;

	/// <summary>
	/// Queuing is always active, but disabling this will cause a queue to be completely processed in one frame.
	/// </summary>
	/// <remarks>
	/// That's not ideal for load balancing, but may work for a special situation.
	/// </remarks>
	public bool _enableQueuing = true;
	
	/// <summary>
	/// When enabled, all chunks will load in on the first frame, with a noticeable delay.
	/// When disabled, chunks will load in the background, preventing a noticeable delay.
	/// </summary>
	public bool _enableSingleFrameLoading = true;
	
	/// <summary>
	/// This must be set to an instantiated material palette containing at least one material.
	/// The chunks in this voxel terrain will use this palette.
	/// </summary>
	public VFMaterialPalette _materialPalette;
	
	/// <summary>
	/// Usually a material with a volumetric shader to be used for the terrain.
	/// </summary>
	public Material[] Materials { get { return _materialPalette._materials; } }
	
	// Voxel data source.  See the Voxels property.
	IVFVoxelDataSource _voxels;
	
	/// <summary>
	/// Provides a flexible data source from which to read and write voxel data.
	/// </summary>
	public IVFVoxelDataSource Voxels { get { return _voxels; } }
	
	/// <summary>
	/// Dictionary of all the chunks in the terrain.
	/// </summary>
	/// <remarks>
	/// Chunks do not store voxels. They access voxel data from an IVFVoxelDataSource.
	/// The data source is the Voxels property of this class.
	/// Chunks are used to display the terrain and provide physics properties as well.
	/// </remarks
	public Dictionary<Vector3, VFVoxelChunk> _chunks;
	
	// Provides queuing for chunk activation and deactivation based on _observerViewingDistance.
	Queue<GameObject> _activationQueue = new Queue<GameObject>();
	Queue<GameObject> _deactivationQueue = new Queue<GameObject>();
	
	// Ensures that the queues aren't loaded up with duplicate items.
	HashSet<GameObject> _activationHashSet = new HashSet<GameObject>();
	HashSet<GameObject> _deactivationHashSet = new HashSet<GameObject>();
	
	/// <summary>
	/// Returns the total physical width of the terrain.
	/// </summary>
	public float Width { get { return _numVoxelsPerXAxis * _xChunkCount * _scale; } }
	
	/// <summary>
	/// Returns the total physical height of the terrain.
	/// </summary>
	public float Height { get { return _numVoxelsPerYAxis * _yChunkCount * _scale; } }
	
	/// <summary>
	/// Returns the total physical depth of the terrain.
	/// </summary>
	public float Depth { get { return _numVoxelsPerZAxis * _zChunkCount * _scale; } }
	
	/// <summary>
	/// Returns the total width of the terrain in voxels.
	/// </summary>
	public int WidthInVoxels { get { return _numVoxelsPerXAxis * _xChunkCount; } }
	
	/// <summary>
	/// Returns the total height of the terrain in voxels.
	/// </summary>
	public int HeightInVoxels { get { return _numVoxelsPerYAxis * _yChunkCount; } }
	
	/// <summary>
	/// Returns the total depth of the terrain in voxels.
	/// </summary>
	public int DepthInVoxels { get { return _numVoxelsPerZAxis * _zChunkCount; } }
	
	// Cycops Framework engine.  See Engine property.
	private CFEngine _engine = new CFEngine();
	
	/// <summary>
	/// Returns a Cyclops Framework engine.  The engine is used here for concurrency and sequencing,
	/// but is capable of far more.  It can replace the use of coroutines when coroutines
	/// can't be used, such as within the editor.
	/// </summary>
	public CFEngine Engine { get { return _engine; } }
		
	/// <summary>
	/// Entry Point - Start here.
	/// </summary>
	public virtual void Start()
	{
		if (_materialPalette == null)
		{
			Debug.LogWarning("Material Palette not set for " + gameObject.name + ".  Please create a Material Palette or use an existing one.");
			return;
		}
		
		if (Materials.Length < 1)
		{
			Debug.LogWarning("Material Palette is empty.  Please set at least one material.");
			return;
		}
		
		print("Starting VFVoxelTerrain");
		
		// If something is left over... (in the editor)
		if (gameObject.transform.childCount > 0)
		{
			// Clean up chunks
			for (int i = gameObject.transform.childCount - 1; i >= 0; --i)
			{
				var child = gameObject.transform.GetChild(i).gameObject;
				DestroyImmediate(child);
			}
		}

		if (_observer == null)
		{
			_observer = Camera.mainCamera;
		}
		
		// Create the shared voxels, to be used by all chunks.
		// This assumes that there's only one terrain per data source... perhaps that's not the case.
		// If not, this code needs to be replaced with something else.
		
		int dataSourceWidthInVoxels = WidthInVoxels + 2;
		int dataSourceHeightInVoxels = HeightInVoxels + 2;
		int dataSourceDepthInVoxels = DepthInVoxels + 2;
		
		if ((_voxels == null)
		    || ((_voxels.Width != dataSourceWidthInVoxels)
		    || (_voxels.Height != dataSourceHeightInVoxels)
		    || (_voxels.Depth != dataSourceDepthInVoxels)))
		{
			_voxels = CreateDataSource(dataSourceWidthInVoxels,
			                           dataSourceHeightInVoxels,
			                           dataSourceDepthInVoxels,
			                           _isolevel);
		}
		
		// Note: Chunk properties can be set via VoxelTerrain properties in the Inspector.
		if (_chunks == null)
		{
			_chunks = new Dictionary<Vector3, VFVoxelChunk>();
		}
		
	}
	
	/// <summary>
	/// Override this to create a custom data source.
	/// </summary>
	protected virtual IVFVoxelDataSource CreateDataSource(int width, int height, int depth, float isolevel)
	{
		return new VFSimpleVoxelDataSource(width, height, depth, isolevel);
	}
		
	/// <summary>
	/// Creates the VFVoxelChunk GameObjects for use by the terrain.
	/// </summary>
	/// <remarks>
	/// This is intended for use in Start.
	/// </remarks>
	protected void InitChunks()
	{
		for (int px = 0; px < _xChunkCount; ++px)
		{
			for (int py = 0; py < _yChunkCount; ++py)
			{
				for (int pz = 0; pz < _zChunkCount; ++pz)
				{
					AddChunk(new Vector3(px, py, pz));
				}
			}
		}
		
		RebuildChunks();
	}
	
	/// <summary>
	/// Sort and rebuild each chunk's mesh and collider.  Used by InitChunks.
	/// </summary>
	private void RebuildChunks()
	{
		// The chunks are sorted so that the chunks closest to the observer will load in first.
		// This allows the player to explore the world even while it's loading in.

		print("Rebuilding chunks.");

		var unsortedChunks = new List<VFVoxelChunk>();
		
		for (int px = 0; px < _xChunkCount; ++px)
		{
			for (int pz = 0; pz < _zChunkCount; ++pz)
			{
				for (int py = 0; py < _yChunkCount; ++py)
				{
					unsortedChunks.Add(_chunks[new Vector3(px, py, pz)]);
				}
			}
		}

		print("Sorting chunks.");
		
		IEnumerable<VFVoxelChunk> sortedChunks;
		
		if (_enableSingleFrameLoading)
		{
			// No reason to sort as they'll all be loaded in on the same frame.
			sortedChunks = unsortedChunks;
		}
		else
		{
			// Sort by distance from the observer which is usually the main camera.
			sortedChunks =
				from chunk in unsortedChunks
				orderby Vector3.Distance(chunk.transform.position, _observer.transform.position)
				select chunk;
		}
		
		print("Rebuilding meshes.");
		
		if (_enableSingleFrameLoading)
		{
			foreach (VFVoxelChunk chunk in sortedChunks)
			{
				chunk.RebuildMesh();
			}
			
			print("Finished rebuilding chunks.");
		}
		else
		{
			// Create a sequence of actions which each rebuild a mesh in sorted order.
			// Then add that sequence to the Cyclops Framework engine for processing
			// over a series of frames.
			
			var actions = new List<CFAction>();
					
			foreach (VFVoxelChunk chunk in sortedChunks)
			{
				actions.Add(new CFFunction(chunk, (o) => ((VFVoxelChunk)o).RebuildMesh()));
			}
			
			Engine
				.AddSequenceReturnTail(actions)
				.Add(() => print("Finished rebuilding chunks."));
		}
		
	}
	
	/// <summary>
	/// Adds a terrain chunk during initialization.
	/// </summary>
	private VFVoxelChunk AddChunk(Vector3 position)
	{
		GameObject o = new GameObject();
		
		o.AddComponent<MeshFilter>();
		o.AddComponent<MeshCollider>();
		
		var renderer = o.AddComponent<MeshRenderer>();
		
		renderer.sharedMaterials = Materials;
		
		var chunk = o.AddComponent<VFVoxelChunk>();

		chunk.transform.parent = this.gameObject.transform;

		chunk.Init(this,
			position,
			_numVoxelsPerXAxis, _numVoxelsPerYAxis, _numVoxelsPerZAxis,
			_scale);
		
		_chunks[new Vector3((int)position.x, (int)position.y, (int)position.z)] = chunk;

		return chunk;
		
	}
	
	/* Experimental
	private void RepositionChunk(VFVoxelChunk chunk, Vector3 position)
	{
		if (_chunks.ContainsKey(chunk.Position))
		{
			_chunks.Remove(chunk.Position);
		}

		_chunks[position] = chunk;

		chunk.Reposition(position);
		chunk.RebuildMesh();
	}
	*/
	
	/// <summary>
	/// Used by VFTerrainChunk to manage enqueuing activation of viewable chunks.
	/// </summary>
	public void EnqueueActivation(GameObject o)
	{
		if (!_activationHashSet.Contains(o))
		{
			_activationHashSet.Add(o);
			_activationQueue.Enqueue(o);
			
			if (_deactivationHashSet.Contains(o))
			{
				_deactivationHashSet.Remove(o);
			}
		}
		
	}
	
	/// <summary>
	/// Used by VFTerrainChunk to manage enqueuing deactivation of non-viewable chunks.
	/// </summary>
	public void EnqueueDeactivation(GameObject o)
	{
		if (!_deactivationHashSet.Contains(o))
		{
			_deactivationHashSet.Add(o);
			_deactivationQueue.Enqueue(o);
			
			if (_activationHashSet.Contains(o))
			{
				_activationHashSet.Remove(o);
			}
		}
		
	}
	
	/// <summary>
	/// Manages display of viewable chunks.
	/// </summary>
	/// <remarks>
	/// Queuing is employed to keep the frame rate reasonably stable.
	/// </remarks>
	/// <seealso cref="_observer"/>
	/// <seealso cref="_observerViewingDistance"/>
	/// <seealso cref="_enableQueuing"/>
	private void ProcessQueues()
	{
		if (_activationQueue.Count > 0)
		{
			if (_enableQueuing)
			{
				for (int n = 64; n > 4; n /= 2)
				{
					if (_activationQueue.Count >= (n * 2 - 1))
					{
						for (int i = 0; i < n; ++i)
						{
							var o = _activationQueue.Dequeue();
							if (o != null) o.active = true;
						}
						break;
					}
				}
			}
			
			while ((_enableQueuing && (_activationQueue.Count < 8)) || (!_enableQueuing))
			{
				if (_activationQueue.Count == 0)
				{
					break;
				}
				
				var o = _activationQueue.Dequeue();
				if (o != null) o.active = true;
			}
			
			if (_activationQueue.Count == 0)
			{
				if (_activationHashSet.Count > 0)
				{
					_activationHashSet.Clear();
				}
			}
			
		}
		
		if (_deactivationQueue.Count > 0)
		{
			if (_enableQueuing)
			{
				for (int n = 64; n > 4; n /= 2)
				{
					if (_deactivationQueue.Count >= (n * 2 - 1))
					{
						for (int i = 0; i < n; ++i)
						{
							var o = _deactivationQueue.Dequeue();
							if (o != null) o.active = false;
						}
						break;
					}
				}
			}
			
			while ((_enableQueuing && (_deactivationQueue.Count < 8)) || (!_enableQueuing))
			{
				if (_deactivationQueue.Count == 0)
				{
					break;
				}
				
				var o = _deactivationQueue.Dequeue();
				if (o != null) o.active = false;
			}
			
			if (_deactivationQueue.Count == 0)
			{
				if (_deactivationHashSet.Count > 0)
				{
					_deactivationHashSet.Clear();
				}
			}
			
		}
		
	}
		
	/// <summary>
	/// Update is called once per frame.
	/// Handles queue processing and drives the Cyclops Framework.
	/// </summary>
	protected virtual void Update ()
	{
		ProcessQueues();
		
		// If all chunks have been cleared out, then a restart is required.
		if (gameObject.transform.childCount	== 0) Start();
		
		Engine.Update(Time.deltaTime);
		
	}
	
	/// <summary>
	/// Cleans up VFVoxelChunks. 
	/// </summary>
	void OnDestroy()
	{
		if (Application.isPlaying)
		{
			if (_chunks != null)
			{
				for (int px = 0; px < _xChunkCount; ++px)
				{
					for (int py = 0; py < _yChunkCount; ++py)
					{
						for (int pz = 0; pz < _zChunkCount; ++pz)
						{
							if (_chunks.ContainsKey(new Vector3(px, py, pz)))
							{
								if (_chunks[new Vector3(px, py, pz)] != null)
								{
									Object.Destroy(_chunks[new Vector3(px, py, pz)]);
								}
							}
						}
					}
				}
			}
			
		}
		
		Resources.UnloadUnusedAssets();
		
	}
	
}

