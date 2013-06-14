//
//  ViewController.m
//  DiaosiRun
//
//  Created by Yu Yichen on 5/28/13.
//  Copyright (c) 2013 Yu Yichen. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import "Ball.h"
#import "Cube.h"
#import "AppDelegate.h"

@interface ViewController ()
{
    int array[60];
    int arrayCurrent[60];
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property  Ball *head;
@property  Ball *body;
@property Ball *leftArm;
@property Ball *rightArm;
@property Ball *leftLeg;
@property Ball *rightLeg;
@property Cube *cube1;
@property Cube *cube2;
@property Cube *cube3;
@property Cube *cube4;
@property GLfloat xPosition;
@property GLfloat yPosition;
@property GLfloat zPosition;
@property GLint currentBlock;
@property GLint nextBlock;
@property GLint left;
@property GLint right;
@property Boolean die;
@property Boolean leftPressed;
@property Boolean rightPressed;
@property GLint faceColor;
@property Boolean arrayExist;
@property GLint tiltLeft;
@property GLint tiltRight;
@property GLint score;
@property GLint lives;
@property GLint anger;

@end

@implementation ViewController
@synthesize context;
@synthesize effect;
@synthesize head;
@synthesize cube1;
@synthesize cube2;
@synthesize body;
@synthesize leftArm;
@synthesize rightArm;
@synthesize leftLeg;
@synthesize rightLeg;
@synthesize xPosition;
@synthesize yPosition;
@synthesize zPosition;
@synthesize currentBlock;
@synthesize nextBlock;
@synthesize cube3;
@synthesize cube4;
@synthesize left;
@synthesize right;
@synthesize die;
@synthesize leftPressed;
@synthesize rightPressed;
@synthesize faceColor;
@synthesize arrayExist;
@synthesize tiltLeft;
@synthesize tiltRight;
@synthesize motionManager;
@synthesize attitude;
@synthesize scoreLabel;
@synthesize liveLabel;
@synthesize angerLabel;
@synthesize score;
@synthesize lives;
@synthesize anger;





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
   
    //I will use the OpenGL ES1
    self.context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if (!self.context)
    {
        NSLog(@"Fail");
    }
    
    //    The context is used to keep track of all of
    //    our specific states, commands, and resources needed to actually
    //    render something on the screen.
    
    GLKView *view =(GLKView *)self.view;
    view.context=self.context;
    view.drawableDepthFormat=GLKViewDrawableDepthFormat24;//support 24-bit color
    
    //use these values to change the overall perspective of the user
    self.xPosition=0.0;
    self.yPosition=0.0;
    self.zPosition=-10.0;
    
    self.currentBlock=0;
    self.nextBlock=0;//these two determines the two blocks are straight, turning left or turning right
    
    self.left=0;
    self.right=0; //determine whether turn left/right is executed
    
    self.die=false;//whether you are dead
    
//    self.leftPressed=false;
//    self.rightPressed=false;
    
    self.faceColor=0;//a value used to change the color of the actor
    
    self.arrayExist=false;//determine if the array needs to be generated, this array is used to place the coins and bombs.
    
    self.tiltLeft=0;
    self.tiltRight=0;//determine if tilt left/right is executed
    
    self.scoreLabel.text=@"0";
    self.liveLabel.text=@"5";
    self.angerLabel.text=@"0";//init the text in the label
    
    self.paused=false;//make sure every time I restart, the game can begin
  
    
   
    
    score=0;
    lives=5;
    anger=0;//init the value in the label
    
