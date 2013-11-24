//
//  processImage.cpp
//
//
//  Created by curry on 11/2/13.
//
//

#include "processImage.h"

processImage::processImage()
{
    
    
}

void processImage::setup( int w, int h, int low, int high, ofxCvGrayscaleImage background ) {
    
    imgWidth = w;
    imgHeight = h;
    moveThreshLow = low;
    moveThreshHigh = high;
    kinectSource.allocate( imgWidth, imgHeight );
    kinectSource.set( 0.0 );//initialize all pixels black
    modifiedImage.allocate( imgWidth, imgHeight );
    modifiedImage = background;
    
    backgroundPixels = background.getPixels();
    difference.resize( imgWidth * imgHeight );
    
    alphaAmount = .02;
    
    _contrast = 0.0;
    
    _brightness=gui.getBrightness();
    //cout<< _brightness << endl;
    
    
}

void processImage::update(){
    _brightness = gui.getBrightness();
    cout<< _brightness << endl;
    
   
    
}


ofxCvGrayscaleImage processImage::getProcessedImage( ofxCvGrayscaleImage img, ofxCvGrayscaleImage background ) {

    
    
    kinectSource = img;
    //kinectSource.mirror( true, true ); // mirror( bool bFlipVertically, bool bFlipHorizontally )
    //kinectSource.brightnessContrast( _brightness, _contrast );
    sourcePixels = kinectSource.getPixels();
    
    modifiedPixels = modifiedImage.getPixels();
    
    //background.mirror( true, true ); // mirror( bool bFlipVertically, bool bFlipHorizontally )
    //background.brightnessContrast( _brightness, _contrast );
    backgroundPixels = background.getPixels();

        
    for ( int i = 0; i < imgWidth; i ++ ) {
        for ( int j = 0; j < imgHeight; j ++ ) {
            int loc = i + j * imgWidth;
            difference[ loc ] = sourcePixels[ loc ] - modifiedPixels[ loc ];
            if ( abs( sourcePixels[ loc ] - backgroundPixels[ loc ] ) > moveThreshLow ) { //if the incoming pixel is different enough from the background image
                difference[ loc ] = sourcePixels[ loc ] - modifiedPixels[ loc ];
                float add = difference[ loc ] * alphaAmount;
                float modifiedPixel = modifiedPixels[ loc ];
                if ( add + modifiedPixel > 255.0 )
                    modifiedPixels[ loc ] = 255;
                else if ( add + modifiedPixel < 0.0 )
                    modifiedPixels[ loc ] = 0;
                else
                    modifiedPixels[ loc ] += add;
            }
        }
    }
    
    
    modifiedImage.setFromPixels( modifiedPixels, imgWidth, imgHeight );
   
    return modifiedImage;
    
    
}


