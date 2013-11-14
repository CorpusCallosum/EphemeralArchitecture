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
    
    gui_panel.add(brightness.set("brightness", 0.2, 0.0, 1));
    gui_panel.add(contrast.set("contrast", 0.2 , 0.0, 1));
    gui_panel.add(extrusion.set("extrusion", 200, 0, 500));
    gui_panel.add(growthFactor.set("growthFactor", 0.05, 0.01, 0.1));
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