//
//  soundCalculations.h
//
//
//  Created by curry on 6/12/14.
//
//

#ifndef soundCalculations_h
#define soundCalculations_h

#include <iostream>
#include "ofMain.h"

class soundCalculations : public ofBaseApp {
    
public:
    
    void setup( int, int, float, float );
    void update();
    void calculateSound( int ); //for calculating volume using moving points from processImage
    vector <float> getVolume(); //for recall from main app
    vector <float> getPan();
    
    int                 numSounds;
    vector <int>        soundRadius;
    vector <float>      soundPan;
    vector <float>      soundVolume;
    vector <ofVec2f>    soundCenter;
    vector <float>      distance;
    
    int                 frameWidth, frameHeight;
    int                 loc;
    float               upSpeed, downSpeed;
    
    
};


#endif
