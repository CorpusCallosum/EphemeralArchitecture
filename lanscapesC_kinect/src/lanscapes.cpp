#include "lanscapes.h"
GLfloat lightOnePosition[] = {40.0, 40, 100.0, 0.0};
GLfloat lightOneColor[] = {0.99, 0.99, 0.99, 1.0};

GLfloat lightTwoPosition[] = {-40.0, 40, 100.0, 0.0};
GLfloat lightTwoColor[] = {0.99, 0.99, 0.99, 1.0};


//--------------------------------------------------------------
void lanscapes::setup(){
    ofSetVerticalSync(true);
    ofEnableSmoothing();
    
    shader.load("shaders/shader");
    
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
    gui.setAlphaValue(XML.getValue("group:alphaValue", .2));
 	gui.setMovementThreshold(XML.getValue("group:movementThreshold", 10));
    gui.setFlickerThreshold(XML.getValue("group:flickerThreshold", 10));
    gui.setFarThreshold(XML.getValue("group:far_threshold", 108));
    
    gui.setRotX(XML.getValue("group:rot_x", 20));
    gui.setxOffset(XML.getValue("group:xOffset", 20));
    gui.setyOffset(XML.getValue("group:yOffset", 20));
    gui.setzOffset(XML.getValue("group:zOffset", 20));
    
    gui.mirrorV = XML.getValue("group:mirror_vertically", false);
    gui.mirrorH = XML.getValue("group:mirror_horizontally", false);
    saveHour = ofToInt(XML.getValue("group:save_hour", "18"));
    
    //Set this to FALSE to use webcam
    //TODO: add this to the XML file
    useKinect = true;//ofToBool(XML.getValue("group:use_kinect", "1"));

    
    //setup vars default values
    //PRESS B TO CAPTURE BACKGROUND//
    fullscreen = true; // f
    bDrawVideo = gui.drawVideo();  // v , should be false
    bWireframe = gui.isWireOn();  // w draw wireframe mesh, should be true
    bFaces = gui.drawFaces();// true;      // e draw faces of main mesh
    bColorWireframe = gui.colorWireframe();
    
    rotX = gui.getX();//set RotX value from the gui
    
    rotY = 0;
    rotZ = 0;
    transX = 0;
    transY = -75;
    transZ = 90;
    
    width =  600;
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
	
    //webcam images
    colorImg.allocate( width, height );
    grayImage.allocate( width, height );
    
    //image used to draw mesh
    modifiedImage.allocate( width, height );
    kinectImage.allocate( kinect.width, kinect.height );
    
    //thresholding
    nearThreshold = 255;
    farThreshold = 155;
    
    //croping
    kinectImage.setROI(0, 0, width, height);
    croppedImg.allocate(width, height);
    
    //reference image
    snapShot.allocate( width, height, OF_IMAGE_GRAYSCALE );
    background.allocate( width, height );
    snapShot.loadImage( "background.jpg" );
    snapShotPix = snapShot.getPixels();
    background.setFromPixels( snapShotPix, width, height );
    
    modifiedImage.setFromPixels( background.getPixels(), width, height );
    
    
    mainMesh.setup( 64, 48, extrusionAmount, true, true );// ( width, height, extrusion amount, draw wireframe, draw faces );
    processImage.setup( width, height, 10, 10, modifiedImage ); // (width, height, low threshold for movement, flicker);
    
    //set values from the xml file
    mainMesh.xOffset = XML.getValue("xOffset", 0);
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
    
    //setup lighting
    
    glShadeModel (GL_SMOOTH);
    
    /* initialize lighting */
   /* glLightfv (GL_LIGHT0, GL_POSITION, lightOnePosition);
    glLightfv (GL_LIGHT0, GL_DIFFUSE, lightOneColor);
    glEnable (GL_LIGHT0);
    glLightfv (GL_LIGHT1, GL_POSITION, lightTwoPosition);
    glLightfv (GL_LIGHT1, GL_DIFFUSE, lightTwoColor);
    glEnable (GL_LIGHT1);
    glEnable (GL_LIGHTING);
    glColorMaterial (GL_FRONT_AND_BACK, GL_DIFFUSE);
    glEnable (GL_COLOR_MATERIAL);*/
   
    ofSetSmoothLighting(true);
    // Point lights emit light in all directions //
    // set the diffuse color, color reflected from the light source //
    pointLight.setDiffuseColor( ofColor(255.f, 255.f, 255.f));
    
    // specular color, the highlight/shininess color //
	pointLight.setSpecularColor( ofColor(255.f, 0.f, 0.f));
	pointLight.setPointLight();
    
    
    //setup materials
    // shininess is a value between 0 - 128, 128 being the most shiny //
	material.setShininess( 60 );
    // the light highlight of the material //
	material.setSpecularColor(ofColor(255, 255, 255, 255));
}


