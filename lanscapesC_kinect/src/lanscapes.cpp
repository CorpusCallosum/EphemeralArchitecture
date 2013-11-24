#include "lanscapes.h"


//--------------------------------------------------------------
void lanscapes::setup(){
    
    //setup vars default values
    fullscreen = false; // f 
    bDrawVideo = true;  // v
    bWireframe = true;  // w draw wireframe mesh
    bFaces = true;      // e draw faces of main mesh
    //Set this to FALSE to use webcam
    useKinect = false;
    
    
    rotX = -160;
    rotY = 0;
    rotZ = 0;
    transX = 0;
    transY = -75;
    transZ = 90;
    
    width =  640;
    height = 480;
    extrusionAmount = 80.0;
    
    previousHour = ofGetHours();
    gui.setup();

    
    if ( useKinect ) {
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
    
    snapShot.allocate( width, height, OF_IMAGE_GRAYSCALE );
    background.allocate( width, height );
    snapShot.loadImage( "background.jpg" );
    snapShotPix = snapShot.getPixels();
    background.setFromPixels( snapShotPix, width, height );
    
    modifiedImage.setFromPixels( background.getPixels(), width, height );
    
    
    mainMesh.setup( 80, 60, extrusionAmount, true, true );// ( width, height, extrusion amount, draw wireframe, draw faces );
    processImage.setup( width, height, 5, 50, modifiedImage ); // (width, height, low threshold for movement, high threshold for movement);
    
    //setup camera starting position
    //move the camera around the mesh
	ofVec3f camDirection( 0, 0, 1 );
	ofVec3f centre( width / 2.f, height / 2.f, 128 / 2.f );
    ofVec3f camDirectionRotated = camDirection.rotated( rotX, rotY, rotZ );
	ofVec3f camPosition = centre + camDirectionRotated * extrusionAmount;
    camPosition += ofVec3f( transX, transY, transZ );
	
	cam.setPosition( camPosition );
	cam.lookAt( centre + ofVec3f( 0, -35, 0 ));
    
    // this sets the camera's distance from the object
	cam.setDistance(100);
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
//            kinectImage.resize( width, height );
            modifiedImage = processImage.getProcessedImage( kinectImage, background );
            
            
            mainMesh.update( modifiedImage );
            //kinectImage.flagImageChanged();
            
        }
    }
    
    else {
        bool bNewFrame = false;
        vidGrabber.update();
        bNewFrame = vidGrabber.isFrameNew();
        
        if (bNewFrame){
            
            colorImg.setFromPixels( vidGrabber.getPixels(), width, height );
            grayImage = colorImg;
            modifiedImage = processImage.getProcessedImage( grayImage, background );
            mainMesh.update( modifiedImage );
            
        }
    }

    
    //SAVE the mesh every hour
    int hour = ofGetHours();
    if(hour != previousHour){
        mainMesh.save();
        previousHour = hour;
    }
    
    
    float b = gui.getBrightness();
    float c = gui.getContrast();
    float e  = gui.getExtrusion();
    float a = gui.getAlpha();
    
    extrusionAmount=e;
    cout<<extrusionAmount<<endl;
    
    processImage.update(b,c,a);
    gui.update();
    
    
}

//--------------------------------------------------------------
void lanscapes::draw(){

    
    //we have to disable depth testing to draw the video frame
    ofDisableDepthTest();
    
    if ( bDrawVideo ) {
        
        if ( useKinect ) {
            kinectImage.draw( 20, 20, 320, 240 );
            modifiedImage.draw( 20 + 320, 20, 320, 240 );
            background.draw( 20 + 2 * 320, 20, 320, 240 );
        }
        
        else {
            
            colorImg.draw( 20, 20, 320, 240 );
            grayImage.draw( 20 + 320, 20, 320, 240 );
            modifiedImage.draw( 20 + 2 * 320, 20, 320, 240 );
            background.draw( 20 + 3 * 320, 20, 320, 240 );
            
        }
        
                
    }
    
    gui.draw();

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
            
        case 'g':
            gui.bHide = !gui.bHide;
            break;
            
        case 'p':
            cout << "( transX, transY, transZ ): ( " << transX << ", " << transY << ", " << transZ << " )" << endl;
            cout << "( rotX, rotY, rotZ ): ( " << rotX << ", " << rotY << ", " << rotZ << " )" << endl;
			break;
        case 's':
            //save the mesh and color data
            mainMesh.save();
			break;
		case 'b':
            if ( useKinect ) {
                snapShotPix = kinectImage.getPixels();
            }
            else {
                snapShotPix = grayImage.getPixels();
            }
            snapShot.setFromPixels( snapShotPix, width, height, OF_IMAGE_GRAYSCALE );
            snapShot.saveImage( "background.jpg" );
            background.setFromPixels( snapShotPix, width, height );
            break;
        case OF_KEY_UP:
            mainMesh.zOffset -= 1;
            break;
        case OF_KEY_DOWN:
            mainMesh.zOffset += 1;
            break;

	}
}


