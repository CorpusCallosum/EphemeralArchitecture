#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){

	camWidth 		= 640;	// try to grab at this size.
	camHeight 		= 480;
	
    //we can now get back a list of devices.
	vector<ofVideoDevice> devices = video.listDevices();
	
    for(int i = 0; i < devices.size(); i++){
		cout << devices[i].id << ": " << devices[i].deviceName;
        if( devices[i].bAvailable ){
            cout << endl;
        }else{
            cout << " - unavailable " << endl;
        }
	}
    
	video.setDeviceID(0);
	video.setDesiredFrameRate(60);
	video.initGrabber(camWidth,camHeight);
	
	ofSetVerticalSync(true);
    
    modifiedImage.allocate( camWidth, camHeight );
    colorImage.allocate( camWidth, camHeight );
    grayImage.allocate( camWidth, camHeight );
    modifiedImage.set( 0.0 );

}

//--------------------------------------------------------------
void testApp::update(){
	ofBackground(100,100,100);
	
	video.update();
    colorImage.setFromPixels( video.getPixels(), camWidth, camHeight );
    grayImage = colorImage;
    
    modifiedImage = processImage.getProcessedImage( grayImage );
}

//--------------------------------------------------------------
void testApp::draw(){

	ofBackground(100,100,100);
    
    grayImage.draw( 0, 0, camWidth / 2, camHeight / 2 );
    modifiedImage.draw( camWidth / 2, 0, camWidth / 2, camHeight / 2 );
   

}

//--------------------------------------------------------------
void testApp::keyPressed(int key){

}

//--------------------------------------------------------------
void testApp::keyReleased(int key){

}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){ 

}
