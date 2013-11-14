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

void processImage::setup( int w, int h, int low, int high ) {
    
    imgWidth = w;
    imgHeight = h;
    moveThreshLow = low;
    moveThreshHigh = high;
    kinectSource.allocate( imgWidth, imgHeight );
    kinectSource.set( 0.0 );//initialize all pixels black
    lastKinect.allocate( imgWidth, imgHeight );
    lastKinect.set( 0.0 );//initialize all pixels black
    modifiedImage.allocate( imgWidth, imgHeight );
    modifiedImage.set( 0.0 ); //initialize all pixels black
    difference.resize( imgWidth * imgHeight );
    
    alphaAmount = .03;
    _brightness = .1;
    _contrast = .2;
    
}

void processImage::update(float b, float c, float e){
    
    _brightness = b;
    cout<<b<<" is brightness"<<endl;
    _contrast = c;
    alphaAmount = e;
    
}

ofxCvGrayscaleImage processImage::getProcessedImage( ofxCvGrayscaleImage img ) {
    
    
    kinectSource = img;
    //kinectSource.mirror( true, true ); // mirror( bool bFlipVertically, bool bFlipHorizontally )
    kinectSource.brightnessContrast( _brightness, _contrast );
    
    sourcePixels = kinectSource.getPixels();
    lastPixels = lastKinect.getPixels();
    modifiedPixels = modifiedImage.getPixels();
        
    for ( int i = 0; i < imgWidth; i ++ ) {
        for ( int j = 0; j < imgHeight; j ++ ) {
            int loc = i + j * imgWidth;
            difference[ loc ] = sourcePixels[ loc ] - modifiedPixels[ loc ];
            float add = difference[ loc ] * alphaAmount;
            float modifiedPixel = modifiedPixels[ loc ];
            if ( add + modifiedPixel > 255.0 )
                modifiedPixels[ loc ] = 255;
            else if ( add + modifiedPixel < 0.0 )
                modifiedPixels[ loc ] = 0;
            else
                modifiedPixels[ loc ] += add;
            
            /*if ( abs( sourcePixels[ loc ] - lastPixels [ loc ] ) > moveThreshLow ){ //if the pixel is different than in the last frame from the kinect
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
            
            else if ( abs( sourcePixels[ loc ] - modifiedPixels[ loc ] ) > moveThreshLow && abs( sourcePixels[ loc ] - modifiedPixels[ loc ] ) < moveThreshHigh ) { //if the incoming pixel is far enough from the composite pixel change it, but if it's super far away, leave it
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
            //else {
              //  modifiedPixels[ loc ] = modifiedPixels[ loc ];
            }*/
        }
    }
    
    lastKinect = kinectSource;
    modifiedImage.setFromPixels( modifiedPixels, imgWidth, imgHeight );
   
    return modifiedImage;
    
    
}
