// HamsterBoo
// 7/16/2014
import gifAnimation.*;

//MODE:
//0 -> black
//1 -> bright
//2 -> white
//b(16777216)
int mode = 1;
//0 -> columns have random levels of sorting
//1 -> columns near eachother have similar levels of sorting
int indexMode = 1;
//0 -> columns sorted by min and max brightness
//1 -> columns sorted according to its own distribution
//2 -> columns sorted according to average distribution
int brightMode = 1;

GifMaker gifExport;
PImage img;
String imgFileName = "lake";
String fileType = "jpg";

int loops = 200;

int blackValue = -10000000;
int brightnessValue = 60;
int whiteValue = -6000000;
int[] brightnesses;
int[][] fullSort;
int[] avSort;
int[] indices;

int maxBright = 150;
int minBright = 30;
int speed = 10; //half the number of frames for 1 full cycle

int row = 0;
int column = 0;

boolean saved = false;

void setup() {
  img = loadImage(imgFileName+"."+fileType);
  size(img.width, img.height);
  image(img, 0, 0);
  
  brightnesses = new int[width];
  indices = new int[width];
  for (int i=0; i<width; i++) {
    brightnesses[i] = (int) random(minBright, maxBright);
    indices[i] = (int) random(height);
  }
  gifExport = new GifMaker(this, imgFileName+"_melt_"+indexMode+"_"+brightMode+".gif");
  gifExport.setRepeat(0);
  
  fullSort = new int[width][];
  for (int i=0; i<width; i++) {
    fullSort[i] = getSortedColumn(i);
  }
  
  avSort = new int[height];
  for (int j=0; j<height; j++) {
    avSort[j] = 0;
    for (int i=0; i<width; i++) {
      avSort[j] += fullSort[i][j];
    }
    avSort[j] /= width;
  }
  println(fullSort[0]);
  println(avSort);
}


void draw() {
  println(frameCount);
  img = loadImage(imgFileName+"."+fileType);
  column = 0;
  row = 0;
  while(column < width-1) {
    switch(indexMode) {
      case 0: //use random index
        indices[column] -= (int) random(height/speed);
        if (indices[column] < 0) {
          indices[column] += height;
        }
        break;
      case 1: //use sticky index
        int distance;
        if (column == 0) {
          distance = indices[column]-indices[width-1];
        } else {
          distance = indices[column]-indices[column-1];
        }
        if (abs(distance-height) < abs(distance)) {
          distance -= height;
        } else if (abs(distance+height) < abs(distance)) {
          distance += height;
        }
        //when difference is negative go slow
        float exp_value = exp(-(float) distance/height);
        indices[column] -= (int) random(1/(1+exp_value)*height/speed);
        //distance = min(abs(distance), abs(distance-height), abs(distance+height));
        //indices[column] -= (int) random(8*sqrt(distance)/speed+2);
        if (indices[column] < 0) {
          indices[column] += height;
        }
        break;
      default:
        break;
    }
    switch(brightMode) {
      case 0: //use minbright and maxbright
        brightnesses[column] -= (int) random((maxBright-minBright)/speed);
        if (brightnesses[column] <= minBright) {
          brightnesses[column] += maxBright-minBright;
        }
        break;
      case 1: //use bightness at index
        brightnesses[column] = fullSort[column][indices[column]];
        break;
      case 2: //use average brightness at index
        brightnesses[column] = avSort[indices[column]];
        break;
      default:
        break;
    }
    
      
    img.loadPixels(); 
    sortColumn();
    column++;
    img.updatePixels();
  }
  /*
  while(row < height-1) {
    img.loadPixels(); 
    sortRow();
    row++;
    img.updatePixels();
  }
  */
  image(img,0,0);
  gifExport.setDelay(10);
  gifExport.addFrame();
  if(!saved && frameCount >= loops) {
    gifExport.finish();
    //saveFrame(imgFileName+"_"+mode+"_"+brightnessValue+".png");
    saved = true;
    println("DONE"+frameCount);
    int total = 0;
    int distance;
    for (int i=1; i< width; i++) {
      distance = indices[i]-indices[i-1];
      total += min(abs(distance), abs(distance-height), abs(distance+height));
    }
    println(total/(width-1));
    println(height);
    System.exit(0);
  }
}

void sortRow() {
  int x = 0;
  int y = row;
  int xend = 0;
  
  while(xend < width-1) {
    switch(mode) {
      case 0:
        x = getFirstNotBlackX(x, y);
        xend = getNextBlackX(x, y);
        break;
      case 1:
        x = getFirstBrightX(x, y);
        xend = getNextDarkX(x, y);
        break;
      case 2:
        x = getFirstNotWhiteX(x, y);
        xend = getNextWhiteX(x, y);
        break;
      default:
        break;
    }
    
    if(x < 0) break;
    
    int sortLength = xend-x;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + i + y * img.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      img.pixels[x + i + y * img.width] = sorted[i];      
    }
    
    x = xend+1;
  }
}


