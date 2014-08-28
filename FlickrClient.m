//
//  FlickrClient.m
//  monothumb
//
//  Created by Wesley Moore on 22/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrClient.h"
#import "FlickrPhoto.h"
#import "WMMonothumbError.h"

NSString *const WMMonothumbErrorDomain = @"net.wezm.monothumb.ErrorDomain";

@interface FlickrClient (Private)

- (NSError *)errorWithCode:(NSInteger)code localizedDescription:(NSString *)description;

@end


@implementation FlickrClient

@synthesize xml;

- (id)initWithAPIKey:(NSString *)key userId:(NSString *)user
{
    if ((self = [super init]) != nil) {
        apiKey = [key retain];
        userId = [user retain];
    }
    
    return self;
}

- (void)dealloc
{
    [apiKey release];
    [userId release];
    
    [super dealloc];
}

- (BOOL)fetchPhotosAndReturnError:(NSError **)error
{
	NSError *errors = nil;
	NSXMLElement *e;
	NSString *stat;
	NSArray *photo_nodes;

	if(xml == nil)
	{
        NSString *apiURLString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=%@&user_id=%@&per_page=20&extras=url_sq,url_z",
                                  [apiKey stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                  [userId stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
		NSURL *api_url = [NSURL URLWithString:apiURLString];
		xml = [[NSXMLDocument alloc] initWithContentsOfURL:api_url options:NSXMLNodeOptionsNone error:&errors];
	}
	
	if(xml == nil) {
		if(error != nil) {
			NSMutableDictionary *user_info = [NSMutableDictionary dictionary];
			[user_info setObject:@"Error parsing the photo XML" forKey:NSLocalizedDescriptionKey];
			if(errors != nil) {
				[user_info setObject:errors forKey:NSUnderlyingErrorKey];
			}
			NSError *err = [[NSError alloc] initWithDomain:WMMonothumbErrorDomain code:WMFlickrClientParseError userInfo:[NSDictionary dictionaryWithDictionary:user_info]];
			*error = [err autorelease];
		}
		return NO;
	}
	
	e = [xml rootElement];
	stat = [[e attributeForName:@"stat"] stringValue];
	if(stat == nil) {
		if(error != nil)
			*error = [self errorWithCode:WMFlickrClientUnexpectedXMLError localizedDescription:@"Expected stat attribute but got nil"];
		[xml release];
		return NO;
	}
	
	if ([stat compare:@"ok"] != NSOrderedSame) {
		NSString *desc = [NSString stringWithFormat:@"Stat not ok: %@", stat];
		if(error != nil)
			*error = [self errorWithCode:WMFlickrClientErrorResponse localizedDescription:desc];
        NSLog(@"%@", [xml XMLString]);
		[xml release];
		return NO;
	}
	
	photo_nodes = [xml nodesForXPath:@"//photos/photo" error:&errors];
	if(photo_nodes == nil) {
		if(error != nil)
			*error = [self errorWithCode:WMFlickrClientUnexpectedXMLError localizedDescription:@"Error getting photos elements"];
		[xml release];
		return NO;
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
	
	return YES;
}

- (NSArray *)photos
{
	return [NSArray arrayWithArray:photos];
}

- (NSError *)errorWithCode:(NSInteger)code localizedDescription:(NSString *)description
{
	NSDictionary *info = [NSDictionary dictionaryWithObject:description
													 forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:WMMonothumbErrorDomain
							   code:code
						   userInfo:info];
}


@end
