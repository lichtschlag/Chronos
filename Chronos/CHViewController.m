//
//  CHViewController.m
//  Chronos
//
//  Created by Leonhard Lichtschlag on 26/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "CHViewController.h"
#import "CHJSONLoader.h"
#import "CHActivityView.h"
#import <QuartzCore/QuartzCore.h>

// ===============================================================================================================
@interface CHViewController ()
// ===============================================================================================================

@property (strong) 	CHJSONLoader		*clientLoader;
@property (strong) 	NSOperationQueue	*backgroundQueue;
@property (strong)	NSTimer				*drawingTimer;
@property (strong)	NSMutableDictionary	*authorData;

@end


NSString *const kCHZeitLeonhardAPIKey	= @"92722b2f5dd54538caa573bb689ce69300e12336c7b6c023ae10";
NSString *const kCHZeitServerMain		= @"http://api.zeit.de";
NSString *const kCHZeitServerAuthors	= @"http://api.zeit.de/author";
NSString *const kCHZeitServerClient		= @"http://api.zeit.de/client";


// ===============================================================================================================
@implementation CHViewController
// ===============================================================================================================

// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Class Life Cycle
// ---------------------------------------------------------------------------------------------------------------

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	// set default values for properties
	self.backgroundQueue = [[NSOperationQueue alloc] init];
	[self.backgroundQueue setName:@"de.rwth.hci.iPhoneClass.chronos.backgroundQueue"];
	
	self.authorData = [NSMutableDictionary dictionary];
}


- (void) viewWillAppear:(BOOL)animated
{
	self.drawingTimer = [NSTimer scheduledTimerWithTimeInterval:0.017		// 60fps
														 target:self
													   selector:@selector(timerFired:)
													   userInfo:nil
														repeats:YES];
	[self configureButtons];
}


- (void) viewDidDisappear:(BOOL)animated
{
	[self.drawingTimer invalidate];
	self.drawingTimer = nil;
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Drawing
// ---------------------------------------------------------------------------------------------------------------

- (void) timerFired:(NSTimer *)theTimer
{
	[self.activityView setNeedsDisplay];
}


- (void) configureButtons
{
	UIImage *buttonImage;

	// creating an im memory image as a template for the buttons
	CGFloat radius = 20.0f;
	CGFloat width = radius * 2+15;
	UIColor *foregroundColor = [UIColor whiteColor];

	buttonImage = [self resizableImageWithForegroundColor:foregroundColor
												withWidth:width
												   radius:radius
												 forState:UIControlStateNormal];
	for (UIButton *aButton in self.buttons)
	{
		[aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	}
	
	buttonImage = [self resizableImageWithForegroundColor:foregroundColor
												withWidth:width
												   radius:radius
												 forState:UIControlStateHighlighted];
	for (UIButton *aButton in self.buttons)
	{
		[aButton setBackgroundImage:buttonImage forState:UIControlStateHighlighted];
	}
}


- (UIImage *) resizableImageWithForegroundColor:(UIColor *)foregroundColor withWidth:(CGFloat)width radius:(CGFloat)radius forState:(UIControlState)buttonState
{
	// set up drawing context
	UIGraphicsBeginImageContext(CGSizeMake(width, width));
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);

	// drawing state image
	[[UIColor clearColor] set];
	CGContextFillRect(context, CGRectMake(0, 0, width, width));
	
	[foregroundColor set];
	CGContextSetShadowWithColor(context, CGSizeMake(0,0), 3.0, foregroundColor.CGColor);
	
	CGPathRef roundedRectPath = [self newPathForRoundedRect:CGRectInset(CGRectMake(0, 0, width, width),5,5) radius:radius];
	CGContextAddPath(context, roundedRectPath);
	
	if (buttonState == UIControlStateNormal)
		CGContextStrokePath(context);
	else
		CGContextFillPath(context);
	
	// take down drawing context
	UIGraphicsPopContext();
	UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [tempImage resizableImageWithCapInsets:UIEdgeInsetsMake(radius +6, radius +6, radius +6, radius +6)];
}


- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	// helper function for the button images
	CGMutablePathRef retPath = CGPathCreateMutable();
	
	CGRect innerRect = CGRectInset(rect, radius, radius);
	
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
	
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
	
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
	
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
	
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
	
	CGPathCloseSubpath(retPath);
	
	return retPath;
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Interaction
// ---------------------------------------------------------------------------------------------------------------

- (IBAction) badButtonPressed:(id)sender
{
	[self loadAuthorInformationSynchronously];
}


- (IBAction) goodButtonPressed:(id)sender
{
	[self loadAuthorInformationAsynchronously];
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Loading Author Information
// ---------------------------------------------------------------------------------------------------------------

- (void) loadAuthorInformationSynchronously
{
	// clear old data (this way we get an animation)
	[self.collectionView performBatchUpdates:^
	 {
		 for (int i = 0; i < [self.authorData count]; i++)
		 {
			 [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:i
																				inSection:0]]];
		 }
		 self.authorData = [NSMutableDictionary dictionary];
	 } completion:nil];
	
	// formulate the request
	NSString *requestString = [kCHZeitServerAuthors stringByAppendingFormat:@"?q=*&limit=3&fields=uri,value"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
	[request setValue:kCHZeitLeonhardAPIKey forHTTPHeaderField:@"X-Authorization"];
	assert(request != nil);

	// send the request over the network
	NSError *networkError;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&networkError];
	
	// use the resulting data
	if (data)
	{
		NSError* parsingError;
		NSDictionary* parsedDict = [NSJSONSerialization JSONObjectWithData:data
																   options:kNilOptions
																	 error:&parsingError];
		
		if (!parsingError)
		{
			self.authorData = [NSMutableDictionary dictionaryWithDictionary:parsedDict];
			[self didUpdateAuthorInformation];
		}
		else
		{
			NSLog(@"%s Could not interpret JSON data. The error returned was: %@", __PRETTY_FUNCTION__, [parsingError localizedDescription]);
		}
	}
	else
		NSLog(@"%s No data arrived. The error returned was: %@", __PRETTY_FUNCTION__, [networkError localizedDescription]);
}


