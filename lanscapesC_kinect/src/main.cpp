#include "lanscapes.h"
#include "ofMain.h"
#include "ofAppGlutWindow.h"

//========================================================================
int main( ){
    
	//ofSetupOpenGL(1024,768, OF_WINDOW);			// <-------- setup the GL context
    
    ofAppGlutWindow window;                         //switched back to glut window to allow ofHideCursor()
    ofSetupOpenGL(&window, 1024,768, OF_WINDOW);
    
	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp( new lanscapes());
    
}