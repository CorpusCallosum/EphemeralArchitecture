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
    
    imgWidth = 640;
    imgHeight = 480;
    kinectSource.allocate( imgWidth, imgHeight );
    differenceImage.allocate( imgWidth, imgHeight );
    modifiedImage.allocate( imgWidth, imgHeight );
    modifiedImage.set( 0.0 ); //initialize all pixels black
    
    difference.resize( imgWidth * imgHeight );
    
}

ofxCvGrayscaleImage processImage::getProcessedImage( ofxCvGrayscaleImage img ) {
    
    
    kinectSource = img;
    kinectSource.mirror( true, true ); // mirror( bool bFlipVertically, bool bFlipHorizontally )
    //kinectSource.brightnessContrast( _brightness, _contrast );
    
    sourcePixels = kinectSource.getPixels();
    lastPixels = modifiedImage.getPixels();
        
    for ( int i = 0; i < imgWidth; i ++ ) {
        for ( int j = 0; j < imgHeight; j ++ ) {
            int loc = i + j * imgWidth;
//            difference[loc] = sourcePixels[loc] > lastPixels[loc] ?
//                sourcePixels[loc] - lastPixels[loc] :
//                lastPixels[loc] - sourcePixels[loc];
            
            difference[ loc ] = sourcePixels[ loc ] - lastPixels[ loc ];
            float add = difference[ loc ] * 0.01;
            float lastPixel = lastPixels[ loc ];
            if ( add + lastPixel > 255.0 )
                lastPixels[ loc ] = 255;
            else if ( add + lastPixel < 0.0 )
                lastPixels[ loc ] = 0;
            else
                lastPixels[ loc ] += add;
            
//            if ( lastPixels[ loc ] > 255) { lastPixels [ loc ] = 255;}
//            else if ( lastPixels[ loc ] < 0) { lastPixels [ loc ] = 0;}

        }
    }
    modifiedImage.setFromPixels( lastPixels, imgWidth, imgHeight );
        
    return modifiedImage;
    
    
}