    for (int i=0; i<60; i++)
        arrayCurrent[i]=0;//init the arrayCurrent. Every time I just generate the array for the next block, and when the actor changes the block, I pass the value from the array to arrayCurrent
    
    
    //get the tilting value of the device
    motionManager=[CMMotionManager new];
//    motionManager.deviceMotionUpdateInterval=0.01;
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(getTilt) userInfo:nil repeats:YES];
    [EAGLContext setCurrentContext:self.context];
    
    //determine how large the players can see in the game world
    [self setClipping];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*******************************************************************************
 * @method          glkView
 * @abstract        rendering the view to the user
 * @description     this method is defind in the GLKViewController, within a certain time (or you can use the method to change it), the frame of the GLKView is rendered once.
                    
 
 ******************************************************************************/
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    
    static GLfloat angle=0.0;//the movement of the arms and legs
    static GLfloat position=0.0;//determines the position of the actor on each block, when the actor comes to the next block, it will be reset
    glClearColor(1.0, 1.0, 1.0, 1.0);//this is the background
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);//each object with a depth buffer, determine if the farther object will be hidden by the nearer object
    
    if (lives<=0||anger>=300)
        die=true;
    
    if (die)
    {
        NSLog(@"You die");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"I am sorry. You die."
                                                        message:@"Please restart the game or go back to the main menu." delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
       
        
        
        [alert show];//show the player he is dead and pause the rendering of the GLKView
        self.paused=true;
        
        
        
       
    }
    else
    {
       
    anger+=1;
    self.angerLabel.text=[NSString stringWithFormat:@"%d",anger];
        
    //draw the head
    glLoadIdentity();
    
    glTranslatef(xPosition, yPosition, zPosition);
    
    glRotatef(0, 1.0, 0.0, 0.0);
    
    glTranslatef(-tiltLeft+tiltRight, 0, 0);
    
    head=[[Ball alloc]init:3 slices:3 radius:1.0 squash:1.0 red:200+55*faceColor green:200-200*faceColor blue:200-200*faceColor alpha:255];
    [head execute];
    
    //draw the body
    glLoadIdentity();
    glTranslatef(-tiltLeft+tiltRight, 0, 0);
    
    glTranslatef(xPosition, yPosition, zPosition);
    glRotatef(0, 1.0, 0.0, 0.0);
    glTranslatef(0, -2.8, 0);

    
    body=[[Ball alloc]init:3 slices:3 radius:1.0 squash:1.8 red:200+55*faceColor green:200-200*faceColor  blue:200-200*faceColor  alpha:255];
    [body execute];
        
    //draw the left leg
    glLoadIdentity();
    
    glTranslatef(xPosition, yPosition, zPosition);
    glTranslatef(-tiltLeft+tiltRight, 0, 0);
    glRotatef(0, 1.0, 0.0, 0.0);
    glTranslatef(-0.8, -5.7, 0);
    glTranslatef(0.5, 3, 0);
    glRotatef(-30*sin(angle), 1.0, 0.0, 0.0);
    glTranslatef(-0.5, -3, 0);
    glRotatef(-15, 0.0, 0.0, 1.0);

    
    leftLeg=[[Ball alloc]init:3 slices:3 radius:0.2 squash:7.5 red:200+55*faceColor green:200-200*faceColor  blue:200-200*faceColor  alpha:255];
    [leftLeg execute];
    
        
    //draw the right leg
    glLoadIdentity();
    glTranslatef(-tiltLeft+tiltRight, 0, 0);
    
    glTranslatef(xPosition, yPosition, zPosition);
    glRotatef(0, 1.0, 0.0, 0.0);
    glTranslatef(0.8, -5.7, 0);
    glTranslatef(-0.5, 3, 0);
    glRotatef(30*sin(angle), 1.0, 0.0, 0.0);
    glTranslatef(0.5, -3, 0);
    glRotatef(15, 0.0, 0.0, 1.0);

    
    rightLeg=[[Ball alloc]init:3 slices:3 radius:0.2 squash:7.5 red:200+55*faceColor green:200-200*faceColor blue:200-200*faceColor alpha:255];
    [rightLeg execute];
    
    //draw the left arm
    glLoadIdentity();
    glTranslatef(-tiltLeft+tiltRight, 0, 0);
    
    glTranslatef(xPosition, yPosition, zPosition);
    glRotatef(0, 1.0, 0.0, 0.0);
    glTranslatef(-1.3, -3.2, 0);
    glTranslatef(0.5, 3, 0);
    glRotatef(30*sin(angle), 1.0, 0.0, 0.0);
    glTranslatef(-0.5, -3, 0);
    glRotatef(-45, 0.0, 0.0, 1.0);
    
    
    leftArm=[[Ball alloc]init:3 slices:3 radius:0.2 squash:4 red:200+55*faceColor  green:200-200*faceColor blue:200-200*faceColor alpha:255];
    [leftArm execute];
    
    //draw the right arm
    glLoadIdentity();
    glTranslatef(-tiltLeft+tiltRight, 0, 0);
    
    glTranslatef(xPosition, yPosition, zPosition);
    glRotatef(0, 1.0, 0.0, 0.0);
    glTranslatef(1.3, -3.2, 0);
    glTranslatef(-0.5, 3, 0);
    glRotatef(-30*sin(angle), 1.0, 0.0, 0.0);
    glTranslatef(0.5, -3, 0);
    glRotatef(45, 0.0, 0.0, 1.0);
    
    
    rightArm=[[Ball alloc]init:3 slices:3 radius:0.2 squash:4 red:200+55*faceColor green:200-200*faceColor blue:200-200*faceColor alpha:255];
    [rightArm execute];
    
    
    
    if (position<60)//I will move the ground instead of the person, when the position equals 60, reset it to 60
    //in the code below, cube1 and cube3 draws the current block while cube2 and cube4 draws the next block
    {
    if (currentBlock==0)//the current block is straight
    {
        if (right==1)//turn right at the wrong time
        {NSLog(@"You lose points");
            score-=10;
            self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
            lives-=1;
            self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
            faceColor=1;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];
            right=0;}
        if (left==1)//turn left at the wrong time
        {NSLog(@"You lose points");
            score-=10;
            self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
            lives-=1;
            self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
            faceColor=1;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];
            left=0;}
    //draw the straight block
    glLoadIdentity();
    glTranslatef(xPosition, yPosition, zPosition);
    glRotatef(0, 1, 0, 0);
    glTranslatef(0, -8, -20+position);

    cube1=[[Cube alloc]init:4 y:1 z:30 red:0 green:255 blue:100 alpha:255];
    [cube1 execute];
        
        //draw the coins and bombs
        for (int i=0; i<60; i++){
            
            if (arrayCurrent[i]==1||arrayCurrent[i]==2)//coin on the left
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(-2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                [coin execute];
                
            }
            else if (arrayCurrent[i]==3||arrayCurrent[i]==4)//coin on the right
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                [coin execute];
            }
            else if (arrayCurrent[i]==5)//bomb on the left
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(-2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                [coin execute];
            }
            else if (arrayCurrent[i]==6)//bomb on the right
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                [coin execute];
            }
            //in other cases there is neither coins nor bombs

        }
        
        GLint position2=(GLint)(position*2+0.1);//I just just want to choose when the position is an integer
        if (position2%2==0)//at this condition, test if running into the coin or bomb
        {   
            if (tiltRight-tiltLeft==-2&&arrayCurrent[position2/2]==5)
            {NSLog(@"You hit the bomb.");
                score-=10;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                lives-=1;
                self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
                arrayCurrent[position2/2]=0;
                faceColor=1;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];}
            if (tiltRight-tiltLeft==2&&arrayCurrent[position2/2]==6)
            {NSLog(@"You hit the bomb.");
                score-=10;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                lives-=1;
                self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
                arrayCurrent[position2/2]=0;
                faceColor=1;
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];}
            if (tiltRight-tiltLeft==-2&&(arrayCurrent[position2/2]==1||arrayCurrent[position2/2]==2))
            {NSLog(@"You get the points.");
                score+=3;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                anger=0;
                self.angerLabel.text=[NSString stringWithFormat:@"%d",anger];
                arrayCurrent[position2/2]=0;
            }
            if (tiltRight-tiltLeft==2&&(arrayCurrent[position2/2]==3||arrayCurrent[position2/2]==4))
            {NSLog(@"You get the points.");
                score+=3;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                anger=0;
                self.angerLabel.text=[NSString stringWithFormat:@"%d",anger];
                arrayCurrent[position2/2]=0;
            }
        }
     
    }
    else if (currentBlock==1)//the block is left turn
    {   if (position==17&&left==1)//at this time or a little before, the player should press left,
         {NSLog(@"You pressed left at the right time!");
             left=0;}
        else if(position==17&&left==0)
            die=true;
        if (right==1)//press right at the wrong time
        {NSLog(@"You lose points");
            score-=10;
            self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
            lives-=1;
            self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
            faceColor=1;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];
            right=0;}
        if (left==1&&position>17)//press left at the wrong time
        {NSLog(@"You lose points");
            score-=10;
            self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
            lives-=1;
            self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
            faceColor=1;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];
            left=0;}
        //draw the straight part of the block
        glLoadIdentity();
        
        glTranslatef(xPosition, yPosition, zPosition);
        
            
        if (position<=17) //this if-else determines the block needs to rotate
        {
            
            glTranslatef(0, -8, -7+position);
        }
        else if(position<23)
        {
            glTranslatef(0, 0, position-20);
            glRotatef((-position+17)*15, 0, 1, 0);
            glTranslatef(0, -8, 13);
            
        }
        else
        {
            glTranslatef(0, 0, position-20);
            glRotatef(-90, 0, 1, 0);
            glTranslatef(0, -8, 13);
            
        }

        
        
        cube1=[[Cube alloc]init:4 y:1 z:17 red:0 green:255 blue:100 alpha:255];
        [cube1 execute];
        
        //draw the part of the block after the turning 
        glLoadIdentity();
        glTranslatef(xPosition, yPosition, zPosition);
        
        
        if (position<=17)
        {
            
            glTranslatef(-13, -8, -20+position);
        }
        else if(position<23)
        {
            glTranslatef(0, 0, position-20);
            glRotatef((-position+17)*15, 0, 1, 0);
            glTranslatef(-13, -8, 0);
            
        }

        else
        {
            glTranslatef(0, 0, position-20);
            glRotatef(-90, 0, 1, 0);
            glTranslatef(-13, -8, 0);
            
        }
       
        
        cube3=[[Cube alloc]init:17 y:1 z:4 red:0 green:255 blue:100 alpha:255];
            [cube3 execute];
        
        //draws the coins and bombs
        if (position>=25){//I will not draw the coins and bombs at the turning point
        for (int i=0; i<60; i++){
            
            if (arrayCurrent[i]==1||arrayCurrent[i]==2)//coin on the left
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(-2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                [coin execute];
                
            }
            else if (arrayCurrent[i]==3||arrayCurrent[i]==4)//coin on the right
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                [coin execute];
            }
            else if (arrayCurrent[i]==5)//bomb on the left
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(-2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                [coin execute];
            }
            else if (arrayCurrent[i]==6)//bomb on the right
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                [coin execute];
            }
            
        }//end of for

      }
        GLint position2=(GLint)(position*2+0.1);
        if (position2%2==0)//at this condition, test if running into the coin or bomb
        {
            if (tiltRight-tiltLeft==-2&&arrayCurrent[position2/2]==5)
            {NSLog(@"You hit the bomb.");
                score-=10;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                lives-=1;
                self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
                arrayCurrent[position2/2]=0;
                faceColor=1;
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];}
            if (tiltRight-tiltLeft==2&&arrayCurrent[position2/2]==6)
            {NSLog(@"You hit the bomb.");
                arrayCurrent[position2/2]=0;
                score-=10;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                lives-=1;
                self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
                faceColor=1;
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];}
            if (tiltRight-tiltLeft==-2&&(arrayCurrent[position2/2]==1||arrayCurrent[position2/2]==2))
            {NSLog(@"You get the points.");
                score+=3;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                anger=0;
                self.angerLabel.text=[NSString stringWithFormat:@"%d",anger];
                arrayCurrent[position2/2]=0;
            }
            if (tiltRight-tiltLeft==2&&(arrayCurrent[position2/2]==3||arrayCurrent[position2/2]==4))
            {NSLog(@"You get the points.");
                score+=3;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                anger=0;
                self.angerLabel.text=[NSString stringWithFormat:@"%d",anger];
                arrayCurrent[position2/2]=0;
            }
        }

    }
    else //if the block is the right-turn
    {   if (position==17&&right==1)
        { NSLog(@"You pressed right at the right time!");
        right=0;}
        else if(position==17&&right==0)
        die=true;
        if (right==1&&position>17)
        {NSLog(@"You lose points");
            score-=10;
            self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
            lives-=1;
            self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
            faceColor=1;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];
            right=0;}
        if (left==1)
        {NSLog(@"You lose points");
            score-=10;
            self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
            lives-=1;
            self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
            faceColor=1;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];
            left=0;}
        glLoadIdentity();
        glTranslatef(xPosition, yPosition, zPosition);
        if (position<=17)
        {
            
            glTranslatef(0, -8, -7+position);
        }
        else if(position<23)
        {
            glTranslatef(0, 0, position-20);
            glRotatef((position-17)*15, 0, 1, 0);
            glTranslatef(0, -8, 13);
            
        }
        
        else
        {
            glTranslatef(0, 0, position-20);
            glRotatef(90, 0, 1, 0);
            glTranslatef(0, -8, 13);
            
        }


      
        
        cube1=[[Cube alloc]init:4 y:1 z:17 red:0 green:255 blue:100 alpha:255];
        [cube1 execute];
        
        
        glLoadIdentity();
        glTranslatef(xPosition, yPosition, zPosition);
        if (position<=17)
        {
            
            glTranslatef(13, -8, -20+position);
        }
        else if(position<23)
        {
            glTranslatef(0, 0, position-20);
            glRotatef((position-17)*15, 0, 1, 0);
            glTranslatef(13, -8, 0);
            
        }
        else
        {
            glTranslatef(0, 0, position-20);
            glRotatef(90, 0, 1, 0);
            glTranslatef(13, -8, 0);
            
        }
        
        cube3=[[Cube alloc]init:17 y:1 z:4 red:0 green:255 blue:100 alpha:255];
        [cube3 execute];
        if (position>=25){
        for (int i=0; i<60; i++){
            
            if (arrayCurrent[i]==1||arrayCurrent[i]==2)//coin on the left
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(-2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                [coin execute];
                
            }
            else if (arrayCurrent[i]==3||arrayCurrent[i]==4)//coin on the right
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                [coin execute];
            }
            else if (arrayCurrent[i]==5)//bomb on the left
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(-2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                [coin execute];
            }
            else if (arrayCurrent[i]==6)//bomb on the right
            {
                glLoadIdentity();
                glTranslatef(xPosition, yPosition, zPosition);
                glRotatef(0, 1, 0, 0);
                glTranslatef(2, -3, position-i);
                Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                [coin execute];
            }
            
        }
      }
        GLint position2=(GLint)(position*2+0.1);
        if (position2%2==0)//at this condition, test if running into the coin or bomb
        {
            if (tiltRight-tiltLeft==-2&&arrayCurrent[position2/2]==5)
            {NSLog(@"You hit the bomb.");
                score-=10;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                lives-=1;
                self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
                arrayCurrent[position2/2]=0;
                faceColor=1;
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];}
            if (tiltRight-tiltLeft==2&&arrayCurrent[position2/2]==6)
            {NSLog(@"You hit the bomb.");
                score-=10;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                lives-=1;
                self.liveLabel.text=[NSString stringWithFormat:@"%d", lives];
                arrayCurrent[position2/2]=0;
                faceColor=1;
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeFace) userInfo:nil repeats:NO];}
            if (tiltRight-tiltLeft==-2&&(arrayCurrent[position2/2]==1||arrayCurrent[position2/2]==2))
            {NSLog(@"You get the points.");
                score+=3;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                anger=0;
                self.angerLabel.text=[NSString stringWithFormat:@"%d",anger];
              
                arrayCurrent[position2/2]=0;
            }
            if (tiltRight-tiltLeft==2&&(arrayCurrent[position2/2]==3||arrayCurrent[position2/2]==4))
            {NSLog(@"You get the points.");
                score+=3;
                self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
                anger=0;
                self.angerLabel.text=[NSString stringWithFormat:@"%d",anger];
                arrayCurrent[position2/2]=0;
            }
        }


    }
       
        
        
        //below is for the next block
     if(!((currentBlock==1||currentBlock==2)&&(position<20)))//only at this condition, I need to show the next block
     {  if (nextBlock==0)
        {
        glLoadIdentity();
        glTranslatef(xPosition, yPosition, zPosition);
        glRotatef(0, 1, 0, 0);
        glTranslatef(0, -8, -80+position);
        
        cube2=[[Cube alloc]init:4 y:1 z:30 red:0 green:255 blue:100 alpha:255];
        [cube2 execute];
            if (!arrayExist)//generate an array to determine the position of coins and bombs
            {
                
                for (int i=0;i<60;i++)
                    array[i]=rand()%10;
                arrayExist=true;
            }
            for (int i=0; i<60; i++){
                
                if (array[i]==1||array[i]==2)//coin on the left
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(-2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                    [coin execute];
                    
                }
                else if (array[i]==3||array[i]==4)//coin on the right
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                    [coin execute];
                }
                else if (array[i]==5)//bomb on the left
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(-2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                    [coin execute];
                }
                else if (array[i]==6)//bomb on the right
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                    [coin execute];
                }
                
                
            }//end of for loop
        }
        else if (nextBlock==1)
        {
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(0, -8, -67+position);
            
            cube2=[[Cube alloc]init:4 y:1 z:17 red:0 green:255 blue:100 alpha:255];
            [cube2 execute];
            
            
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(-13, -8, -80+position);
            
            cube4=[[Cube alloc]init:17 y:1 z:4 red:0 green:255 blue:100 alpha:255];
            [cube4 execute];
            //if the next block is left-turn or right-turn, I don't need to draw the coins and bombs
            if (!arrayExist)//generate an array to determine the position of coins and bombs
            {
                for (int i=0; i<25;i++)
                    array[i]=0;
                
                for (int i=25;i<60;i++)
                    array[i]=rand()%10;
                arrayExist=true;
            }
            
          
        }
        else
        {
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(0, -8, -67+position);
            
            cube2=[[Cube alloc]init:4 y:1 z:17 red:0 green:255 blue:100 alpha:255];
            [cube2 execute];
            
            
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(13, -8, -80+position);
            
            cube4=[[Cube alloc]init:17 y:1 z:4 red:0 green:255 blue:100 alpha:255];
            [cube4 execute];
            
            if (!arrayExist)//generate an array to determine the position of coins and bombs
            {
                for (int i=0; i<25;i++)
                    array[i]=0;
                
                for (int i=25;i<60;i++)
                    array[i]=rand()%10;
                arrayExist=true;
            }
            
          
            
        }
     }

    position+=0.5;
    }
    else// most code in this block just to make sure the next block will not disappear temperarily when the position equals 60
    {
       
        if(!((currentBlock==1||currentBlock==2)&&(position<20)))//only at this condition, I will show the next block
        {  if (nextBlock==0)
        {
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(0, -8, -80+position);
            
            cube2=[[Cube alloc]init:4 y:1 z:30 red:0 green:255 blue:100 alpha:255];
            [cube2 execute];
            if (!arrayExist)//generate an array to determine the position of coins and bombs
            {
                
                for (int i=0;i<60;i++)
                    array[i]=rand()%10;
                arrayExist=true;
            }
            for (int i=0; i<60; i++){
                
                if (array[i]==1||array[i]==2)//coin on the left
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(-2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                    [coin execute];
                    
                }
                else if (array[i]==3||array[i]==4)//coin on the right
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:255 green:255 blue:0 alpha:255];
                    [coin execute];
                }
                else if (array[i]==5)//bomb on the left
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(-2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                    [coin execute];
                }
                else if (array[i]==6)//bomb on the right
                {
                    glLoadIdentity();
                    glTranslatef(xPosition, yPosition, zPosition);
                    glRotatef(0, 1, 0, 0);
                    glTranslatef(2, -3, -60+position-i);
                    Ball *coin=[[Ball alloc]init:3 slices:3 radius:0.5 squash:1.2 red:0 green:0 blue:0 alpha:255];
                    [coin execute];
                }
                
                
            }//end of for loop
        }
        else if (nextBlock==1)
        {
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(0, -8, -67+position);
            
            cube2=[[Cube alloc]init:4 y:1 z:17 red:0 green:255 blue:100 alpha:255];
            [cube2 execute];
            
            
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(-13, -8, -80+position);
            
            cube4=[[Cube alloc]init:17 y:1 z:4 red:0 green:255 blue:100 alpha:255];
            [cube4 execute];
            
            if (!arrayExist)//generate an array to determine the position of coins and bombs
            {
                for (int i=0; i<25;i++)
                    array[i]=0;
                
                for (int i=25;i<60;i++)
                    array[i]=rand()%10;
                arrayExist=true;
            }
            
            

        }
        else
        {
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(0, -8, -67+position);
            
            cube2=[[Cube alloc]init:4 y:1 z:17 red:0 green:255 blue:100 alpha:255];
            [cube2 execute];
            
            
            glLoadIdentity();
            glTranslatef(xPosition, yPosition, zPosition);
            glRotatef(0, 1, 0, 0);
            glTranslatef(13, -8, -80+position);
            
            cube4=[[Cube alloc]init:17 y:1 z:4 red:0 green:255 blue:100 alpha:255];
            [cube4 execute];
            
            if (!arrayExist)//generate an array to determine the position of coins and bombs
            {
                for (int i=0; i<25;i++)
                    array[i]=0;
                
                for (int i=25;i<60;i++)
                    array[i]=rand()%10;
                arrayExist=true;
            }
            
           
            
        }
        }

        //make the nextBlock to by current, randomly choose the next block  and reset the position
        
        currentBlock=nextBlock;
        for(int i=0; i<60; i++)
        {
            arrayCurrent[i]=array[i];
        }
        nextBlock=rand()%3;
        position=0;//this is the reset
        arrayExist=false;
        score+=1;
        self.scoreLabel.text=[NSString stringWithFormat:@"%d", score];
        NSLog(@"You come into the next block");

    }
    angle+=0.5;
    }
    
}
/*******************************************************************************
 * @method          setClipping
 * @abstract        determines the world that the player can see
 * @description     the construct frustum determines the world that the player can see. i.e. specifying the projection view
 
 
 ******************************************************************************/

