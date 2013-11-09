//
//  currentColor.cpp
//  
//
//  Created by curry on 11/8/13.
//
//

#include "currentColor.h"

//--------------------------------------------------------------
void currentColor::setup( int w, int h ) {
    
    width = w;
    height = h;
    
    //color timers
    startTime = ofGetSystemTime();
    currentTime = startTime;
    lastTime = 0;
    colorTime = 0;
    colorDuration = 1000 * 20; //how long each color lasts in ms
    
    colorPalette.resize( 5 );
    
    colorPalette[ 0 ] = ofColor( 0, 227, 221 );   //ice blue
    colorPalette[ 1 ] = ofColor( 21, 55, 232 );      //dark blue
    colorPalette[ 2 ] = ofColor( 88, 4, 180 );     //purple
    colorPalette[ 3 ] = ofColor( 170, 0, 170 );   //magenta
    colorPalette[ 4 ] = ofColor( 230, 230, 230 );  //white
    
    lastColor = 0;
    nextColor = 1;
    cycles = 1;
    
    currentColor = colorPalette[ lastColor ];
    fromColor = colorPalette[ lastColor ];
    toColor = colorPalette[ nextColor ];
    
    colorGrid.resize( width * height );
    meshImage.allocate( width, height );
    lastMeshImage.allocate( width, height );
    
    for ( int i = 0; i < width * height; i ++ ) {
        colorGrid[ i ] = colorPalette[ 0 ];
    }

}

//--------------------------------------------------------------
//ofColor currentColor::getCurrentColor() {
vector<ofColor> currentColor::getCurrentColor( ofxCvGrayscaleImage img) {
    
    meshImage = img;
    
    transSpeed = (float) colorTime / colorDuration;
    currentColor = fromColor.getLerped( toColor, transSpeed );
    
    currentTime = ofGetSystemTime() - startTime;//how long the sketch has been running in m
    
    if ( colorTime >= colorDuration ) {
        cycles ++;
        lastColor = nextColor;
        nextColor ++;
        if ( nextColor > colorPalette.size() - 1 ) {
            nextColor = 0;
        }
        fromColor = colorPalette[ lastColor ];
        toColor = colorPalette[ nextColor ];
    }
    if ( cycles > 1 ) {
        colorTime = currentTime - ((cycles - 1 ) * colorDuration );
    }
    else {
        colorTime = currentTime;
    }
    
    unsigned char * meshPix = meshImage.getPixels();
    unsigned char * lastPix = lastMeshImage.getPixels();
    for ( int i = 0; i < width * height; i ++ ) {
        if ( abs( meshPix[ i ] - lastPix[ i ] ) > 1 ) {
            colorGrid [ i ] = currentColor;
        }
    }
    
    lastMeshImage = meshImage;
    
    return colorGrid;
    
}