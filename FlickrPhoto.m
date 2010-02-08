//
//  Photo.m
//  monothumb
//
//  Created by Wesley Moore on 28/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhoto.h"


@implementation FlickrPhoto

- (id)init
{
	if((self = [super init]) != nil) {
		data = [[NSMutableData alloc] init];
		finished = NO;
	}
	
	return self;
}

//- (id)initWithDict:(NSDictionary *)attributes
//{
//	if((self = [super init]) != nil)
//	{
//		NSString *value;
//
//		// Messages to nil are ok right....
//		identifier = [[attributes objectForKey:@"id"] retain];
//		owner = [[attributes objectForKey:@"owner"] retain];
//		value = [attributes objectForKey:@"url_sq"];
//		if (value != nil) {
//			squareUrl = [[NSURL alloc] initWithString:value];
//		}
//
//		value = [attributes objectForKey:@"url_m"];
//		if (value != nil) {
//			mediumUrl = [[NSURL alloc] initWithString:value];
//		}
//
//		squareDimensions = [self sizeForHeightKey:@"height_sq" widthKey:@"width_sq" fromDict:attributes];
//		mediumDimensions = [self sizeForHeightKey:@"height_m" widthKey:@"width_m" fromDict:attributes];
//	}
//	
//	return self;
//}
//
//- (NSSize)sizeForHeightKey:(NSString *)heightKey widthKey:(NSString *)widthKey fromDict:(NSDictionary *)dict
//{
//	NSString *height;
//	NSString *width;
//	NSSize size;
//	
//	height = [dict objectForKey:heightKey];
//	width = [dict objectForKey:widthKey];
//	if(width && height) {
//		size = NSMakeSize([width floatValue], [height floatValue]);
//	}
//	else {
//		size = NSMakeSize(-1, -1);
//	}
//
//	return size;
//}
//
//- (BOOL)isValid
//{
//	return YES;
//}
//
//- (NSURL *)photoPageURL
//{
//	// "http://www.flickr.com/photos/" + escape(photo.owner) + "/" + photo.id
//	NSString *url = [NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@", owner, identifier];
//	return [NSURL URLWithString:url];
//}
//
//- (void)dealloc
//{
//	if(identifier != nil) [identifier release];
//	if(owner != nil) [owner release];
//	if(squareUrl != nil) [squareUrl release];
//	if(mediumUrl != nil) [mediumUrl release];
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	NSLog(@"%@", response);
    [data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)new_data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [data appendData:new_data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [data release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	finished = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[data length]);
	
    // release the connection, and the data object
    [connection release];
    //[receivedData release];
	finished = YES;
}

- (BOOL)isFinished
{
	return finished;
}

@end
