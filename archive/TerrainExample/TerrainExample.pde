/**
 * This demo shows a simple 2D car steering algorithm and alignment of
 * the car on the 3D terrain surface. The demo also features a third
 * person camera, following the car and re-orienting itself towards the
 * current direction of movement. The camera ensures it's always positioned
 * above ground level too...
 *
 * <p>Usage: use cursor keys to control car
 * <ul>
 * <li>up: accelerate</li>
 * <li>down: break</li>
 * <li>left/right: steer</li>
 * </ul>
 * </p>
 */

/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.processing.*;

import processing.opengl.*;

Terrain terrain;
ToxiclibsSupport gfx;
Mesh3D mesh;

PImage img;

void setup() {
  size(1024, 576, OPENGL);
  //load image
   img=loadImage("heightmap.png");
  
  // create terrain & generate elevation data
  terrain = new Terrain(round(img.width),round(img.height), round(50));
  float[] el = new float[img.width*img.height];
  
   for (int z = 0, i = 0; z < img.height; z++) {
    for (int x = 0; x < img.width; x++) {
      el[i++] = brightness(img.get(x,z))/255.0 * 400;
    }
  }
    terrain.setElevation(el);

  // create mesh
  mesh = (TriangleMesh)terrain.toMesh();
  // attach drawing utils
  gfx = new ToxiclibsSupport(this);
}

void draw() {  
  background(0);
  // setup lights
  directionalLight(192, 160, 128, 0, -1000, -0.5f);
  directionalLight(255, 64, 0, 0.5f, -0.1f, 0.5f);
  fill(255);
  noStroke();
  // draw mesh
  rotateX(mouseY * 0.01f);
  rotateY(mouseX * 0.01f);
  
  //change color
  
  //extrude mesh based on image
  gfx.mesh(mesh, false);
}

