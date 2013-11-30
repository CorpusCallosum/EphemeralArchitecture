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
	bool bHide;
    
    ofxPanel gui_panel;
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



    float b,c,e,g;
    int x;

    
    
};
 

#endif /* defined(__LANscapes__gui__) */
