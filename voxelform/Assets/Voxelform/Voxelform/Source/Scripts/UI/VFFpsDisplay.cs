/*  Author: Mark Davis
 * 
 *  This behaviour calculates and displays a smooth frame rate.
 */

using UnityEngine;
using System.Collections;

/// <summary>
/// This behaviour calculates and displays a smooth frame rate.
/// </summary>
public class VFFpsDisplay : MonoBehaviour
{
	/// <summary>
	/// <see cref="GUIText"/> used to display frame rate. 
	/// </summary>
	public GUIText fpsDisplay;
	
	// Initial assumed frame rate.
	private float _fps = 60f;
	
	/// <summary>
	/// Use this for initialization.
	/// </summary>
	void Start ()
	{
		if (fpsDisplay == null)
		{
			fpsDisplay = gameObject.guiText;
		}
		
		//Time.timeScale = 1f;
		
	}
	
	/// <summary>
	/// Calculates the smoothed frame rate and updates the <see cref="GUIText"/>. 
	/// </summary>
	void Update()
	{
		_fps = _fps * .99f + (1f / Time.deltaTime) * .01f;
		
		if (fpsDisplay != null)
		{
			fpsDisplay.text = (Mathf.RoundToInt(_fps)).ToString();
		}
	}

}

