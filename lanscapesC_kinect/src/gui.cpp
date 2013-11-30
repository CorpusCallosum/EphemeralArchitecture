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
    gui_panel.add(zOffset.set("zOffset", -20, -200,200));
    gui_panel.add(yOffset.set("yOffset", -20, -200,200));
    gui_panel.add(wireframe.setup("wireframe", true));
    gui_panel.add(faces.setup("faces", true));
    gui_panel.add(video.setup("video", false));
    
    hidden = true;
    ofHideCursor();
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
void gui::setzOffset(int z){
    zOffset.set(z);
}void gui::setyOffset(int y){
    yOffset.set(y);
}

void gui::draw(){
    if(!hidden){
        gui_panel.draw();
    }
}

void gui::show(){
    ofShowCursor();
    hidden = false;
}

void gui::hide(){
    ofHideCursor();
    hidden = true;
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

int gui::getyOffset(){
    return yOffset;
}
int gui::getzOffset(){
    return zOffset;
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