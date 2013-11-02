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

#pragma once
#include "ofMain.h"
#include "ofxOpenCv.h"



class Mesh : public ofBaseApp{
	
public:
	void setup(int w, int h);
	void update(ofxCvGrayscaleImage img);
	void draw();
	
	void keyPressed  (int key);
    
	ofCamera cam; // add mouse controls for camera movement
	float extrusionAmount;
	ofVboMesh mainMesh;
	ofVideoGrabber vidGrabber;
	
};
