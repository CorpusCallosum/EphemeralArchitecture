#include "lanscapes.h"


//--------------------------------------------------------------
void lanscapes::setup(){
    //load settings xml data file
    //-----------
	//the string is printed at the top of the app
	//to give the user some feedback
	message = "loading settings.xml";
    
	//we load our settings file
	//if it doesn't exist we can still make one
	//by hitting the 's' key
	if( XML.loadFile("settings.xml") ){
		message = "settings.xml loaded!";
	}else{
		message = "unable to load settings.xml check data/ folder";
	}
    
    ofSetFullscreen( true );
    
    //setup gui and initial values from xml
    gui.setup();
    gui.setBrightness(XML.getValue("group:brightness", .2));
    gui.setContrast(XML.getValue("group:contrast", .2));
    gui.setExtrusion(XML.getValue("group:extrusion", .2));
    gui.setAlphaValue(XML.getValue("group:AlphaValue", .2));
    gui.setRotX(XML.getValue("group:rot_x", 20));
    gui.setzOffset(XML.getValue("group:zOffset", 20));
    gui.setyOffset(XML.getValue("group:yOffset", 20));

    
    
    
    //setup vars default values
    //PRESS B TO CAPTURE BACKGROUND//
    fullscreen = true; // f
    bDrawVideo = gui.drawVideo();  // v , should be false
    bWireframe = gui.isWireOn();  // w draw wireframe mesh, should be true
    bFaces = gui.drawFaces();// true;      // e draw faces of main mesh
    //Set this to FALSE to use webcam
    useKinect = true;
    
    
    rotX = gui.getX();//set RotX value from the gui
    
    rotY = 0;
    rotZ = 0;
    transX = 0;
    transY = -75;
    transZ = 90;
    
    width =  640;
    height = 480;
    extrusionAmount = gui.getExtrusion();
    
    previousHour = ofGetHours();

    
    
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
    
    
    mainMesh.setup( 64, 48, extrusionAmount, true, true );// ( width, height, extrusion amount, draw wireframe, draw faces );
    processImage.setup( width, height, 10, 10, modifiedImage ); // (width, height, low threshold for movement, flicker);
    
    //set values from the xml file
    mainMesh.zOffset = XML.getValue("zOffset", 0);
    mainMesh.yOffset = XML.getValue("yOffset", 0);

    
    
    mainMesh.wireframeBrightness = XML.getValue("wireframe:brightness", 255);
    mainMesh.wireframeSaturation = XML.getValue("wireframe:saturation", 100);
    
    
    //setup camera starting position
    //move the camera around the mesh
    ofVec3f camDirection( 0, 0, 1 );
    ofVec3f centre( width / 2.f, height / 2.f, 128 / 2.f );
    camDirectionRotated = camDirection.rotated( rotX, rotY, rotZ );
    ofVec3f camPosition = centre + camDirectionRotated * extrusionAmount;
    camPosition += ofVec3f( transX, transY, transZ );
	
    cam.setPosition( camPosition );
    cam.lookAt( centre + ofVec3f( 0, -35, 0 ));
    
    // this sets the camera's distance from the object
    cam.setDistance(100);
    cam.disableMouseInput();
}

//----------------------------------------------------------
void lanscapes::update(){

	ofBackground( 0 );
    
    if ( useKinect ) {
        kinect.update();
        if(kinect.isFrameNew()) {
            // load grayscale depth image from the kinect source
            kinectImage.setFromPixels( kinect.getDepthPixels(),kinect.width, kinect.height);
            //mirror the image
            kinectImage.mirror(false, true);
            modifiedImage = processImage.getProcessedImage( kinectImage, background );
            mainMesh.update( modifiedImage , extrusionAmount);

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
            mainMesh.update( modifiedImage , extrusionAmount);
        }
        
    }
    
    //SAVE the mesh every hour
    int hour = ofGetHours();
    if(hour != previousHour){
        mainMesh.save();
        previousHour = hour;
    }
    
    //get  data from gui
    float b = gui.getBrightness();
    float c = gui.getContrast();
    extrusionAmount  = gui.getExtrusion();
    float a = gui.getAlpha();
    rotX = gui.getX();
    
    processImage.update(b,c,a);
    
    //wireframe
    bWireframe = gui.isWireOn();
    bDrawVideo = gui.drawVideo();
    bFaces = gui.drawFaces();//   e draw faces of main mesh
    mainMesh.yOffset = gui.getyOffset();
    mainMesh.zOffset = gui.getzOffset();



    
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
    //rotate the camera
    ofRotateX(rotX);
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
            ofSetFullscreen( fullscreen );
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
            if(gui.hidden){
                gui.show();
            }
            else{
                gui.hide();
            }
            break;
            
            case 'p':
            cout << "( transX, transY, transZ ): ( " << transX << ", " << transY << ", " << transZ << " )" << endl;
            cout << "( rotX, rotY, rotZ ): ( " << rotX << ", " << rotY << ", " << rotZ << " )" << endl;
            cout << "( yOffset, zOffset ): ( " << mainMesh.yOffset << ", " << mainMesh.zOffset << " )" << endl;
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
            case OF_KEY_LEFT:
            mainMesh.yOffset += 1;
            break;
            case OF_KEY_RIGHT:
            mainMesh.yOffset -= 1;
            break;
 		case 'x':
            saveXML();
            break;
            
	}
    
}

void lanscapes::saveXML(){
    XML.setValue("brightness", gui.getBrightness());
    XML.setValue("contrast", gui.getContrast());
    XML.setValue("extrusion", gui.getExtrusion());
    XML.setValue("AlphaValue", gui.getAlpha());
    XML.setValue("rot_x", gui.getX());
    XML.setValue("zOffset", gui.getzOffset());
    XML.setValue("yOffset", gui.getyOffset());


   // XML.setValue("zOffset", mainMesh.zOffset);
    XML.save("settings.xml");
}




