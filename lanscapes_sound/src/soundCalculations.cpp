//
//  soundCalculations.cpp
//  
//
//  Created by curry on 6/12/14.
//
//

#include "soundCalculations.h"

void soundCalculations::setup( int w, int h, float u, float d ) {
    
    frameWidth = w;
    frameHeight = h;
    upSpeed = u;
    downSpeed = d;
    
    numSounds = 5;
    
    soundCenter.resize( numSounds );
    soundCenter[ 0 ].set( 100.0, 100.0 );
    soundCenter[ 1 ].set( 160.0, 400.0 );
    soundCenter[ 2 ].set( 300.0, 240.0 );
    soundCenter[ 3 ].set( 400.0, 300.0 );
    soundCenter[ 4 ].set( 600.0, 480.0 );
    
    soundRadius.resize( numSounds );
    soundRadius[ 0 ] = 200;
    soundRadius[ 1 ] = 150;
    soundRadius[ 2 ] = 100;
    soundRadius[ 3 ] = 150;
    soundRadius[ 4 ] = 150;

    soundPan.resize( numSounds );
    soundVolume.resize( numSounds);
    distance.resize( numSounds );
    for ( int i = 0; i < numSounds; i ++ ) {
        soundVolume[ i ] = 0.0;
    }
    soundPan[ 0 ] = -1.0;
    soundPan[ 1 ] = -0.5;
    soundPan[ 2 ] = 0;
    soundPan[ 3 ] = 0.5;
    soundPan[ 4 ] = 1.0;
}

void soundCalculations::calculateSound( int location ) { //if there is motion, increase the volume of sounds based on location of movement

    loc = location;
    float y = loc / 600;
    float x = loc - y * 600;
        
    for ( int i = 0; i < numSounds; i ++ ){
        distance[ i ] = ofDist( x, y, soundCenter[ i ].x, soundCenter[ i ].y );
        
        if ( distance[ i ] < soundRadius[ i ] && ofRandom( 0.0, 50.0 ) < 5 ) {
            soundVolume[ i ] += ( soundRadius[ i ] - distance[ i ] ) * upSpeed;
            //cout << "soundVolume[ " << i << " ]: " << soundVolume[ i ]  << endl;

            
            if ( soundVolume[ i ] >= 0.8 ) {
                soundVolume[ i ] = 0.8;
            }
        }
    }
}

void soundCalculations::update() { //volume slowly returns to silence with stillness
    
    for ( int i = 0; i < numSounds; i ++ ){
        soundVolume[ i ] -= downSpeed;
        if ( soundVolume[ i ] <= 0.0 ) {
            soundVolume[ i ] = 0.0;
        }
    }
}

vector <float> soundCalculations::getVolume() {
    return soundVolume;
}

vector <float> soundCalculations::getPan() {
    return soundPan;
}



