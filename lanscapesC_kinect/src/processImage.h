//
//  processImage.h
//
//
//  Created by curry on 11/2/13.
//
//

#ifndef processImage_h
#define processImage_h

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "gui.h"

class processImage : public ofBaseApp {
    
public:
    
    //methods
    void                setup( int, int, int, int, ofxCvGrayscaleImage );
    void update();

    ofxCvGrayscaleImage getProcessedImage( ofxCvGrayscaleImage, ofxCvGrayscaleImage );

    
    //constructor
    processImage();
    
    //variables
    
    int                     imgWidth, imgHeight;
    int                     moveThreshLow, moveThreshHigh;
    ofxCvGrayscaleImage     kinectSource;
    ofxCvGrayscaleImage     modifiedImage;
    ofxCvGrayscaleImage     backgroundImage;
    
    
    
    unsigned char *         sourcePixels;
    unsigned char *         modifiedPixels;
    unsigned char *         backgroundPixels;
    vector <int>            difference;
    
    float                   _brightness, _contrast, alphaAmount;
    gui                     gui;
    
private:
    
};


#endif
