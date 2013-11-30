//
//  gui.cpp
//  LANscapes
//
//  Created by gabriella levine on 11/13/13.
//
//

//--------------------------------------------------------------


#include "gui.h"

void gui::setup(){
    ofSetVerticalSync(true);
    
    gui_panel.setup();
    
    gui_panel.add(brightness.set("brightness", 0.3, 0.0, 1));
    gui_panel.add(contrast.set("contrast", 0.2 , 0.0, 1));
    gui_panel.add(extrusion.set("extrusion", 65, 0, 500));
    gui_panel.add(alphaValue.set("alphaValue", 0.05, 0.01, 0.1));
    gui_panel.add(rot_x.set("rot_x", -20,-360,360));
    gui_panel.add(zOff.set("zOffset", -20, -200,200));
    gui_panel.add(yOff.set("yOffset", -20, -200,200));
    gui_panel.add(wireframe.setup("wireframe", true));
    gui_panel.add(faces.setup("faces", true));
    gui_panel.add(video.setup("video", false));
    
    bHide = false;
    
}

//set the parameters
void gui::setBrightness(float b){
    brightness.set(b);
}
void gui::setContrast(float c){
    contrast.set(c);
}
void gui::setExtrusion(float e){
    extrusion.set(e);
}
void gui::setAlphaValue(float a){
    alphaValue.set(a);
}
void gui::setRotX(int r){
    rot_x.set(r);
}
void gui::setzOff(int z){
    zOff.set(z);
}void gui::setyOff(int y){
    yOff.set(y);
}

void gui::draw(){
    if(bHide){
        gui_panel.draw();
    }
}

float gui::getBrightness(){
    return brightness;
    
}

float gui::getExtrusion(){
    return extrusion;
    
}

float gui::getContrast(){
    return contrast;
    
}
float gui::getAlpha(){
    return alphaValue;
    
}

int gui::getX(){
    return rot_x;
}

int gui::getyOff(){
    return yOff;
}
int gui::getzOff(){
    return zOff;
}

bool gui::isWireOn(){
    return wireframe;
}

bool gui::drawVideo(){
    return video;
}

bool gui::drawFaces(){
    return faces;
    
}