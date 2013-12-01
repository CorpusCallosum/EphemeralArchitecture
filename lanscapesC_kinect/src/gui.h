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
	bool hidden; //hide or show gui
    //set the initial gui parameters
    void setBrightness(float);
    void setContrast(float);
    void setExtrusion(float);
    void setAlphaValue(float);
    void setRotX(int);
    void setxOffset(int);
    void setzOffset(int);
    void setyOffset(int);
    void hide();
    void show();

    ofxPanel gui_panel;//initialize the gui panel
    
    //return parameters
    float getBrightness();
    float getContrast();
    float getExtrusion();
    float getAlpha();
    int getX();
    int getyOffset();
    int getxOffset();
    int getzOffset();
    bool isWireOn();
    bool drawVideo();
    bool drawFaces();
    
    //functions
    ofParameter<float> brightness;
    ofParameter<float> contrast;
    ofParameter<float> alphaValue;
	ofParameter<float> extrusion;
    ofParameter<int> rot_x;
    ofParameter<int> zOffset;
    ofParameter<int> xOffset;
    ofParameter<int> yOffset;

    
	ofxToggle wireframe;
    ofxToggle video;
    ofxToggle faces;

    
    
};
 

#endif /* defined(__LANscapes__gui__) */
