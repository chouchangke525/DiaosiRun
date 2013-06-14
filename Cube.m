//
//  Cube.m
//  DiaosiRun
//
//  Created by Yu Yichen on 5/28/13.
//  Copyright (c) 2013 Yu Yichen. All rights reserved.
//

#import "Cube.h"

@implementation Cube

    
-(id)init:(GLfloat)x y:(GLfloat)y z:(GLfloat)z red:(GLubyte)red green:(GLubyte)green blue:(GLubyte)blue alpha:(GLubyte)alpha
{
    
    GLfloat *cubeVertices=vertexArray=(GLfloat*)malloc(sizeof(GLfloat)*24);
    
    GLubyte *cubeColors=colorArray=(GLubyte*)malloc(sizeof(GLubyte)*32);
    GLubyte *tfan1=fanArray1=(GLubyte*)malloc(sizeof(GLubyte)*18);
    GLubyte *tfan2=fanArray2=(GLubyte*)malloc(sizeof(GLubyte)*18);

    cubeVertices[0]=-x;
    cubeVertices[1]=y;
    cubeVertices[2]=z;
    
    cubeVertices[3]=x;
    cubeVertices[4]=y;
    cubeVertices[5]=z;
    
    cubeVertices[6]=x;
    cubeVertices[7]=-y;
    cubeVertices[8]=z;
    
    cubeVertices[9]=-x;
    cubeVertices[10]=-y;
    cubeVertices[11]=z;
    
    
    cubeVertices[12]=-x;
    cubeVertices[13]=y;
    cubeVertices[14]=-z;
    
    cubeVertices[15]=x;
    cubeVertices[16]=y;
    cubeVertices[17]=-z;
    
    cubeVertices[18]=x;
    cubeVertices[19]=-y;
    cubeVertices[20]=-z;
    
    cubeVertices[21]=-x;
    cubeVertices[22]=-y;
    cubeVertices[23]=-z;
  
    
  
    cubeColors[0]=red;
    cubeColors[1]=green;
    cubeColors[2]=blue;
    cubeColors[3]=alpha;
    cubeColors[4]=red;
    cubeColors[5]=green;
    cubeColors[6]=blue;
    cubeColors[7]=alpha;
    cubeColors[8]=red;
    cubeColors[9]=green;
    cubeColors[10]=blue;
    cubeColors[11]=alpha;
    cubeColors[12]=red;
    cubeColors[13]=green;
    cubeColors[14]=blue;
    cubeColors[15]=alpha;
    cubeColors[16]=red;
    cubeColors[17]=green;
    cubeColors[18]=blue;
    cubeColors[19]=alpha;
    cubeColors[20]=red;
    cubeColors[21]=green;
    cubeColors[22]=blue;
    cubeColors[23]=alpha;
    cubeColors[24]=red;
    cubeColors[25]=green;
    cubeColors[26]=blue;
    cubeColors[27]=alpha;
    cubeColors[28]=red;
    cubeColors[29]=green;
    cubeColors[30]=blue;
    cubeColors[31]=alpha;
    
    tfan1[0]=1;
    tfan1[1]=0;
    tfan1[2]=3;
    tfan1[3]=1;
    tfan1[4]=3;
    tfan1[5]=2;
    tfan1[6]=1;
    tfan1[7]=2;
    tfan1[8]=6;
    tfan1[9]=1;
    tfan1[10]=6;
    tfan1[11]=5;
    tfan1[12]=1;
    tfan1[13]=5;
    tfan1[14]=4;
    tfan1[15]=1;
    tfan1[16]=4;
    tfan1[17]=0;
    
    
    tfan2[0]=7;
    tfan2[1]=4;
    tfan2[2]=5;
    tfan2[3]=7;
    tfan2[4]=5;
    tfan2[5]=6;
    tfan2[6]=7;
    tfan2[7]=6;
    tfan2[8]=2;
    tfan2[9]=7;
    tfan2[10]=2;
    tfan2[11]=3;
    tfan2[12]=7;
    tfan2[13]=3;
    tfan2[14]=0;
    tfan2[15]=7;
    tfan2[16]=0;
    tfan2[17]=4;


    return self;
    
}

-(bool)execute{
    
   
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);//cut the back of the image
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, vertexArray);
   
    
    
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorArray);
   
    
    
    glDrawElements(GL_TRIANGLE_FAN, 6*3, GL_UNSIGNED_BYTE, fanArray1);
    glDrawElements(GL_TRIANGLE_FAN, 6*3, GL_UNSIGNED_BYTE, fanArray2);

    return true;
}

@end
