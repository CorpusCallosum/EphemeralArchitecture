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
    
    gui_panel.add(brightness.set("brightness", 0.1, 0.0, 1));
    gui_panel.add(contrast.set("contrast", 0.1, 0.0, 1));
    gui_panel.add(extrusion.set("extrusion", 80, 0, 100));
    gui_panel.add(alphaValue.set("alphaValue", 0.02, 0.001, 0.1));
    //gui_panel.add(buttonTest.setup(");

    bHide = false;
}

void gui::update(){
}

void gui::draw(){
    if(bHide){
        gui_panel.draw();
        //cout<<brightness<<"  is brightness"<<endl;
    }
}

float gui::getBrightness(){
   
  //  cout<<brightness<<"is brightness _";
    return brightness;
    
}

float gui::getExtrusion(){
    
    //  cout<<brightness<<"is brightness _";
    return extrusion;
    
}

float gui::getContrast(){
    
    //  cout<<brightness<<"is brightness _";
    return contrast;
    
}
float gui::getAlpha(){
    return alphaValue;
    
}
