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

void processImage::setup( int w, int h, int low, int high, ofxCvGrayscaleImage modified ) {
    
    imgWidth = w;
    imgHeight = h;
    moveThreshLow = low;
    moveThreshHigh = high;
    kinectSource.allocate( imgWidth, imgHeight );
    kinectSource.set( 0.0 );//initialize all pixels black
    lastKinect.allocate( imgWidth, imgHeight );
    lastKinect.set( 0.0 );//initialize all pixels black
    modifiedImage.allocate( imgWidth, imgHeight );
    modifiedImage = modified;
    difference.resize( imgWidth * imgHeight );
    
    alphaAmount = .02;
    _brightness = 0.2;
    _contrast = 0.2;
    
    lastImages.resize( 10 );
    
    for ( int i = 0; i < lastImages.size(); i ++ ) {
        lastImages[ i ].allocate( imgWidth, imgHeight );
    }
    
}

void processImage::update(float b, float c, float e){
    
    _brightness = b;
    cout<<b<<" is brightness"<<endl;
    _contrast = c;
    alphaAmount = e;
    
}

ofxCvGrayscaleImage processImage::getProcessedImage( ofxCvGrayscaleImage img ) {
    
    
    kinectSource = img;
    kinectSource.mirror( true, true ); // mirror( bool bFlipVertically, bool bFlipHorizontally )
    kinectSource.brightnessContrast( _brightness, _contrast );
    
    sourcePixels = kinectSource.getPixels();
    lastPixels = lastKinect.getPixels();
    modifiedPixels = modifiedImage.getPixels();
        
    for ( int i = 0; i < imgWidth; i ++ ) {
        for ( int j = 0; j < imgHeight; j ++ ) {
            int loc = i + j * imgWidth;
            difference[ loc ] = sourcePixels[ loc ] - modifiedPixels[ loc ];
            
            if ( abs( sourcePixels[ loc ] - lastPixels[ loc ] ) > moveThreshHigh ){ //if the pixel is very different than in the last frame from the kinect
                modifiedPixels[ loc ] = modifiedPixels[ loc ]; //keep the ond one
            }
            
            else if ( abs( sourcePixels[ loc ] - lastPixels[ loc ] ) < moveThreshLow && abs( sourcePixels[ loc ] - modifiedPixels [ loc ] ) > 120 ){ //if the pixel is the same as the last incoming, but very different from in the image used to generate the mesh
                modifiedPixels[ loc ] = modifiedPixels[ loc ]; //keep the old one
            }
            
            
            else {
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
    
    
    
    /*for ( int i = 0; i < lastImages.size() - 1; i ++ ) { // working on averaging the previous frames 
        lastImages[ i ] = lastImages[ i + 1 ];
    }
    lastImages[ lastImages.size() ] = kinectSource;
    
    vector<unsigned char *> lastImagePix[ lastImages.size() ];
    unsigned char * averagePix;
    for ( int i = 0; i < imgWidth * imgHeight; i ++ ) {
        for ( int j = 0; j < lastImages.size(); j ++ ) {
            averagePix[ i ] += lastImages[ i ][ j ];
        }
    }*/
    
    lastKinect = kinectSource;
    modifiedImage.setFromPixels( modifiedPixels, imgWidth, imgHeight );
   
    return modifiedImage;
    
    
}
