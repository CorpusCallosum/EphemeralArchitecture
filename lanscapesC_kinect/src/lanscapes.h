#pragma once

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"

#include "meshGenerator.h"
#include "processImage.h"


class lanscapes : public ofBaseApp{
    
public:
    void setup();
    void update();
    void draw();
    void keyPressed( int );
    
    
    ofVideoGrabber          vidGrabber;
    ofxKinect               kinect;
    
    ofxCvColorImage			colorImg;
    ofxCvGrayscaleImage 	grayImage;
    ofxCvGrayscaleImage     modifiedImage;
    ofxCvGrayscaleImage     kinectImage;
    
    bool                    fullscreen, bDrawVideo, bWireframe, bFaces;
    bool                    useKinect;
    
    meshGenerator           mainMesh;
    processImage            processImage;
    
    ofCamera                cam;
    
    int                     rotX, rotY, rotZ, transX, transY, transZ, width, height;
    float                   extrusionAmount;
    
    ofLight light;
    
    
};


