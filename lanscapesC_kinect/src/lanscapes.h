#pragma once

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"
#include "ofxGui.h"

#include "meshGenerator.h"
#include "processImage.h"
#include "gui.h"
#include "ofxXmlSettings.h"


class lanscapes : public ofBaseApp{
    
public:
    void setup();
    void update();
    void draw();
    void keyPressed( int );
    void updateZOffset();
    void saveXML();
    
    
    ofVideoGrabber          vidGrabber;
    ofxKinect               kinect;
    
    ofxCvColorImage			colorImg;
    ofxCvGrayscaleImage 	grayImage;
    ofxCvGrayscaleImage     modifiedImage;
    ofxCvGrayscaleImage     kinectImage;
    
    ofImage                 snapShot;
    ofxCvGrayscaleImage     background;
    unsigned char *         snapShotPix;
    
    bool                    fullscreen, bDrawVideo, bWireframe, bFaces;
    bool                    useKinect;
    
    float b,c,e,a;
    
    meshGenerator           mainMesh;
    processImage            processImage;
    gui                     gui;
    
    ofVec3f camDirectionRotated;
       
    ofEasyCam cam; // add mouse controls for camera movement
    
    
    int                     rotX, rotY, rotZ, transX, transY, transZ, width, height;
    float                   extrusionAmount;
    
    int                     previousHour;
    
    ofxXmlSettings          XML;
    
    string                  message;
    
};
