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
	void draw( bool, bool );
    void save();
    void setZOffset(int);

    
	//variables
    ofxCvGrayscaleImage meshImage;
    
	float extrusionAmount;
	ofVboMesh mainMesh, wireframeMesh;
    bool    bDrawWireframe, bDrawFaces;
    int width, height, zOffset;
    
    vector<ofColor> colorGrid;
    
    currentColor    currentColor;
    
	
};




#endif
