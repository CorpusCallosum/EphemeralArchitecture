//
//  meshGenerator.cpp
//  
//
//  Created by curry on 11/7/13.
//
//

#include "meshGenerator.h"

//--------------------------------------------------------------
void meshGenerator::setup( int w, int h, float extrusion, bool wireframe, bool faces ){

    width = w;
    height = h;
    xOffset=0;
    zOffset = -4;
    yOffset = -23;
    
    colorGrid.resize( width * height );
    

    //add one vertex to the mesh for each pixel
	for ( int y = 0; y < height; y ++ ) {
		for ( int x = 0; x < width; x ++ ) {
			mainMesh.addVertex( ofPoint( x, y, 0 ));	// mesh index = x + y * width
            // this replicates the pixel array within the camera bitmap...
            
            mainMesh.addNormal(ofVec3f(ofRandom(1), ofRandom(1),ofRandom(1)));
            
            colorGrid[ x + y * width ] = ofColor( 237, 237, 237 );
            
            mainMesh.addColor( colorGrid[ x + y * width] );  // placeholder for colour data, we'll get this from the camera
		}
	}
    
    for ( int y = 0; y < height - 1; y ++ ) {
		for ( int x = 0; x < width - 1; x ++ ) {
			mainMesh.addIndex( x + y * width );                 // 0
			mainMesh.addIndex(( x + 1 ) + y * width );			// 1
			mainMesh.addIndex( x + ( y + 1 ) * width );			// 10

            
			mainMesh.addIndex(( x + 1 ) + y * width );			// 1
			mainMesh.addIndex(( x + 1 ) + ( y + 1 ) * width );	// 11
			mainMesh.addIndex( x + ( y + 1 ) * width );			// 10

		}
	}
    
    //this determines how much we push the meshes out
	extrusionAmount = extrusion;

    bDrawWireframe = wireframe;
    bDrawFaces = faces;
    
    currentColor.setup( width, height );
    
    //make a copy of this mesh
    wireframeMesh = mainMesh;
    
    noiseImage.allocate( width, height, OF_IMAGE_GRAYSCALE );
    lastMeshImage.allocate( width, height);
    
}

//--------------------------------------------------------------
ofVboMesh meshGenerator::update( ofxCvGrayscaleImage img, float extrusion, bool colorWireframe ){
    img.resize(width, height);
    meshImage = img;
    bColorWireframe = colorWireframe;
    
    //return a vector of color values for the mesh
    colorGrid = currentColor.getCurrentColor( meshImage );
    
    //perlin noise image update
    for ( int y = 0; y < height; y ++ ) {
        for ( int x = 0; x < width; x ++ ) {
            
            float a = x * .7;
            float b = y * .7;
            float c = ofGetFrameNum() / 120.0;
            
            float noise = ofNoise( a, b, c ) * 255;
            float color = noise < 210  ? ofMap( noise, 0, 210, 210, 255 ) : 210;
            
            noiseImage.getPixels()[ y * width + x ] = color;
        }
    }
    noiseImage.reloadTexture();
    unsigned char * noisePixels = noiseImage.getPixels();
    
    
    //this determines how far we extrude the mesh
    for ( int i = 0; i < width * height; i ++ ) {
        
        //colorGrid[ i ] = currentColor.getCurrentColor();
        
        float b = meshImage.getPixels()[ i ] / 255.f; //b & w image
        
        //now we get the vertex at this position
        //we extrude the mesh based on it's brightness
        ofVec3f tmpVec = mainMesh.getVertex( i );
        extrusionAmount = extrusion;
        
        //extrude using negative value to pull the mesh UP
        tmpVec.z = -b * extrusionAmount;
        mainMesh.setVertex( i, tmpVec );
        wireframeMesh.setVertex( i, tmpVec );
        
        //here we need to set the normals also
        //***HOW TO CALCULATE THIS?
         mainMesh.setNormal( i, ofVec3f(ofRandom(1),ofRandom(1),ofRandom(1)) );
        
        //set the mesh color
        ofColor c = colorGrid[ i ];
        mainMesh.setColor( i, c );
        
        //set the wireframe color
        if ( bColorWireframe ) {
            c.setBrightness( noisePixels[ i ] ); //wireframeBrightness);
            c.setSaturation(wireframeSaturation);
            wireframeMesh.setColor(i, c);
        }
        else {
            ofColor whiteNoise = noisePixels[ i ];
            wireframeMesh.setColor( i, whiteNoise );
        }
    }
    
    
    //throw an event if the mesh changes from frame to frame
    unsigned char * meshPix = meshImage.getPixels();
    unsigned char * lastPix = lastMeshImage.getPixels();
    
    //if the difference exceeds the threshold, change the color
    int thresh = 1;
    for ( int i = 0; i < width * height; i ++ ) {
        if ( abs( meshPix[ i ] - lastPix[ i ] ) > thresh ) {
            //throw an event if the mesh changes from frame to frame
          //  ofNotifyEvent(meshGenerator::onMeshChange, meshPix[ i ], i);
        }
    }
    
    lastMeshImage = meshImage;
    
    
    return mainMesh;
}

//--------------------------------------------------------------
void meshGenerator::draw( bool wireframe, bool faces ) {
    
    ofTranslate(-width/2 + xOffset, -height/2 + yOffset, zOffset);
    
    bDrawWireframe = wireframe;
    bDrawFaces = faces;
    
    
    if ( bDrawWireframe ) {
        //draw the wireframe mesh
        wireframeMesh.drawWireframe();
    }
    if ( bDrawFaces ) {
        mainMesh.drawFaces();
    }
    
    
    
}

//Export PLY mesh data file, with color
void meshGenerator::save(){
    mainMesh.save("export/"+ofGetTimestampString()+".ply");
}







