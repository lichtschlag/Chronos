//
//  CHViewController.m
//  Chronos
//
//  Created by Leonhard Lichtschlag on 26/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "CHViewController.h"

// ===============================================================================================================
@interface CHViewController ()
// ===============================================================================================================

@property (nonatomic, strong) NSURLConnection	*clientConnection;

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
	
	self.clientConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	assert(self.clientConnection != nil);
}


- (void) didFinishClientInformation
{
	// teardown
}


- (void) connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
	
    assert(theConnection == self.clientConnection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2)
	{
        NSLog(@"%s Failed to get Client Information, response is %d", __PRETTY_FUNCTION__, httpResponse.statusCode);
    }
	else
	{
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
        // the string, so we can just use -isEqual: on the result.
        contentTypeHeader = [httpResponse MIMEType];
		NSLog(@"%s Got Client Response and Type is %@", __PRETTY_FUNCTION__, httpResponse.MIMEType);
	}
}




@end