-(void)setClipping
{
    float aspectRatio;
    const float zNear=0.1;
    const float zFar=1000;
    const float fieldOfView=60.0;
    GLfloat size;
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    aspectRatio=(float)frame.size.width/(float)frame.size.height;
    
    glMatrixMode(GL_PROJECTION);//going to change the projection view
    
    glLoadIdentity();
    
    size=zNear*tanf(GLKMathDegreesToRadians(fieldOfView)/2.0);
    
    glFrustumf(-size, size, -size/aspectRatio, size/aspectRatio, zNear, zFar);
    glViewport(0, 0, frame.size.width, frame.size.height);
    
    glMatrixMode(GL_MODELVIEW);//set it back to the model view
}



/*******************************************************************************
 * @method          changeValueLeft
 * @abstract        change back the left value to zero
 * @description     change back the left value to zero
 ******************************************************************************/
-(void)changeValueLeft
{
    left=0;
    NSLog(@"Now the left value is Zero");
}

/*******************************************************************************
 * @method          changeValueRight
 * @abstract        change back the right value to zero
 * @description     change back the right value to zero
 ******************************************************************************/
-(void)changeValueRight
{
    right=0;
    NSLog(@"Now the right value is Zero");
}
/*******************************************************************************
 * @method          changeFace
 * @abstract        change back the face value to zero
 * @description     change back the face value to zero
 ******************************************************************************/
