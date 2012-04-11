//
//  AVCamTouchController.m
//  LucasKanadeV1
//
//  Created by nikolay on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AVCamTouchController.h"

#define MAX_POINT_NUMBER 2

@implementation AVCamTouchController

- (id)initWithFrame:(CGRect)frame
{
    pointnumber=0;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma Touches to get a point

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if([touches count]==1){
        UITouch *touch = [touches anyObject];
        CGPoint tapPoint=[touch locationInView:self];
        NSLog(@"x:%f y:%f",tapPoint.x,tapPoint.y);
        switch (pointnumber) {
            case 0:p1x=tapPoint.y/self.frame.size.height*320;
                   p1y=(1-tapPoint.x/self.frame.size.width)*210;
                   pointnumber++;
                   break;
            case 1:p2x=tapPoint.y/self.frame.size.height*320;
                   p2y=(1-tapPoint.x/self.frame.size.width)*210;
                   pointnumber++;
                   break;
//          case 2:p3x=tapPoint.y/self.frame.size.height*320;
//                 p3y=(1-tapPoint.x/self.frame.size.width)*200;
//                 pointnumber++;
//                 break;
//          case 3:p4x=tapPoint.y/self.frame.size.height*320;
//                 p4y=(1-tapPoint.x/self.frame.size.width)*200;
//                 pointnumber++;
//                 break;                        
            default:
                break;
        }
        if(pointnumber==MAX_POINT_NUMBER)
            pointnumber=0;
        need_to_init = 1;
    }
}

@end
