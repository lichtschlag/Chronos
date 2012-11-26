//
//  CHViewController.m
//  Chronos
//
//  Created by Leonhard Lichtschlag on 26/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "CHViewController.h"
#import "CHJSONLoader.h"

// ===============================================================================================================
@interface CHViewController ()
// ===============================================================================================================

@property (strong) 	CHJSONLoader *clientLoader;

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
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated
{
	[self startLoadingClientInformation];
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Loading Author Information
// ---------------------------------------------------------------------------------------------------------------

- (void) startLoadingAuthors
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
			 [weakSelf startLoadingAuthors];
		 }
		 
		 weakSelf.clientLoader = nil;
	 }];
}



- (void) didLoadAuthors
{
	// display data on screen
}


- (void) didFinishLoadingAuthors
{
	// teardown
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Loading Client Information
// ---------------------------------------------------------------------------------------------------------------

- (void) startLoadingClientInformation
{
	// start the download

	// both methods work
	//	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[kCHZeitServerClient stringByAppendingFormat:@"?api_key=%@", kCHZeitLeonhardAPIKey]]];
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
			[weakSelf startLoadingAuthors];
		}
		
		weakSelf.clientLoader = nil;
	}];
}


@end