-(void)changeFace
{
    faceColor=0;
    NSLog(@"FaceColor is now Zero");
}
/*******************************************************************************
 * @method          getTilt
 * @abstract        changes the tiltLeft and tiltRight value
 * @description     changes the tiltLeft and tiltRight value
 ******************************************************************************/
-(void)getTilt
{   CMDeviceMotion *dm = motionManager.deviceMotion;
    attitude = dm.attitude;
    [motionManager startDeviceMotionUpdates];
//    NSLog(@"%f",attitude.roll); //This shows the value of the tilting, I comment it out because it is too annoying.
    if (attitude.roll<-0.5)
    {tiltLeft=2;
//        NSLog(@"Now the tilting is left");//I comment it out because it is too annoying.
    }
    if (attitude.roll>0.5)
    {  tiltRight=2;
//        NSLog(@"Now the tilting is right");//I comment it out because it is too annoying.
    }
    if (attitude.roll<=0.5&&attitude.roll>=-0.5)
    {tiltLeft=0;
        tiltRight=0;
//     NSLog(@"Now there is no tilting");//I comment it out because it is too annoying.
    }
   
}
/*******************************************************************************
 * @method          restart
 * @abstract        restart the game
 * @description     restart the game
 ******************************************************************************/
- (IBAction)restart:(UIButton *)sender {
    NSLog(@"The game is restarted");
    [self viewDidLoad];

}
/*******************************************************************************
 * @method          pause
 * @abstract        pause or resume the game
 * @description     pause or resume the game
 ******************************************************************************/
- (IBAction)pause:(UIButton *)sender {
    if (self.paused==false)
    {self.paused=true;
        NSLog(@"The game is paused");}
    else
    {self.paused=false;
        NSLog(@"The game is resumed");}
        
}
/*******************************************************************************
 * @method          swipe
 * @abstract        make the actor the turn right
 * @description     make the actor the turn right
 ******************************************************************************/
- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
   
        NSLog(@"You swiped right.");
    right=1;
    NSLog(@"The right value is One now");
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeValueRight) userInfo:nil repeats:NO];
}
/*******************************************************************************
 * @method          swipeLeft
 * @abstract        make the actor the turn left
 * @description     make the actor the turn left
 ******************************************************************************/
- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
     NSLog(@"You swiped left.");
    left=1;
    NSLog(@"The left value is One now");
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeValueLeft) userInfo:nil repeats:NO];
}



@end