- (void) loadAuthorInformationAsynchronously
{
	// clear old data (this way we get an animation)
	[self.collectionView performBatchUpdates:^
	{
		for (int i = 0; i < [self.authorData count]; i++)
		{
			[self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:i
																			   inSection:0]]];
		}
		self.authorData = [NSMutableDictionary dictionary];
	} completion:nil];
	
	// start the download
	NSString *requestString = [kCHZeitServerAuthors stringByAppendingFormat:@"?q=*&limit=3&fields=uri,value"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
	[request setValue:kCHZeitLeonhardAPIKey forHTTPHeaderField:@"X-Authorization"];
	assert(request != nil);
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:self.backgroundQueue
						   completionHandler:^(NSURLResponse *resp, NSData *data, NSError *networkError)
	 {
		 [[NSOperationQueue mainQueue] addOperationWithBlock:^
		 {
			 NSError* parsingError;
			 if (data)
			 {
				 NSDictionary* parsedDict = [NSJSONSerialization JSONObjectWithData:data
																			options:kNilOptions
																			  error:&parsingError];
				 if (!parsingError)
				 {
					 self.authorData = [NSMutableDictionary dictionaryWithDictionary:parsedDict];
					 [self didUpdateAuthorInformation];
				 }
				 else
				 {
					 NSLog(@"%s Could not interpret JSON data. The error returned was: %@", __PRETTY_FUNCTION__, [parsingError localizedDescription]);
				 }
			 }
			 else
				 NSLog(@"%s No data arrived. The error returned was: %@", __PRETTY_FUNCTION__, [networkError localizedDescription]);
		 }];
	}];
}


- (void) didUpdateAuthorInformation
{
	// display data on screen
	[self.collectionView performBatchUpdates:^
	 {
		 for (int i = 0; i < [self.authorData count]; i++)
		 {
			 [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:i
																				inSection:0]]];
		 }
	 } completion:nil];
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Loading Client Information
// ---------------------------------------------------------------------------------------------------------------

- (void) startLoadingClientInformation
{
	// start the download
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kCHZeitServerClient]];
	[request setValue:kCHZeitLeonhardAPIKey forHTTPHeaderField:@"X-Authorization"];
	
	assert(request != nil);
	
	self.clientLoader = [[CHJSONLoader alloc] init];
	__weak CHViewController *weakSelf = self;
	[self.clientLoader startLoadingFromURL:request completion:^(NSString *information, NSDictionary *response)
	{
		// do something once finished
		if (information)
		{
			NSLog(@"Failed to get client Information. %@", information);
		}
		else
		{
			NSInteger quota = [response[@"quota"] intValue];
			NSLog(@"Remaining quota is %d.", quota);
		}
		
		weakSelf.clientLoader = nil;
	}];
}



// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Data source for the collection view
// ---------------------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}


- (NSInteger) collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	return [self.authorData count];
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"authorCell" forIndexPath:indexPath];
	
    // Configure the cell as a blurry white box
	CALayer *innerLayer = [CALayer new];
	innerLayer.frame = CGRectInset(cell.bounds, 2, 2);
	innerLayer.backgroundColor = [UIColor whiteColor].CGColor;
	innerLayer.shadowRadius = 2;
	innerLayer.shadowOffset = CGSizeMake(0, 0);
	innerLayer.shadowOpacity = 1.0;
	innerLayer.shadowColor = [UIColor whiteColor].CGColor;
	
	[cell.contentView.layer addSublayer:innerLayer];
	
    return cell;
}


@end

