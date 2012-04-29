/* Author: Mark Davis
 * 
 * WARNING: This class is VERY unpolished, ugly, in beta, and may be completely rewritten.
 * 
 */
using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;
using Voxelform2.VoxelData;

// WARNING: This class is VERY unpolished, ugly, in beta, and may be completely rewritten.
public class VFProEditor : EditorWindow
{
	public const string MainCameraName = "Pro Editor Camera";
	
	GameObject _cameraGameObject;
	Camera _camera;
	GameObject _materialCameraGameObject;
	Camera _materialCamera;
	
	Light _materialLight;
	
	Vector3 _cameraPan;
	Vector2 _cameraRotation;
	Light _cameraSpotlight;
	GameObject _sunGameObject;
	Light _sun;
	RenderTexture _renderTexture;
	RenderTexture _materialRenderTexture;
	VFVoxelTerrain _terrain;
	//bool _terrainWasActive = false;
	GameObject _cursor;
	
	Material[] _materials;
	
	GameObject _materialSphere;

	Vector2 _mousePosition = new Vector2();
	Vector2 _mouseDragStartingPosition = new Vector2();
	Vector2 _mouseDragRelativePosition = new Vector2();
	bool _dragging = false;
	Vector2 _mouseScrollDelta = new Vector2();
	int _mouseButton = 0;
	//float _deltaTime = 0f;

	double _lastClickTime;
	double _doubleClickMaxDelta = 0.4;
	bool _doubleClickDetected = false;

	int _numGuiPassesThisFrame = 0;

	Vector3 _selectedVoxelPosition;

	enum ToolMode { Idle, Building, Digging }
	ToolMode _toolMode = ToolMode.Idle;

	enum ControlMode { Navigation, Edit };
	ControlMode _controlMode = ControlMode.Navigation;
	
	bool _invertX = false;
	bool _invertY = false;

	bool _lockX = false;
	bool _lockZ = false;

	//float _xLockValue = 0f;
	//float _yLockValue = 0f;
	//float _zLockValue = 0f;
	
	bool _snapCameraRotation = false;
	float _snapCameraRotationAngle = 45f;
	
	enum BrushShape { Box, Sphere };
	BrushShape _brushShape = BrushShape.Sphere;
	
	Vector3 _boxBrushSize = new Vector3(3f, 3f, 3f);
	float _sphereBrushSize = 3f;

	float _brushDensity = .75f;
	ushort _brushMaterialIndex = 0;
	
	bool _eraserEnabled = false;

	//System.DateTime _lastTime = System.DateTime.Now;

	Texture2D _boxTexture;
	
	//ushort _materialIndex = 0;
	
	//bool _hasFocus = false;
	
	Queue<Action> _destructionFunctions = new Queue<Action>();
	
	public static void ShowWindow ()
	{
		EditorWindow window = EditorWindow.GetWindow(typeof(VFProEditor));
		window.autoRepaintOnSceneChange = true;
		window.minSize = new Vector2(960f, 400f);
		window.wantsMouseMove = true;
		window.Show();
	}
	
	public void DoOnDestroy(Action o)
	{
		_destructionFunctions.Enqueue(o);
	}
	
	public void Awake()
	{
		
	}
	
	void OnApplicationFocus(bool focus)
	{
		if (focus)
		{
			Screen.showCursor = true;
		}
		
		//_hasFocus = focus;
		
	}
	
