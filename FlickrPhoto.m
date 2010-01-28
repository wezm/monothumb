//
//  Photo.m
//  monothumb
//
//  Created by Wesley Moore on 28/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhoto.h"


@implementation FlickrPhoto

- (id)initWithDict:(NSDictionary *)attributes
{
	if((self = [super init]) != nil)
	{
		NSString *value;

		// Messages to nil are ok right....
		identifier = [[attributes objectForKey:@"id"] retain];
		owner = [[attributes objectForKey:@"owner"] retain];
		value = [attributes objectForKey:@"url_sq"];
		if (value != nil) {
			squareUrl = [[NSURL alloc] initWithString:value];
		}

		value = [attributes objectForKey:@"url_m"];
		if (value != nil) {
			mediumUrl = [[NSURL alloc] initWithString:value];
		}

		squareDimensions = [self sizeForHeightKey:@"height_sq" widthKey:@"width_sq" fromDict:attributes];
		mediumDimensions = [self sizeForHeightKey:@"height_m" widthKey:@"width_m" fromDict:attributes];
	}
	
	return self;
}

- (NSSize)sizeForHeightKey:(NSString *)heightKey widthKey:(NSString *)widthKey fromDict:(NSDictionary *)dict
{
	NSString *height;
	NSString *width;
	NSSize size;
	
	height = [dict objectForKey:heightKey];
	width = [dict objectForKey:widthKey];
	if(width && height) {
		size = NSMakeSize([width floatValue], [height floatValue]);
	}
	else {
		size = NSMakeSize(-1, -1);
	}

	return size;
}

- (BOOL)isValid
{
	return YES;
}

- (NSURL *)photoPageURL
{
	// "http://www.flickr.com/photos/" + escape(photo.owner) + "/" + photo.id
	NSString *url = [NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@", owner, identifier];
	return [NSURL URLWithString:url];
}

- (void)dealloc
{
	if(identifier != nil) [identifier release];
	if(owner != nil) [owner release];
	if(squareUrl != nil) [squareUrl release];
	if(mediumUrl != nil) [mediumUrl release];
}

@end
