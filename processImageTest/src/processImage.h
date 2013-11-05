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
#include "ofxCvColorImageAlpha.h"

class processImage : public ofBaseApp {
    
public:
    
    //methods
    ofxCvGrayscaleImage getProcessedImage( ofxCvGrayscaleImage );
    
    //constructor
    processImage();
    
    //variables
    
    int                     imgWidth, imgHeight;
    ofxCvGrayscaleImage     kinectSource;
    ofxCvGrayscaleImage     differenceImage;
    ofxCvGrayscaleImage     modifiedImage;
    
    unsigned char *         sourcePixels;
    unsigned char *         lastPixels;
    //vector <int>            newPixels;
    vector <int>            difference;
    
    float                   _brightness, _contrast;
    
private:
    
};


#endif
