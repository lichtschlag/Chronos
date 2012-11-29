//
//  CHViewController.h
//  Chronos
//
//  Created by Leonhard Lichtschlag on 26/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHActivityView;

// ===============================================================================================================
@interface CHViewController : UIViewController
// ===============================================================================================================

@property (weak, nonatomic)		IBOutlet						CHActivityView	*activityView;
@property (strong, nonatomic)	IBOutletCollection(UIButton)	NSArray			*buttons;

- (IBAction) goodButtonPressed:(id)sender;
- (IBAction) badButtonPressed:(id)sender;

@end
