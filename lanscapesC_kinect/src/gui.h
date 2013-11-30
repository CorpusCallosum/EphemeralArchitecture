//
//  gui.h
//  LANscapes
//
//  Created by gabriella levine on 11/13/13.
//
//
#pragma once

#ifndef __LANscapes__gui__
#define __LANscapes__gui__

#include <iostream>
#include "ofMain.h"
#include "ofxGui.h"




class gui :  public ofBaseApp{

public:
    void setup();
    void draw();    
	bool bHide; //hide or show gui
    //set the initial gui parameters
    void setBrightness(float);
    void setContrast(float);
    void setExtrusion(float);
    void setAlphaValue(float);
    void setRotX(int);
    void setzOff(int);
    void setyOff(int);


    ofxPanel gui_panel;//initialize the gui panel
    
    //return parameters
    float getBrightness();
    float getContrast();
    float getExtrusion();
    float getAlpha();
    int getX();
    int getyOff();
    int getzOff();
    bool isWireOn();
    bool drawVideo();
    bool drawFaces();
    
    //functions
    ofParameter<float> brightness;
    ofParameter<float> contrast;
    ofParameter<float> alphaValue;
	ofParameter<float> extrusion;
    ofParameter<int> rot_x;
    ofParameter<int> zOff;
    ofParameter<int> yOff;

    
	ofxToggle wireframe;
    ofxToggle video;
    ofxToggle faces;

    
    
};
 

#endif /* defined(__LANscapes__gui__) */