	void SetupCameraAndLights()
	{
		_cameraGameObject = new GameObject(MainCameraName);
		_cameraGameObject.AddComponent<Camera>();
		_cameraGameObject.hideFlags = HideFlags.HideAndDontSave;
		
		_camera = _cameraGameObject.camera;
		_camera.backgroundColor = new Color(0.45f, 0.55f, 0.86f);
		_camera.depth = -1;
		
		_cameraPan = new Vector3(_terrain.Width * .5f, _terrain.Height * .5f, -_terrain.Width * .25f) * 2f;
				
		DoOnDestroy(() =>
		{
			GameObject.DestroyImmediate(_cameraGameObject);
			_cameraGameObject = null;
			_camera = null;
		});
		
		_materialCameraGameObject = new GameObject("Pro Editor Material Camera");
		_materialCameraGameObject.AddComponent<Camera>();
		_materialCameraGameObject.hideFlags = HideFlags.HideAndDontSave;
		
		_materialCamera = _materialCameraGameObject.camera;
		_materialCamera.transform.position = new Vector3(5.95f, -10f, -960f);
		_materialCamera.transform.localEulerAngles = new Vector3(0f, 180f, 0f);
		_materialCamera.backgroundColor = new Color(.2f, .2f, .2f);
		_materialCamera.fov = 10.9f;
		_materialCamera.depth = -.5f;
		
		DoOnDestroy(() =>
		{
			GameObject.DestroyImmediate(_materialCameraGameObject);
			_materialCameraGameObject = null;
			_materialCamera = null;
		});	
		
		if (_materialLight == null)
		{
			Debug.Log("Creating Material Light!");
			
			var materialCameraLightGameObject = GameObject.CreatePrimitive(PrimitiveType.Capsule);
			materialCameraLightGameObject.transform.localPosition = new Vector3(-100, 100, -900);
			
			_materialLight = materialCameraLightGameObject.AddComponent<Light>();
			_materialLight.type = LightType.Directional;
			_materialLight.transform.localEulerAngles = new Vector3(35f, 164f, 0f);
			_materialLight.color = Color.white;
			_materialLight.intensity = 1f;
			_materialLight.enabled = false;
			_materialLight.renderMode = LightRenderMode.ForcePixel;
			
			DoOnDestroy(() =>
			{
				GameObject.DestroyImmediate(materialCameraLightGameObject);
				_materialLight = null;
			});
		}
		
		_cameraSpotlight = _cameraGameObject.AddComponent<Light>();
		_cameraSpotlight.type = LightType.Spot;
		_cameraSpotlight.range = 1000f;
		_cameraSpotlight.spotAngle = 160f;
		_cameraSpotlight.color = Color.white;
		_cameraSpotlight.intensity = 1f;
		
		DoOnDestroy(() =>
		{
			GameObject.DestroyImmediate(_cameraSpotlight);
			_cameraSpotlight = null;
		});
		
		_sunGameObject = new GameObject("Pro Editor Sun");
		_sunGameObject.hideFlags = HideFlags.HideAndDontSave;
		_sunGameObject.transform.position = new Vector3(_terrain.Width * .5f, _terrain.Height * 4f, _terrain.Width * .5f);

		_sun = _sunGameObject.AddComponent<Light>();
		_sun.type = LightType.Point;
		_sun.range = _terrain.Height * 6f;
		_sun.color = Color.white;
		_sun.intensity = 1f;
		
		DoOnDestroy(() =>
		{
			GameObject.DestroyImmediate(_sunGameObject);
			_sunGameObject = null;
			_sun = null;
		});
		
	}
	
	void SetVoxelBrushCursorType(PrimitiveType ptype)
	{
		if (_cameraGameObject == null)
		{
			Debug.Log("_cameraGameObject == null");
			return;
		}
		
		bool cursorWasActive = false;
		
		Quaternion cursorRotation = (_cursor != null) ? _cursor.transform.localRotation : Quaternion.identity;
		
		if (_cursor != null)
		{
			cursorWasActive = _cursor.active;
			DestroyImmediate(_cursor);
		}
		
		_cursor = GameObject.CreatePrimitive(ptype);
				
		GameObject.DestroyImmediate(_cursor.rigidbody);

		var st = _cursor.transform;
		st.localPosition = new Vector3(0f, 0f, 20f);
		st.localScale = new Vector3(5f, 5f, 5f);
		st.parent = _cameraGameObject.transform;
		st.localRotation = cursorRotation;
		
		_cursor.name = "Voxel Brush Cursor";
		_cursor.active = (_controlMode == ControlMode.Navigation);
		_cursor.renderer.sharedMaterial.shader = Shader.Find("Voxelform/Voxel Brush");
		_cursor.renderer.receiveShadows = true;
		_cursor.active = cursorWasActive;
		
		DoOnDestroy(() =>
    	{
			GameObject.DestroyImmediate(_cursor);
			_cursor = null;
		});
		
	}

