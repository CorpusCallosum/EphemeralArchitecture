Pt[][] generateImagePoints(int res) {
  Pt[][] pt;
  float D;

  int imgw=img.width;
  int imgh=img.height;
  float xstep=(float)imgw/(float)res;
  float ystep=(float)imgh/(float)res;

  pt=new Pt[res][res];
  D=(float)width*0.8f;
  D=D/(float)(res-1);

  for(int i=0; i<res; i++) {
    for(int j=0; j<res; j++) {
      // generate new verex
      pt[i][j]=new Pt(
      (float)i*D,
      (float)j*D,
      0);
      
      int X=(int)((float)i*xstep);
      int Y=(int)((float)j*ystep);
      pt[i][j].z=
        (brightness(img.get(X,Y))/255.0)*Z;
    }
  }
  
  return pt;
}
