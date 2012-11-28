//
//  CHActivityView.m
//  Chronos
//
//  Created by Leonhard Lichtschlag on 28/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "CHActivityView.h"


// ===============================================================================================================
@implementation CHActivityView
// ===============================================================================================================

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code
		self.opaque = NO;
    }
    return self;
}


- (void) drawRect:(CGRect)rect
{
	// rotate every 2 seconds
	NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
	double	phase = fmod(time, 2.0f);
	BOOL whitePhase = (fmod(time, 4.0f) > 2.0f);
	double	angle = phase * M_PI;
	
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *phaseColor;
	if (whitePhase)
	{
		phaseColor = [UIColor whiteColor];
	}
	else
	{
		phaseColor = [UIColor blackColor];
	}
	[phaseColor setFill];
	CGContextSetShadowWithColor(context, CGSizeMake(0,0), 3.0, phaseColor.CGColor);
	
	CGPoint midPoint =  CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
	CGContextMoveToPoint(context, midPoint.x, midPoint.y);
	CGContextAddArc(context, midPoint.x, midPoint.y,
					self.bounds.size.width *0.45,
					0 - M_PI / 2.0,
					angle - M_PI / 2.0,
					1);
	CGContextAddLineToPoint(context, midPoint.x, midPoint.y);
	CGContextFillPath(context);
}


@end
