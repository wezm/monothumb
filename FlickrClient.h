//
//  FlickrClient.h
//  monothumb
//
//  Created by Wesley Moore on 22/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FlickrClient : NSObject {
	NSMutableArray *photos;
	NSXMLDocument *xml;
}

@property(retain) NSXMLDocument *xml;

- (BOOL)fetchPhotosAndReturnError:(NSError **)error;
- (NSArray *)photos;

@end