	void CreateObjectsIfNull()
	{
		if (_terrain == null) return;
		
		/*
		if (_terrain == null)
		{
			GameObject tgo = GameObject.Find("Voxel Terrain");

			if (tgo != null)
			{
				_terrain = tgo.GetComponent<VFVoxelTerrain>();

				if (_terrain != null)
				{
					Debug.Log("VFProEditor is restarting the terrain.");
					_terrain.Start();
				}
			}
		}
		*/
		
		if (_renderTexture == null)
		{
			_renderTexture = new RenderTexture((int)position.width, (int)position.height, (int)RenderTextureFormat.Default);
			
			DoOnDestroy(() =>
			{
				GameObject.DestroyImmediate(_renderTexture);
				_renderTexture = null;
			});
		}
		
		if (_materialRenderTexture == null)
		{
			_materialRenderTexture = new RenderTexture(297, 200, (int)RenderTextureFormat.Default);
			
			DoOnDestroy(() =>
			{
				GameObject.DestroyImmediate(_materialRenderTexture);
				_materialRenderTexture = null;
			});
		}
		
		if (_cameraGameObject == null) SetupCameraAndLights();

		if (_terrain.Voxels == null)
		{
			_terrain.Start();

			if (_cameraGameObject == null)
			{
				SetupCameraAndLights();
			}
		}

		if (_cursor == null)
		{
			// If more cursor types are added, this will need to get more flexible.
			SetVoxelBrushCursorType(_brushShape == VFProEditor.BrushShape.Sphere ? PrimitiveType.Sphere : PrimitiveType.Cube);
		}
		
		// material selection
		
		int numMaterialColumns = 5;
		float materialCellWidth = 2.2f;
		float materialCellHeight = 2f;
		float materialCellScale = 1.8f;
		
		_materials = _terrain.Materials;
		
		if (_materialSphere == null)
		{
			_materialSphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
			_materialSphere.name = "Material Sphere";
			
			DoOnDestroy(() =>
			{
				GameObject.DestroyImmediate(_materialSphere);
				_materialSphere = null;
			});
			
			int maxi = Mathf.Clamp(_materials.Length, 0, numMaterialColumns);
			
			for (int i = 0; i < maxi; ++i)
			{
				var pos = new Vector3(i * materialCellWidth + 1.55f, -5.5f - materialCellHeight, -1000f);
				
				var sphere = (GameObject)Instantiate(_materialSphere, pos, Quaternion.identity);
				sphere.transform.localScale *= materialCellScale + (i == 4 ? .5f : 0f);
				DoOnDestroy(() => GameObject.DestroyImmediate(sphere));
				
				sphere.renderer.sharedMaterial = _materials[maxi - i - 1];
				sphere.name = "Material Sphere " + i;
			}
			
		}
		else
		{
			
			int maxi = Mathf.Clamp(_materials.Length, 0, numMaterialColumns);
			
			if (_materials.Length < 6)
			{
				for (int i = 0; i < maxi; ++i)
				{
					var materialSphere = GameObject.Find("Material Sphere " + i);
					materialSphere.renderer.enabled = true;
					materialSphere.renderer.sharedMaterial = _materials[maxi - i - 1];
					bool scaleUp = ((maxi - i - 1) == _materialScrollPos);
					materialSphere.transform.localScale = Vector3.one * (materialCellScale + (scaleUp ? .5f : 0f));
				}
			}
			else
			{
				for (int i = 0; i < maxi; ++i)
				{
					int matIndex = Mathf.Max(0, _materialScrollPos - 2) + maxi - i - 1;
					var materialSphere = GameObject.Find("Material Sphere " + i);
					
					int rightShift = 0;
					
					if (_materialScrollPos >= _materials.Length - 3)
					{
						rightShift = _materialScrollPos - (_materials.Length - 3);
						matIndex -= rightShift;
						matIndex = Mathf.Max(0, matIndex);
					}
					
					if (matIndex < _materials.Length)
					{	
						materialSphere.renderer.enabled = true;
						materialSphere.renderer.sharedMaterial = _materials[matIndex];
						bool scaleUp = (i == 4 - (Mathf.Min(2, _materialScrollPos) + rightShift));
						materialSphere.transform.localScale = Vector3.one * (materialCellScale + (scaleUp ? .5f : 0f));
					}
					else
					{
						materialSphere.renderer.enabled = false;
					}
				}
			}
		}

	}

