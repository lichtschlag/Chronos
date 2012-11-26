//
//  CHJSONLoader.m
//  Chronos
//
//  Created by Leonhard Lichtschlag on 26/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "CHJSONLoader.h"

// ===============================================================================================================
@interface CHJSONLoader ()
// ===============================================================================================================

@property (nonatomic, strong) NSURLConnection	*clientConnection;
@property (nonatomic, strong) NSMutableData		*receivedData;
@property (nonatomic, copy) void (^completionBlock)(NSString *, NSDictionary *);

@end


// ===============================================================================================================
@implementation CHJSONLoader
// ===============================================================================================================

- (BOOL) startLoadingFromURL:(NSURLRequest *)aDestination completion:(void (^)(NSString *, NSDictionary *))aCompletionBlock
{
	assert(aDestination != nil);
	
	self.clientConnection	= [NSURLConnection connectionWithRequest:aDestination delegate:self];
	if (!self.clientConnection)
	{
		return NO;
	}
	
	self.completionBlock	= aCompletionBlock;
	self.receivedData		= [NSMutableData data];
	
	return YES;
}


- (void) stop
{
	[self stoppedWithReason:@"Connection Aborted"];
}


- (BOOL) isLoading
{
	return (self.clientConnection != nil);
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Delegate Methods
// ---------------------------------------------------------------------------------------------------------------

- (void) connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx and that the Content-Type is acceptable.  If these checks
// fail, we give up on the transfer.
{
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
	
    assert(theConnection == self.clientConnection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2)
	{
		self.completionBlock([NSString stringWithFormat:@"HTTP error %d", httpResponse.statusCode], nil);
    }
	else
	{
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
        // the string, so we can just use -isEqual: on the result.
        contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil)
		{
			[self stoppedWithReason:@"Unexpected HTTP Response"];
        }
		else if (![contentTypeHeader isEqual:@"application/json"])
		{
			[self stoppedWithReason:[NSString stringWithFormat:@"Unsupported Content-Type: %@", contentTypeHeader]];
        }
		
		// everything is OK
    }
	
	self.receivedData = [NSMutableData data];
}


- (void) connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)newData
// A delegate method called by the NSURLConnection as data arrives.  We just
// write the data to the file.
{
	if (!self.receivedData)
		self.receivedData = [NSMutableData data];
	[self.receivedData appendData:newData];
}


- (void) connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
    assert(theConnection == self.clientConnection);
	[self stoppedWithReason:@"Connection Failed"];
}


- (void) connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    assert(theConnection == self.clientConnection);
	[self stoppedWithReason:nil];
}


- (void) stoppedWithReason:(NSString *)reason
{
	[self.clientConnection cancel];
	self.clientConnection = nil;
	
	NSError* error;
    NSDictionary* parsedDict = [NSJSONSerialization JSONObjectWithData:self.receivedData
															   options:kNilOptions
																 error:&error];
	if (!error)
	{
		self.completionBlock(reason, parsedDict);
	}
	else
	{
		self.completionBlock(@"Failed to interpret server response", nil);
	}
	
	self.completionBlock	= nil;
	self.receivedData		= nil;
}


@end


