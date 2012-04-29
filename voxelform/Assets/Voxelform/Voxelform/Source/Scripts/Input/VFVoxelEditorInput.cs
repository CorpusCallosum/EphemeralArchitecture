/* Author: Mark Davis
 * 
 * This example script handles input for in-game editing.
 * Input is relayed via messaging to the VFVoxelInteraction script.
 * It's highly likely that you'll want to replace this with your own input handling,
 * but perhaps it will be useful for prototyping.
 * 
 * This script should be attached to a game object with a rigid body that parents the main camera.
 * 
 */

using System.Collections;
using UnityEngine;

/// <summary>
/// This example script handles input for in-game editing.
/// Input is relayed via messaging to the VFVoxelInteraction script.
/// It's highly likely that you'll want to replace this with your own input handling,
/// but perhaps it will be useful for prototyping.
/// This script should be attached to a game object with a rigid body that parents the main camera.
/// </summary>
public class VFVoxelEditorInput : MonoBehaviour
{
	/// <summary>
	/// Controls the velocity of the game object's rigid body. 
	/// </summary>
	private Vector3 _velocity = Vector3.zero;
			
	/// <summary>
	/// Hides and locks the cursor.
	/// </summary>
	void Start ()
	{
		Screen.showCursor = false;
		Screen.lockCursor = true;
	}
	
	/// <summary>
	/// Sends various input related messages to the VFVoxelInteraction script.
	/// </summary>
	void SendVoxelInteractionMessage(string name, object payload)
	{
		var voxelInteraction = GameObject.Find("Voxel Interaction");

		if (voxelInteraction != null)
		{
			if (payload == null)
			{
				voxelInteraction.SendMessage(name);
			}
			else
			{
				voxelInteraction.SendMessage(name, payload);
			}
		}
	}
	
	/// <summary>
	/// Toggled to control the message staggering. 
	/// </summary>
	bool _staggering = false;
	
	/// <summary>
	/// Sends messages, but limits them to 10 per second.
	/// </summary>
	IEnumerator StaggerMessage(string msg)
	{
		if (!_staggering)
		{
			_staggering = true;
			SendVoxelInteractionMessage(msg, null);
			yield return new WaitForSeconds(.1f);
			_staggering = false;
		}
	}
	
	/// <summary>
	/// This method polls for input and sends messages to the VFVoxelInteraction script.
	/// It also updates a game object with a rigid body.
	/// The game object should be a parent to the main camera.
	/// </summary>
	void FixedUpdate()
	{
		if (Input.GetKey(KeyCode.Space))
		{
			bool digMode = !(Input.GetKey(KeyCode.LeftControl));
			SendVoxelInteractionMessage("EditVoxels", digMode);
		}

		if (Input.GetKey(KeyCode.E))
		{
			StartCoroutine("StaggerMessage", "DecrementVoxelType");
		}
		else if (Input.GetKey(KeyCode.R))
		{
			StartCoroutine("StaggerMessage", "IncrementVoxelType");
		}
		
		if (Input.GetKey(KeyCode.LeftBracket))
		{
			SendVoxelInteractionMessage("AdjustRayPower", -.05f);
		}
		else if (Input.GetKey(KeyCode.RightBracket))
		{
			SendVoxelInteractionMessage("AdjustRayPower", .05f);
		}

		Vector3 v = Vector3.zero;
		
		v.x = Input.GetAxis("Horizontal");
		v.z = Input.GetAxis("Vertical"); 
		v.y = Input.GetKey(KeyCode.Q) ? 1f : Input.GetKey(KeyCode.Z) ? -1f : 0;
		
		float power = 5f;
		
		if (Input.GetKey(KeyCode.LeftShift))
		{
			power *= .2f;
		}
		
		if (v.x != 0f) v.x = Mathf.Sign(v.x) * power;
		if (v.z != 0f) v.z = Mathf.Sign(v.z) * power;
		
		v.y *= power;
		
		float ry = gameObject.transform.localRotation.eulerAngles.y;
		
		ry = ry * Mathf.Deg2Rad + Mathf.PI / 2f;
				
		Vector3 dv = Vector3.zero;
		
		dv.x = -Mathf.Cos(ry) * v.z + Mathf.Sin(ry) * v.x;
		dv.y = v.y;
		dv.z = Mathf.Sin(ry) * v.z + Mathf.Cos(ry) * v.x;
		
		_velocity += dv * power;
		_velocity *= .5f;
		
		gameObject.rigidbody.velocity = _velocity;
		
	}
	
}

