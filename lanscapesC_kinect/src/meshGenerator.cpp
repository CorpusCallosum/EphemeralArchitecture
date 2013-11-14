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
    
    colorGrid.resize( width * height );
    

    //add one vertex to the mesh for each pixel
	for ( int y = 0; y < height; y ++ ) {
		for ( int x = 0; x < width; x ++ ) {
			mainMesh.addVertex( ofPoint( x, y, 0 ));	// mesh index = x + y * width
            // this replicates the pixel array within the camera bitmap...
            
            colorGrid[ x + y * width ] = ofColor( 70, 216, 98 );
            
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
}

//--------------------------------------------------------------
ofVboMesh meshGenerator::update( ofxCvGrayscaleImage img ){
    
    meshImage = img;
    
    colorGrid = currentColor.getCurrentColor( meshImage );

    //this determines how far we extrude the mesh
    for ( int i = 0; i < width * height; i ++ ) {
        
        //colorGrid[ i ] = currentColor.getCurrentColor();
        
            float b = meshImage.getPixels()[ i ] / 255.f; //b & w image
            
            //now we get the vertex at this position
            //we extrude the mesh based on it's brightness
            ofVec3f tmpVec = mainMesh.getVertex( i );
            tmpVec.z = b * extrusionAmount;
            
            mainMesh.setVertex( i, tmpVec );
            mainMesh.setColor( i, colorGrid[ i ] );
    
    }
        
    return mainMesh;
}

//--------------------------------------------------------------
void meshGenerator::draw( bool wireframe, bool faces ) {
    
    bDrawWireframe = wireframe;
    bDrawFaces = faces;
    if ( bDrawWireframe ) {
        mainMesh.drawWireframe();
    }
    if ( bDrawFaces ) {
        mainMesh.drawFaces();
    }
    
}

//Export PLY mesh data file, with color
void meshGenerator::save(){
    mainMesh.save("export/"+ofGetTimestampString()+".ply");
}








