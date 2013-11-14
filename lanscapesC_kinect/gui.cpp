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
    
    gui_panel.setup();
    
    gui_panel.add(brightness.setup("brightness", 0, 0.0, 1));
    gui_panel.add(contrast.setup("contrast", 0.0 , 0.0, 1));
    gui_panel.add(extrusion.setup("extrusion", 200, 0, 500));
    gui_panel.add(growthFactor.setup("growthFactor", 0.05, 0.01, 0.1));
    

    bHide = false;
}

void gui::update(){
    
    
}

void gui::draw(){
    if(bHide){
        gui_panel.draw();
    }
}
