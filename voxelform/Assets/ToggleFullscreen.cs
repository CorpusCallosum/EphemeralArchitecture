using UnityEngine;
using System.Collections;

public class ToggleFullscreen : MonoBehaviour
{
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F))
            Screen.fullScreen = !Screen.fullScreen;
    }
    // Use this for initialization
	void Start () {
		//unused in example	
		 Screen.fullScreen = true;

	}
}