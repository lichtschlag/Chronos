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

@property (weak, nonatomic) IBOutlet CHActivityView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *mainButton;

- (IBAction) buttonPressed:(id)sender;

@end
