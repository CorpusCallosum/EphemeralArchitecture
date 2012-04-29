/*
 * This script is based on Unity's MouseLook script, but handles keyboard input too.
 * This script should be attached to a GameObject that is the parent of a GameObject with the main camera.
 * Set Axes to XAxis.
 * Then the script should also be attached to the GameObject with the main camera.
 * Set Axes to YAxis.
 */

using UnityEngine;
using System.Collections;

/// <summary>
/// This script is based on Unity's MouseLook script, but handles keyboard input too.
/// This script should be attached to a GameObject that is the parent of a GameObject with the main camera.
/// Set Axes to XAxis.
/// Then the script should also be attached to the GameObject with the main camera.
/// Set Axes to YAxis.
/// </summary>
[AddComponentMenu("Voxelform/Mouse And Keyboard Look")]
public class VFMouseAndKeyboardLook : MonoBehaviour {

	public enum RotationAxes { XAxis = 0, YAxis = 1 }
	public RotationAxes _axes = RotationAxes.XAxis;
	public float _keyboardSensitivity = 1f;
	public float _mouseSensitivity = 15f;

	public float _minimumX = -360f;
	public float _maximumX = 360f;

	public float _minimumY = -90f;
	public float _maximumY = 90f;

	float _rotationY = 0f;

	float _mouseDX = 0f;
	float _mouseDY = 0f;

	/// <summary>
	/// Sets current mouse deltas.
	/// </summary>
	void Update()
	{
		_mouseDX += Input.GetAxis("Mouse X");
		_mouseDY += Input.GetAxis("Mouse Y");
	}
	
	/// <summary>
	/// Updates the game object's transform based on mouse and keyboard input. 
	/// </summary>
	void FixedUpdate()
	{
		if (Time.timeScale == 0) return;

		bool shift = Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift);
		float sensitivity = (shift ? .1f : 1f);
		float keyboardSensitivity = _keyboardSensitivity * sensitivity;
		float mouseSensitivity = 14f * sensitivity;
		
		if (_axes == RotationAxes.XAxis)
		{
			float dx = (Input.GetKey(KeyCode.J) ? -1f : Input.GetKey(KeyCode.L) ? 1f : 0f) * keyboardSensitivity;
			dx += _mouseDX * mouseSensitivity;

			if (dx != 0f)
			{
				transform.Rotate(0, dx, 0);
			}
		}
		else if (_axes == RotationAxes.YAxis)
		{
			float dy = (Input.GetKey(KeyCode.K) ? -1f : Input.GetKey(KeyCode.I) ? 1f : 0f) * keyboardSensitivity;
			dy += _mouseDY * mouseSensitivity;

			if (dy != 0f)
			{
				_rotationY += dy;
				_rotationY = Mathf.Clamp(_rotationY, _minimumY, _maximumY);

				transform.localEulerAngles = new Vector3(-_rotationY, transform.localEulerAngles.y, 0);
			}
		}

		_mouseDX = 0f;
		_mouseDY = 0f;

	}
	
	/// <summary>
	/// Prevent the rigid body from rotating. 
	/// </summary>
	void Start ()
	{
		if (rigidbody)
		{
			rigidbody.freezeRotation = true;
		}
	}
}