//----------------------------------------------------------
void lanscapes::update(){

	ofBackground( 0 );
    
    farThreshold = gui.farThreshold;
    //cout << "farThreshold: " << farThreshold << endl;
    
    if ( useKinect ) {
        kinect.update();
        if(kinect.isFrameNew()) {
            // load grayscale depth image from the kinect source
            kinectImage.setFromPixels( kinect.getDepthPixels(),kinect.width, kinect.height);
            
            unsigned char * pix = kinectImage.getPixels();
			
			int numPixels = kinectImage.getWidth() * kinectImage.getHeight();
			for(int i = 0; i < numPixels; i++) {
				if(pix[i] > nearThreshold || pix[i] < farThreshold) {
					pix[i] = 0;
				}
                else{ pix[i] = ofMap( pix[i], farThreshold, 255, 0, 255 );}
			}
            
            croppedImg.scaleIntoMe(kinectImage);
            //mirror the image  - causese black line :(
            croppedImg.mirror(gui.mirrorV, gui.mirrorH);
            modifiedImage = processImage.getProcessedImage( croppedImg, background );
            mainMesh.update( modifiedImage , extrusionAmount, bColorWireframe );

        }
    }
    else {
        bool bNewFrame = false;
        vidGrabber.update();
        bNewFrame = vidGrabber.isFrameNew();
        
        if (bNewFrame){
            colorImg.setFromPixels( vidGrabber.getPixels(), width, height );
            colorImg.mirror(gui.mirrorV, gui.mirrorH);
            grayImage = colorImg;
            modifiedImage = processImage.getProcessedImage( grayImage, background );
            mainMesh.update( modifiedImage , extrusionAmount, bColorWireframe);
        }
    }
    
    //**********
    //need to add an event listener here to the mainMesh object
    //should return an event each time the change threshold on the mesh is triggerred
    //should return information about the extrusion depth and x,y location (x,y,z of modified point)
    //use this info to trigger audio
    //**********
    
    
    //SAVE the mesh every hour
    int hour = ofGetHours();
    if( hour != previousHour && hour == saveHour )
    { //save at 5pm every day
        mainMesh.save();
        previousHour = hour;
    }
    
    //get  data from gui
    float b = gui.getBrightness();
    float c = gui.getContrast();
    extrusionAmount  = gui.getExtrusion();
    float a = gui.getAlpha();
    rotX = gui.getX();
    int m = gui.getMovementThreshold();
    int t = gui.getFlickerThreshold();
    processImage.update( b, c, a, m, t);
    
    //wireframe
    bWireframe = gui.isWireOn();
    bDrawVideo = gui.drawVideo();
    bColorWireframe = gui.colorWireframe();
    bFaces = gui.drawFaces();//   e draw faces of main mesh
    mainMesh.yOffset = gui.getyOffset();
    mainMesh.zOffset = gui.getzOffset();
    mainMesh.xOffset = gui.getxOffset();


    pointLight.setPosition( mouseX, mouseY, 200);
}

//--------------------------------------------------------------
void lanscapes::draw(){
    // enable lighting //
    ofEnableLighting();
    ofEnableDepthTest();
    
    //DRAW THE MESH!
   
    
    ////DRAW THE MESH
	cam.begin();
    pointLight.enable();
    material.begin();
    //rotate the camera
    ofRotateX(rotX);
    
    //shader.begin();
    mainMesh.draw( bWireframe, bFaces );
    //shader.end();
    material.end();
    pointLight.disable();
    cam.end();
    
	

    
    // turn off lighting //
    ofDisableLighting();
    
	ofSetColor( pointLight.getDiffuseColor() );
	pointLight.draw();
    
    ////DRAW DEPTH IMAGES [DEBUG]
    //we have to disable depth testing to draw the video frame
    ofDisableDepthTest();
    if ( bDrawVideo ) {
        
        if ( useKinect ) {
            int margin = 20;
            int w = 320;
            int h = 230;
            kinectImage.draw( margin, 20, w, h );
            modifiedImage.draw( 20 + w+margin, margin, w, h );
            background.draw( 20 + (w+margin)*2, margin, w, h );
        }
        
        else {
            colorImg.draw( 20, 20, 320, 240 );
            grayImage.draw( 20 + 320, 20, 320, 240 );
            modifiedImage.draw( 20 + 2 * 320, 20, 320, 240 );
            background.draw( 20 + 3 * 320, 20, 320, 240 );
        }
        
        
    }
    
    ////DRAW THE GUI
    gui.draw();
    
}

//--------------------------------------------------------------
void lanscapes::keyPressed(int key){
    
	switch (key){
            case 'f':
			fullscreen = !fullscreen;
            ofSetFullscreen( fullscreen );
			break;
            
        case '>':
		case '.':
			farThreshold ++;
			if (farThreshold > 255) farThreshold = 255;
            cout<< farThreshold<< endl;
			break;
			
		case '<':
		case ',':
			farThreshold --;
			if (farThreshold < 0) farThreshold = 0;
            cout<< farThreshold<< endl;
			break;
			
		case '+':
		case '=':
			nearThreshold ++;
			if (nearThreshold > 255) nearThreshold = 255;
            cout<< nearThreshold<< endl;
			break;
			
		case '-':
			nearThreshold --;
			if (nearThreshold < 0) nearThreshold = 0;
            cout<< nearThreshold<< endl;
			break;
            
        case ']':
            rotY += 10;
            break;
            
        case '[':
            rotY -= 10;
            break;
            
        case 'w':
            bWireframe = !bWireframe;
            break;
            
        case 'e':
            bFaces = !bFaces;
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
            cout << "( yOffset, zOffset ): ( " << mainMesh.yOffset << ", " << mainMesh.zOffset << ", "<<mainMesh.xOffset<<" )" << endl;
			break;
            
            case 's':
            //save the mesh and color data
            mainMesh.save();
			break;
        
        case 'b':
                if ( useKinect ) {
                    snapShotPix = croppedImg.getPixels();
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
            
	}
    
}