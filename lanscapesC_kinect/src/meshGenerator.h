//
//  meshGenerator.h
//  
//
//  Created by curry on 11/7/13.
//
//

#ifndef meshGenerator_h
#define meshGenerator_h

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "currentColor.h"

class meshGenerator : public ofBaseApp{
	
public:
    
    //methods
	void setup( int, int, float, bool, bool );
    ofVboMesh update( ofxCvGrayscaleImage );
    //ofVboMesh update( ofxCvGrayscaleImage, ofColor ); //get current color from current color class
	void draw( bool, bool );
    void save();

    
	//variables
    ofxCvGrayscaleImage meshImage;
    
	float extrusionAmount;
	ofVboMesh mainMesh;
    bool    bDrawWireframe, bDrawFaces;
    int width, height;
    
    vector<ofColor> colorGrid;
    
    currentColor    currentColor;
    
	
};




#endif