	void RenderCameraView()
	{
		Quaternion lastCursorRotation = Quaternion.identity;
		
		if (_cursor	!= null)
		{
			lastCursorRotation = _cursor.transform.localRotation;
			_cursor.transform.localRotation = Quaternion.identity;
		}		
		
		// On a 64-bit Windows 7 machine, the Unity Editor will crash without this try/catch block.
		// Perhaps this would occur on other platforms as well.
		// No exceptions are ever caught, but this horrible little hack makes Unity behave.
		// But please don't worry... there aren't any hacks like this in the game runtime code.
		
		try
		{	
			_camera.transform.position = _cameraPan * .5f;
			_cameraRotation.y = Mathf.Clamp(_cameraRotation.y, -90f, 90f);
			_camera.transform.localEulerAngles = new Vector3(_cameraRotation.y, _cameraRotation.x, 0f);
			
			_camera.targetTexture = _renderTexture;
			_camera.Render();
			_camera.targetTexture = null;
			
			if (_materialLight != null) _materialLight.enabled = true;
			
			_materialCamera.targetTexture = _materialRenderTexture;
			_materialCamera.Render();
			_materialCamera.targetTexture = null;
			
			if (_materialLight != null) _materialLight.enabled = false;
			
			if (_renderTexture.width != position.width || _renderTexture.height != (position.height - 200))
			{
				if (_renderTexture != null) DestroyImmediate(_renderTexture);
				
				_renderTexture = new RenderTexture(
					(int)position.width,
					(int)(position.height - 200),
					24,
					RenderTextureFormat.Default);
			}
			
		}
		catch(System.Exception e)
		{
			Debug.Log(e.ToString());
		}
		
		if (_cursor	!= null) _cursor.transform.localRotation = lastCursorRotation;
				
	}

	void ProcessInput()
	{
		if (Event.current == null) return;

		bool repaintRequired = false;

		_mouseScrollDelta = Vector2.zero;
		_mouseDragStartingPosition = _mousePosition;
		_dragging = false;
		_doubleClickDetected = false;
		
		switch (Event.current.type)
		{
			case EventType.mouseMove:
				_mousePosition = Event.current.mousePosition;
				repaintRequired = true;
				break;

			case EventType.mouseDrag:
				_mousePosition = Event.current.mousePosition;
				repaintRequired = true;
				_dragging = true;
				break;

			case EventType.scrollWheel:
				_mouseScrollDelta = Event.current.delta;
				_mousePosition = Event.current.mousePosition;
				repaintRequired = true;
				break;

			case EventType.mouseDown:
				_mouseButton = Event.current.button + 1;
				_mousePosition = Event.current.mousePosition;
				_mouseDragStartingPosition = _mousePosition;

				// double click detection
				if ((EditorApplication.timeSinceStartup - _lastClickTime) < _doubleClickMaxDelta)
				{
					_doubleClickDetected = true;
				}

				_lastClickTime = EditorApplication.timeSinceStartup;

				repaintRequired = true;
				break;

			case EventType.mouseUp:
				_mouseButton = 0;
				_toolMode = ToolMode.Idle;
				repaintRequired = true;
				break;
		}

		if (repaintRequired) Repaint();

	}

	void ProcessDragging()
	{
		float dragTrackingScale = (1f / 6f);
		_mouseDragRelativePosition = (_mousePosition - _mouseDragStartingPosition) * dragTrackingScale;		
	}
	
	/*
	void SelectVoxelWithMouse()
	{
		RaycastHit hitInfo;
		var v = new Vector3(_mousePosition.x + 0f * (_camera.pixelWidth / position.width), (position.height - 160f) - _mousePosition.y);
			//((position.height - 160f) - _mousePosition.y) * (_camera.pixelHeight / (position.height - 160f)));

		v.x -= position.width * .48f;
		v.x *= 1.5f;
		v.x += position.width * .5f;

		v.y -= (position.height - 160f) * .3f;
		v.y *= 1.6f;
		v.y += (position.height - 160f) * .5f;

		var ray = _camera.ScreenPointToRay(v);
		
		if (Physics.Raycast(ray, out hitInfo, _camera.farClipPlane))
		{
			var chunk = hitInfo.collider.gameObject.GetComponent<VFVoxelChunk>();

			if (chunk != null)
			{
				var terrain = chunk.Terrain;

				if (terrain != null)
				{
					Vector3 p = (hitInfo.point / terrain._scale) - terrain.transform.localPosition / terrain._scale;
					_selectedVoxelPosition = p;
				}
			}
		}

	}
	*/
	
