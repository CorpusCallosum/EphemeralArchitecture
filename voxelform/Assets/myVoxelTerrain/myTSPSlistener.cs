using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using TSPS;

public class myTSPSListener : MonoBehaviour {

	private Dictionary<int,GameObject> peopleCubes = new Dictionary<int,GameObject>();
	
	//game engine stuff for the example
	public Material	[] materials;
	public GameObject boundingPlane; //put the people on this plane
	public GameObject personMarker; //used to represent people moving about in our example
	
	// Use this for initialization
	void Start () {
		//unused in example	
	}
	
	// Update is called once per frame
	void Update () {
		//unused in example
	}
	
	public void PersonEntered(Person person){
		Debug.Log(" person entered with ID " + person.id);
		GameObject personObject = (GameObject)Instantiate(personMarker, positionForPerson(person), Quaternion.identity);
		personObject.renderer.material = materials[person.id % materials.Length];
		peopleCubes.Add(person.id,personObject);
	}

	public void PersonUpdated(Person person) {
		//Debug.Log("Person updated with ID " + person.id);
		if(peopleCubes.ContainsKey(person.id)){
			GameObject cubeToMove = peopleCubes[person.id];
			cubeToMove.transform.position = positionForPerson(person);
		}
	}

	public void PersonWillLeave(Person person){
		Debug.Log("Person leaving with ID " + person.id);
		if(peopleCubes.ContainsKey(person.id)){
			Debug.Log("Destroying cube");
			GameObject cubeToRemove = peopleCubes[person.id];
			peopleCubes.Remove(person.id);
			//delete it from the scene	
			Destroy(cubeToRemove);
		}
	}
	
	//maps the OpenTSPS coordinate system into one that matches the size of the boundingPlane
	private Vector3 positionForPerson(Person person){
		Bounds meshBounds = boundingPlane.GetComponent<MeshFilter>().sharedMesh.bounds;
		return new Vector3( (float)(.5 - person.centroidX) * meshBounds.size.x, 0.25f, (float)(person.centroidY - .5) * meshBounds.size.z );
		Debug.Log(person.centroidX);
	}
	
}