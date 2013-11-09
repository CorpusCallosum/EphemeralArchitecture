#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){

	camWidth 		= 640;	// try to grab at this size.
	camHeight 		= 480;
	
    //we can now get back a list of devices.
	/*vector<ofVideoDevice> devices = video.listDevices();
	
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
	video.initGrabber(camWidth,camHeight);*/
    
    // enable depth->video image calibration
	kinect.setRegistration(true);
    
	kinect.init(false, false);
	
	kinect.open();		// opens first available kinect
	
	// print the intrinsic IR sensor values
	if(kinect.isConnected()) {
		ofLogNotice() << "sensor-emitter dist: " << kinect.getSensorEmitterDistance() << "cm";
		ofLogNotice() << "sensor-camera dist:  " << kinect.getSensorCameraDistance() << "cm";
		ofLogNotice() << "zero plane pixel size: " << kinect.getZeroPlanePixelSize() << "mm";
		ofLogNotice() << "zero plane dist: " << kinect.getZeroPlaneDistance() << "mm";
    }

	
	ofSetVerticalSync(true);
    
    modifiedImage.allocate( camWidth, camHeight );
    colorImage.allocate( camWidth, camHeight );
    grayImage.allocate( camWidth, camHeight );
    modifiedImage.set( 0.0 );

}

//--------------------------------------------------------------
void testApp::update(){
	ofBackground(100,100,100);
	
	//video.update();
    //colorImage.setFromPixels( video.getPixels(), camWidth, camHeight );
    //grayImage = colorImage;

    if(kinect.isFrameNew()) {
        kinect.update();
        grayImage.setFromPixels( kinect.getDepthPixels(), camWidth, camHeight );
    }
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
