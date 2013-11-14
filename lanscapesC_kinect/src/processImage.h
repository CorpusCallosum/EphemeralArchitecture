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

class processImage : public ofBaseApp {
    
public:
    
    //methods
    void                setup( int, int, int, int, ofxCvGrayscaleImage );
    ofxCvGrayscaleImage getProcessedImage( ofxCvGrayscaleImage );
    
    //constructor
    processImage();
    
    //variables
    
    int                     imgWidth, imgHeight;
    int                     moveThreshLow, moveThreshHigh;
    ofxCvGrayscaleImage     kinectSource;
    ofxCvGrayscaleImage     lastKinect;
    ofxCvGrayscaleImage     modifiedImage;
    
    vector<ofxCvGrayscaleImage> lastImages; //will use this to compare incoming pixels vs smoothed average of previous frames
    
    unsigned char *         sourcePixels;
    unsigned char *         lastPixels;
    unsigned char *         modifiedPixels;
    vector <int>            difference;
    
    float                   _brightness, _contrast, alphaAmount;
    
private:
    
};


#endif
