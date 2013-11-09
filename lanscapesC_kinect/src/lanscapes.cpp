#include "lanscapes.h"


//--------------------------------------------------------------
void lanscapes::setup(){
    
    fullscreen = false;
    bDrawVideo = true;
    bWireframe = true;
    bFaces = true;
    useKinect = true;
    
    rotX = -300;
    rotY = 0;
    rotZ = 0;
    transX = 0;
    transY = -50;
    transZ = 100;
    
    width = 320;
    height = 240;
    extrusionAmount = 300.0;
    
    if ( useKinect ) {
        // enable depth->video image calibration
        kinect.setRegistration(true);
        kinect.init( false, false );
        kinect.open();		// opens first available kinect
    }
    
    else {
        vidGrabber.setVerbose(true);
        vidGrabber.initGrabber( width, height );
    }
	
    colorImg.allocate( width, height );
	grayImage.allocate( width, height );
    modifiedImage.allocate( width, height );
    kinectImage.allocate( kinect.width, kinect.height );
    
    mainMesh.setup( width, height, extrusionAmount, true, true );// ( width, height, extrusion amount, draw wireframe, draw faces );
    
    processImage.setup( width, height, 5, 100 );
	
}

//--------------------------------------------------------------
void lanscapes::update(){
    
    ofSetFullscreen( fullscreen );
    if ( fullscreen ) {
        ofHideCursor();
    }
	ofBackground( 0 );
    
    
    if ( useKinect ) {
        kinect.update();
        if(kinect.isFrameNew()) {
            
            // load grayscale depth image from the kinect source
            kinectImage.setFromPixels( kinect.getDepthPixels(), kinect.width, kinect.height);
            kinectImage.resize( width, height );
            modifiedImage = processImage.getProcessedImage( kinectImage );
            
            mainMesh.update( modifiedImage );

            
            kinectImage.flagImageChanged();
            //modifiedImage.flagImageChanged();
            
        }
    }
    
    else {
        bool bNewFrame = false;
        vidGrabber.update();
        bNewFrame = vidGrabber.isFrameNew();
        
        if (bNewFrame){
            
            colorImg.setFromPixels( vidGrabber.getPixels(), 320, 240 );
            grayImage = colorImg;
            modifiedImage = processImage.getProcessedImage( grayImage );
            mainMesh.update( modifiedImage );
            
        }
    }
	
    
    
    
	//let's move the camera when you move the mouse
	float rotateAmount = ofMap( ofGetMouseY(), 0, ofGetHeight(), 0, 360 );
	
	//move the camera around the mesh
	ofVec3f camDirection( 0, 0, 1 );
	ofVec3f centre( width / 2.f, height / 2.f, 255 / 2.f );
    ofVec3f camDirectionRotated = camDirection.rotated( rotX, rotY, rotZ );
	ofVec3f camPosition = centre + camDirectionRotated * extrusionAmount;
    camPosition += ofVec3f( transX, transY, transZ );
	
	cam.setPosition( camPosition );
	cam.lookAt( centre );
    
}

//--------------------------------------------------------------
void lanscapes::draw(){
    
    //we have to disable depth testing to draw the video frame
    ofDisableDepthTest();
	// draw the incoming, the grayscale, the bg and the thresholded difference
	//ofSetHexColor(0xffffff);
    
    if ( bDrawVideo ) {
        
        if ( useKinect ) {
            
            kinectImage.draw( 20, 20 );
            modifiedImage.draw( 320, 20 );
        }
        
        else {
            colorImg.draw( 20, 20);
            grayImage.draw( 320, 20);
            modifiedImage.draw( 700, 20 );
        }
        
    }
	
	//but we want to enable it to show the mesh
	ofEnableDepthTest();
	cam.begin();
    mainMesh.draw( bWireframe, bFaces );
	cam.end();
	
    if ( !fullscreen ) {
        //draw framerate for fun
        ofSetColor(255);
        string msg = "fps: " + ofToString(ofGetFrameRate(), 2);
        ofDrawBitmapString(msg, 10, 20);
    }
    
}

//--------------------------------------------------------------
void lanscapes::keyPressed(int key){
    
	switch (key){
		case 'f':
			fullscreen = !fullscreen;
			break;
            
        case '=':
            rotX += 10;
            break;
            
        case '-':
            rotX -= 10;
            break;
            
        case ']':
            rotY += 10;
            break;
            
        case '[':
            rotY -= 10;
            break;
            
        case '.':
            rotZ += 10;
            break;
            
        case ',':
            rotZ -= 10;
            break;
            
        case '1':
            transX += 10;
            break;
            
        case '2':
            transX -= 10;
            break;
            
        case '3':
            transY += 10;
            break;
            
        case '4':
            transY -= 10;
            break;
            
        case '5':
            transZ += 10;
            break;
            
        case '6':
            transZ -= 10;
            break;
            
        case '7':
            extrusionAmount += 10;
            break;
            
        case '8':
            extrusionAmount -= 10;
            break;
            
        case 'w':
            bWireframe = !bWireframe;
            break;
            
        case 'e':
            bFaces = !bFaces;
            break;
            
        case 'v':
            bDrawVideo = !bDrawVideo;
            break;
            
        case 'k':
            useKinect = !useKinect;
            break;
            
        case 'p':
            cout << "( transX, transY, transZ ): ( " << transX << ", " << transY << ", " << transZ << " )" << endl;
            cout << "( rotX, rotY, rotZ ): ( " << rotX << ", " << rotY << ", " << rotZ << " )" << endl;
	}
}

