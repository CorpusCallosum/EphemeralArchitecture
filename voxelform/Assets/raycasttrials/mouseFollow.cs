using UnityEngine;
using System.Collections;

public class mouseFollow : MonoBehaviour {
	
	public float speed = 1.0f;
	public float dist = 20.0f;
	public Vector3 currentPosition = Vector3.zero;
	public Vector3 newPosition = Vector3.zero;
	public Vector3 down = -Vector3.up;
	

	// Use this for initialization
	void Start () {
		
	
	}
	
	// Update is called once per frame
	void Update () {
		
		newPosition.x = Input.mousePosition.x;
		newPosition.y = 100;
		newPosition.z = Input.mousePosition.y;
		
		RaycastHit hit;
		
		transform.position = Vector3.Lerp( currentPosition, newPosition, speed );
		Debug.DrawRay( transform.position, down * dist, Color.white );
		
		if (Physics.Raycast(transform.position, down, out hit))
            print("There's something down there");
            float distToGround = hit.distance;
            Debug.Log ( distToGround );
            
  
           // Debug.Log( "There's something there" );
        
		currentPosition = newPosition;
	}
}
