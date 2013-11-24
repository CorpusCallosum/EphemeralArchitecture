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
    void update();
	bool bHide;
    
    ofParameter<float> brightness;
    ofParameter<float> contrast;
    ofParameter<float> extrusion;
	ofParameter<float> growthFactor;
    
    float b,c,e,g;


    //ofxFloatSlider brightness, contrast, extrusion, growthFactor;
	
	ofxPanel gui_panel;
    float getBrightness();

    
};
 

#endif /* defined(__LANscapes__gui__) */
