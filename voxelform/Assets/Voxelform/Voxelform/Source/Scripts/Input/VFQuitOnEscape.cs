/*  Author: Mark Davis
 * 
 *  Quits application when escape is pressed.
 * 
 */

using UnityEngine;
using System.Collections;

/// <summary>
/// Quits application when escape is pressed. 
/// </summary>
[AddComponentMenu("Voxelform/Quit On Escape")]
public class VFQuitOnEscape : MonoBehaviour
{
	/// <summary>
	/// Checks each frame for escape key press.
	/// Quits application when escape is pressed.
	/// </summary>
	void Update ()
	{
		if (Input.GetKey(KeyCode.Escape))
		{
			Application.Quit();
		}
	}
}

