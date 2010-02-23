//
//  FlickrClient.m
//  monothumb
//
//  Created by Wesley Moore on 22/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrClient.h"
#import "FlickrPhoto.h"

@implementation FlickrClient

@synthesize xml;

- (void)fetchPhotosAndReturnError:(NSError **)error
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSError *errors;
	NSXMLElement *e;
	NSString *stat;
	NSArray *photo_nodes;

	if(xml == nil)
	{
		NSURL *api_url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=aa003631cc50bd47f27f242d30bcd22f&user_id=40215689%40N00&per_page=20&extras=url_sq,url_m"];
		xml = [[NSXMLDocument alloc] initWithContentsOfURL:api_url options:NSXMLNodeOptionsNone error:&errors];
	}
	
	if(xml == nil) {
		NSLog(@"Error parsing the photo XML");
		[pool drain];
		return 1;
	}
	
	e = [xml rootElement];
	stat = [[e attributeForName:@"stat"] stringValue];
	if(stat == nil) {
		NSLog(@"Expected stat attribute but got nil");
		[xml release];
		[pool drain];
		return 1;
	}
	
	if ([stat compare:@"ok"] != NSOrderedSame) {
		NSLog(@"Stat not ok: %@", stat);
		[xml release];
		[pool drain];
		return 1;
	}
	
	photo_nodes = [xml nodesForXPath:@"//photos/photo" error:&errors];
	if(errors != nil) {
		NSLog(@"Error getting photos");
		[xml release];
		[pool drain];
		return 1;
	}
	
	photos = [[NSMutableArray alloc] initWithCapacity:[photo_nodes count]];
	[photo_nodes enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSXMLNode *node = (NSXMLNode *)obj;
		if ([node kind] != NSXMLElementKind) {
			NSLog(@"Expecting XML element, got something else");
			return;
		}
		NSXMLElement *photo_elem = (NSXMLElement *)node;
		
		FlickrPhoto *photo = [[FlickrPhoto alloc] initWithXMLElement:photo_elem]; //process_photo_node(node);
		if(photo != nil)
		{
			[photos addObject:photo];
			[photo release];
		}
	}];
	
	[pool drain];
	return 0;
}

- (NSArray *)photos
{
	return [NSArray arrayWithArray:photos];
}


@end
