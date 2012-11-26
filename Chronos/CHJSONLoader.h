//
//  CHJSONLoader.h
//  Chronos
//
//  Created by Leonhard Lichtschlag on 26/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHJSONLoader : NSObject

- (BOOL) startLoadingFromURL:(NSURLRequest *)aDestination completion:(void (^)(NSString *, NSDictionary *))aCompletionBlock;
- (void) stop;
- (BOOL) isLoading;

@end