void sortColumn() {
  int x = column;
  int y = 0;
  int yend = 0;
  
  while(yend < height-1) {
    switch(mode) {
      case 0:
        y = getFirstNotBlackY(x, y);
        yend = getNextBlackY(x, y);
        break;
      case 1:
        y = getFirstBrightY(x, y);
        yend = getNextDarkY(x, y);
        break;
      case 2:
        y = getFirstNotWhiteY(x, y);
        yend = getNextWhiteY(x, y);
        break;
      default:
        break;
    }
    
    if(y < 0) break;
    
    int sortLength = yend-y;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + (y+i) * img.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      img.pixels[x + (y+i) * img.width] = sorted[i];
    }
    
    y = yend+1;
  }
}

int[] getSortedColumn(int x) {
  int[] unsorted = new int[height];
  int[] sorted = new int[height];
  for (int i=0; i<height; i++) {
    unsorted[i] = (int) brightness(img.pixels[x + i * img.width]);
  }
  sorted = sort(unsorted);
  return sorted;
}

//BLACK
int getFirstNotBlackX(int _x, int _y) {
  int x = _x;
  int y = _y;
  color c;
  while((c = img.pixels[x + y * img.width]) < blackValue) {
    x++;
    if(x >= width) return -1;
  }
  return x;
}

int getNextBlackX(int _x, int _y) {
  int x = _x+1;
  int y = _y;
  color c;
  while((c = img.pixels[x + y * img.width]) > blackValue) {
    x++;
    if(x >= width) return width-1;
  }
  return x-1;
}

//BRIGHTNESS
int getFirstBrightX(int _x, int _y) {
  int x = _x;
  int y = _y;
  color c;
  while(brightness(c = img.pixels[x + y * img.width]) < brightnessValue) {
    x++;
    if(x >= width) return -1;
  }
  return x;
}

int getNextDarkX(int _x, int _y) {
  int x = _x+1;
  int y = _y;
  color c;
  while(brightness(c = img.pixels[x + y * img.width]) > brightnessValue) {
    x++;
    if(x >= width) return width-1;
  }
  return x-1;
}

//WHITE
int getFirstNotWhiteX(int _x, int _y) {
  int x = _x;
  int y = _y;
  color c;
  while((c = img.pixels[x + y * img.width]) > whiteValue) {
    x++;
    if(x >= width) return -1;
  }
  return x;
}

int getNextWhiteX(int _x, int _y) {
  int x = _x+1;
  int y = _y;
  color c;
  while((c = img.pixels[x + y * img.width]) < whiteValue) {
    x++;
    if(x >= width) return width-1;
  }
  return x-1;
}


//BLACK
int getFirstNotBlackY(int _x, int _y) {
  int x = _x;
  int y = _y;
  color c;
  if(y < height) {
    while((c = img.pixels[x + y * img.width]) < blackValue) {
      y++;
      if(y >= height) return -1;
    }
  }
  return y;
}

int getNextBlackY(int _x, int _y) {
  int x = _x;
  int y = _y+1;
  color c;
  if(y < height) {
    while((c = img.pixels[x + y * img.width]) > blackValue) {
      y++;
      if(y >= height) return height-1;
    }
  }
  return y-1;
}

//BRIGHTNESS
int getFirstBrightY(int _x, int _y) {
  int x = _x;
  int y = _y;
  color c;
  if(y < height) {
    while(brightness(c = img.pixels[x + y * img.width]) < brightnesses[column]) {
      y++;
      if(y >= height) return -1;
    }
  }
  return y;
}

int getNextDarkY(int _x, int _y) {
  int x = _x;
  int y = _y+1;
  color c;
  if(y < height) {
    while(brightness(c = img.pixels[x + y * img.width]) > brightnesses[column]) {
      y++;
      if(y >= height) return height-1;
    }
  }
  return y-1;
}

//WHITE
int getFirstNotWhiteY(int _x, int _y) {
  int x = _x;
  int y = _y;
  color c;
  if(y < height) {
    while((c = img.pixels[x + y * img.width]) > whiteValue) {
      y++;
      if(y >= height) return -1;
    }
  }
  return y;
}

int getNextWhiteY(int _x, int _y) {
  int x = _x;
  int y = _y+1;
  color c;
  if(y < height) {
    while((c = img.pixels[x + y * img.width]) < whiteValue) {
      y++;
      if(y >= height) return height-1;
    }
  }
  return y-1;
}
