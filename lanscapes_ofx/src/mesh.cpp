/**
 *
 * OFDevCon Example Code Sprint
 *
 * This example shows building a mesh, texturing it with a webcam, and extruding the vertices based on the pixel brightness
 * Moving the mouse also rotates the mesh to see it at different angles
 *
 * Created by Tim Gfrerer and James George for openFrameworks workshop at Waves Festival Vienna sponsored by Lichterloh and Pratersauna
 * Adapted during ofDevCon on 2/23/2012
 */


#include "mesh.h"

//--------------------------------------------------------------
void Mesh::setup(int w, int h){
    
	ofSetVerticalSync(true);
	ofSetFrameRate(60);
	ofBackground(0,0,0);
	
	//initialize the video grabber
	//vidGrabber.setVerbose(true);
	//vidGrabber.initGrabber(320,240);
    
	//store the width and height for convenience
	int width = w;
	int height = h;
	
	//add one vertex to the mesh for each pixel
	for (int y = 0; y < height; y++){
		for (int x = 0; x<width; x++){
			mainMesh.addVertex(ofPoint(x,y,0));	// mesh index = x + y*width
            // this replicates the pixel array within the camera bitmap...
			mainMesh.addColor(ofFloatColor(0,0,0));  // placeholder for colour data, we'll get this from the camera
		}
	}
	
	for (int y = 0; y<height-1; y++){
		for (int x=0; x<width-1; x++){
			mainMesh.addIndex(x+y*width);				// 0
			mainMesh.addIndex((x+1)+y*width);			// 1
			mainMesh.addIndex(x+(y+1)*width);			// 10
			
			mainMesh.addIndex((x+1)+y*width);			// 1
			mainMesh.addIndex((x+1)+(y+1)*width);		// 11
			mainMesh.addIndex(x+(y+1)*width);			// 10
		}
	}
	
	//this is an annoying thing that is used to flip the camera
	cam.setScale(1,-1,1);
	
	
	//this determines how much we push the meshes out
	extrusionAmount = 300.0;
}

//--------------------------------------------------------------
void Mesh::update(ofxCvGrayscaleImage img){
	//grab a new frame
	//vidGrabber.update();
	
	//update the mesh if we have a new frame
	//if (vidGrabber.isFrameNew()){
		//this determines how far we extrude the mesh
    
    
    
    
		for (int i=0; i<img.getWidth()*img.getHeight(); i++){
            
			//ofFloatColor sampleColor(img.getPixels()[i*3]/255.f,				// r
			//						 img.getPixels()[i*3+1]/255.f,			// g
			//						 img.getPixels()[i*3+2]/255.f);			// b
			
			//now we get the vertex aat this position
			//we extrude the mesh based on it's brightness
            
            float b = img.getPixels()[i]/255.f;
            
			ofVec3f tmpVec = mainMesh.getVertex(i);
			//tmpVec.z = sampleColor.getBrightness() * extrusionAmount;
            tmpVec.z = b * extrusionAmount;

			mainMesh.setVertex(i, tmpVec);
            
			mainMesh.setColor(i, b);
		}
	//}
	
	//let's move the camera when you move the mouse
	float rotateAmount = ofMap(ofGetMouseY(), 0, ofGetHeight(), 0, 360);
    
	
	//move the camera around the mesh
	ofVec3f camDirection(0,0,1);
	ofVec3f centre(vidGrabber.getWidth()/2.f,img.getHeight()/2.f, 255/2.f);
	ofVec3f camDirectionRotated = camDirection.rotated(rotateAmount, ofVec3f(1,0,0));
	ofVec3f camPosition = centre + camDirectionRotated * extrusionAmount;
	
	cam.setPosition(camPosition);
	cam.lookAt(centre);
}

//--------------------------------------------------------------
void Mesh::draw(){
	//we have to disable depth testing to draw the video frame
	ofDisableDepthTest();
    //	vidGrabber.draw(20,20);
	
	//but we want to enable it to show the mesh
	ofEnableDepthTest();
	cam.begin();
    
	//You can either draw the mesh or the wireframe
	// mainMesh.drawWireframe();
	mainMesh.drawFaces();
	cam.end();
	
	//draw framerate for fun
	ofSetColor(255);
	string msg = "fps: " + ofToString(ofGetFrameRate(), 2);
	ofDrawBitmapString(msg, 10, 20);
	
}

//--------------------------------------------------------------
void Mesh::keyPressed(int key){
	switch(key) {
		case 'f':
			ofToggleFullscreen();
			break;
	}
    
}