	public void Update()
	{
		if (_terrain == null) return;
		
		//_deltaTime = (float)(System.DateTime.Now - _lastTime).Milliseconds / 1000f;
		//_lastTime = System.DateTime.Now;

		CreateObjectsIfNull();
		
		RenderCameraView();
		
		_terrain.BroadcastMessage("UpdateChunkManually", SendMessageOptions.DontRequireReceiver);
		
		_numGuiPassesThisFrame = 0;
		
	}
	
	int _materialScrollPos;
		
	void OnGUI()
	{
		/* These have been moved lower... so remember not to access them.  Further comments explaining the situation, below.
			if (_terrain == null) return;
			if (_camera == null) return;
			if (_renderTexture == null) return;
			if (_materialRenderTexture == null) return;
			if (_materials == null) return;
		*/
		
		ProcessInput();
		ProcessDragging();

		Rect displayArea = new Rect(0f, 0f, position.width, position.height - 160f);
		Rect controlArea = new Rect(0f, position.height - 160f + 16f, position.width, 160f);
		Rect controlStatusArea = new Rect(position.width - 176f, 0f, 160f, 64f);
		Rect controlModifierArea = new Rect(position.width - 352f, 0f, 160f, 160f);
		Rect controlBrushArea = new Rect(position.width - 352f - 128f - 160f - 16f, 0f, 288f, 160f);
		Rect inversionArea = new Rect(position.width - 176f, 72f, 160f, 64f);
		Rect materialArea = new Rect(0f, position.height - 160f, 304f, 68f);
		
		int numMaterials = (_materials != null) ? _materials.Length : 1;
		
		GUILayout.BeginArea(new Rect(materialArea.x, materialArea.y + materialArea.height, materialArea.width, 32f));
		_materialScrollPos = (int)GUILayout.HorizontalScrollbar(_materialScrollPos, 1f, 0f, Mathf.Max(0f, numMaterials), GUILayout.Height(materialArea.height));
		GUILayout.EndArea();
		
		// get rid of something...
		_brushMaterialIndex = (ushort)_materialScrollPos;
		
		GUILayout.BeginArea(controlArea);

		GUILayout.BeginArea(controlStatusArea);

		GUILayout.Label("Select Voxel Terrain", EditorStyles.boldLabel);
		
		var selectedTerrain = (VFVoxelTerrain)EditorGUILayout.ObjectField(_terrain, typeof(VFVoxelTerrain), true);
		
		if (selectedTerrain	!= null)
		{
			if (selectedTerrain	!= _terrain)
			{
				if (_terrain != null) _terrain.gameObject.SetActiveRecursively(false);
				_terrain = selectedTerrain;
				//_terrainWasActive = _terrain.gameObject.active;
				_terrain.gameObject.SetActiveRecursively(true);
			}
		}
		
		GUILayout.EndArea();

		GUILayout.BeginArea(controlModifierArea);

		GUILayout.Label("Constraints", EditorStyles.boldLabel);
		_snapCameraRotation = EditorGUILayout.Toggle("Snap Camera", _snapCameraRotation);
		_snapCameraRotationAngle = EditorGUILayout.FloatField("Snap Angle", _snapCameraRotationAngle);
		_lockX = EditorGUILayout.Toggle("Lock Brush X", _lockX);
		_lockZ = EditorGUILayout.Toggle("Lock Brush Z", _lockZ);
		GUILayout.EndArea();
		
		GUILayout.BeginArea(controlBrushArea);

		GUILayout.Label("Brush Settings", EditorStyles.boldLabel);
		
		BrushShape lastBrushShape = _brushShape;
		
		_brushShape = (BrushShape)EditorGUILayout.EnumPopup("Shape", _brushShape);
		
		// GUI events would be nice... :P
		if (lastBrushShape != _brushShape)
		{
			//SetVoxelBrushCursorType(_brushShape == VFProEditor.BrushShape.Box ? PrimitiveType.Cube : PrimitiveType.Sphere);
			SetVoxelBrushCursorType(PrimitiveType.Sphere);
		}
		
		if (_brushShape == BrushShape.Box)
		{
			_boxBrushSize.x = (int)EditorGUILayout.Slider("Width", _boxBrushSize.x, 2f, 12f);
			_boxBrushSize.y = (int)EditorGUILayout.Slider("Height", _boxBrushSize.y, 2f, 12f);
			_boxBrushSize.z = (int)EditorGUILayout.Slider("Depth", _boxBrushSize.z, 2f, 12f);
		}
		else if (_brushShape == BrushShape.Sphere)
		{
			_sphereBrushSize = EditorGUILayout.Slider("Radius", _sphereBrushSize, 1f, 12f);
		}

		_brushDensity = EditorGUILayout.Slider("Density", _brushDensity, 0f, 1f);
		
		_eraserEnabled = EditorGUILayout.Toggle("Eraser", _eraserEnabled);
		
		GUILayout.EndArea();

		GUILayout.BeginArea(inversionArea);

		GUILayout.Label("Invert Mouse Rotation", EditorStyles.boldLabel);
		_invertX = EditorGUILayout.Toggle("Invert X", _invertX);
		_invertY = EditorGUILayout.Toggle("Invert Y", _invertY);
		
		GUILayout.EndArea();

		GUILayout.EndArea();
		
		// RANT: If this seems weird... it's because of the GUI system's hacks to get around the lack of a proper object model.
		// EditorGUILayout.ObjectField won't work properly unless it's sitting in (roughly?) the same place every frame.
		
		if (_terrain == null) return;
		if (_camera == null) return;
		if (_renderTexture == null) return;
		if (_materialRenderTexture == null) return;
		if (_materials == null) return;
		
		GUI.DrawTexture(new Rect(0f, 0f, position.width, (position.height - 160f)), _renderTexture);
		
		GUILayout.BeginArea(materialArea);
		GUI.DrawTexture(new Rect(0f, 0f, _materialRenderTexture.width + 8f, _materialRenderTexture.height + 8f), _materialRenderTexture);
		GUILayout.EndArea();
		
		GUILayout.Label("Mode: " + _controlMode.ToString(), EditorStyles.boldLabel);
		
		//Rect trackingArea = position;

		var nextControlMode = (_controlMode == ControlMode.Navigation) ? ControlMode.Edit : ControlMode.Navigation;

		if (_mouseScrollDelta.y != 0f)
		{
			_controlMode = nextControlMode;
			_cursor.active = (_controlMode == ControlMode.Edit);
			if (_cursor.active)
			{
				_cursor.transform.localPosition = new Vector3(0f, 0f, 20f);
				_cursor.transform.parent = _camera.transform;
			}
		}
		
		if (_controlMode == ControlMode.Navigation)
		{
			if (displayArea.Contains(_mousePosition))
			{
				if (_dragging)
				{
					float ry = _cameraGameObject.transform.localRotation.eulerAngles.y;
					ry = ry * Mathf.Deg2Rad + Mathf.PI / 2f;

					Vector2 dv = Vector2.zero;

					dv.x = -Mathf.Cos(ry) * _mouseDragRelativePosition.y + Mathf.Sin(ry) * -_mouseDragRelativePosition.x;
					dv.y = Mathf.Sin(ry) * _mouseDragRelativePosition.y + Mathf.Cos(ry) * -_mouseDragRelativePosition.x;

					if (_mouseButton == 1)
					{
						_cameraPan.x += dv.x;
						_cameraPan.z += dv.y;
					}
					else if (_mouseButton == 2)
					{
						_cameraRotation.x -= _mouseDragRelativePosition.x * (_invertX ? -1f : 1f);
						_cameraRotation.y -= _mouseDragRelativePosition.y * (_invertY ? -1f : 1f);
					}
					else if (_mouseButton == 3)
					{
						_cameraPan.y += _mouseDragRelativePosition.y;
					}
				}
			}
		}
		else if (_controlMode == ControlMode.Edit)
		{
			
			if (_brushShape == VFProEditor.BrushShape.Box)
			{
				float brushSize = Mathf.Max(_boxBrushSize.x, _boxBrushSize.y, _boxBrushSize.z) + 1f;
				_cursor.transform.localScale = new Vector3(brushSize, brushSize, brushSize) * _terrain._scale * 1f;
			}
			else if (_brushShape == VFProEditor.BrushShape.Sphere)
			{
				_cursor.transform.localScale = new Vector3(_sphereBrushSize, _sphereBrushSize, _sphereBrushSize) * _terrain._scale * 2f;
			}
			
			if (displayArea.Contains(_mousePosition))
			{
				//if (_dragging)
				{
					if (_snapCameraRotation)
					{
						_cameraRotation.x = Mathf.Round(_cameraRotation.x / _snapCameraRotationAngle) * _snapCameraRotationAngle;
						_cameraRotation.y = Mathf.Round(_cameraRotation.y / _snapCameraRotationAngle) * _snapCameraRotationAngle;
					}
					
					float ry = _cursor.transform.localRotation.eulerAngles.y;
					ry = ry * Mathf.Deg2Rad + Mathf.PI / 2f;
					
					Vector2 dv = Vector2.zero;
					
					dv.x = -Mathf.Cos(ry) * _mouseDragRelativePosition.y + Mathf.Sin(ry) * -_mouseDragRelativePosition.x;
					dv.y = Mathf.Sin(ry) * _mouseDragRelativePosition.y + Mathf.Cos(ry) * -_mouseDragRelativePosition.x;

					if (_mouseButton == 1)
					{
						if (_lockX) dv.x = 0f;
						if (_lockZ) dv.y = 0f;
						_cursor.transform.Translate(new Vector3(-dv.x, 0f, -dv.y));
					}
					else if (_mouseButton == 3)
					{
						_cursor.transform.Translate(new Vector3(0f, -_mouseDragRelativePosition.y * .5f, 0f));
					}

					if (_toolMode == ToolMode.Building)
					{
						//if (Event.current.delta != Vector2.zero)
						{
							Vector3 p = (_cursor.transform.position / _terrain._scale) - _terrain.transform.localPosition / _terrain._scale;
							
							if (_brushShape == VFProEditor.BrushShape.Sphere)
							{
								p.x += .5f;
								p.y += .5f;
								p.z += .5f;
							}
							else if (_brushShape == VFProEditor.BrushShape.Box)
							{
								p.x += 1f;
								p.y += 1f;
								p.z += 1f;
							}
							
							if (_brushShape == BrushShape.Box)
							{
								_terrain.AlterVoxelBox(p,
									(int)_boxBrushSize.x, (int)_boxBrushSize.y, (int)_boxBrushSize.z,
									_brushDensity,
									_brushMaterialIndex,
									_eraserEnabled ? VFFabOptions.EnableVolumeSubtraction : VFFabOptions.None);
							}
							else if (_brushShape == BrushShape.Sphere)
							{
								_terrain.AlterVoxelSphere(p,
									_sphereBrushSize,
									_brushDensity,
									_brushMaterialIndex,
									_eraserEnabled ? VFFabOptions.EnableVolumeSubtraction : VFFabOptions.None);
							}
						}
					}

				}
				
				if (!_dragging)
				{
					if (_mouseButton == 2)
					{
						float brushSize = _brushShape == BrushShape.Box ? _boxBrushSize.z * .5f : _sphereBrushSize;
						_cursor.transform.localPosition = new Vector3(0f, 0f, 4f + brushSize) * _terrain._scale;
						_cursor.transform.parent = _camera.transform;
					}
					else if (_doubleClickDetected)
					{
						_doubleClickDetected = false;
						_toolMode = ToolMode.Building;
					}
				}
			}

		}

		++_numGuiPassesThisFrame;
		
	}

	void OnDestroy()
	{
		
		while (_destructionFunctions.Count > 0)
		{
			_destructionFunctions.Dequeue()();
		}
		
		_renderTexture = null;
		
	}

}

