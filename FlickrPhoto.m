//
//  Photo.m
//  monothumb
//
//  Created by Wesley Moore on 28/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhoto.h"

@interface FlickrPhoto (Private)

- (NSSize)sizeForHeightKey:(NSString *)heightKey widthKey:(NSString *)widthKey fromElement:(NSXMLElement *)e;

@end


@implementation FlickrPhoto

//- (id)init
//{
//	if((self = [super init]) != nil) {
//		data = [[NSMutableData alloc] init];
//		finished = NO;
//	}
//	
//	return self;
//}
//

@synthesize url;
@synthesize dimensions;
@synthesize title;

- (id)initWithXMLElement:(NSXMLElement *)element
{
	if((self = [super init]) != nil)
	{
		NSString *value = [[element attributeForName:@"url_sq"] stringValue];
		if(value == nil) {
			NSLog(@"Square photo URL was nil");
//			[pool drain];
			return nil;
		}

		url = [[NSURL alloc] initWithString:value];
		dimensions = [self sizeForHeightKey:@"height_sq" widthKey:@"width_sq" fromElement:element];
		title = [[element attributeForName:@"title"] stringValue];
		data = [[NSMutableData alloc] init];
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
- (NSSize)sizeForHeightKey:(NSString *)heightKey widthKey:(NSString *)widthKey fromElement:(NSXMLElement *)e
{
	NSString *height = [[e attributeForName:heightKey] stringValue];
	NSString *width = [[e attributeForName:widthKey] stringValue];
	NSSize size;
	
	if(width && height) {
		size = NSMakeSize([width floatValue], [height floatValue]);
	}
	else {
		size = NSMakeSize(-1, -1);
	}

	return size;
}
//
- (BOOL)isValid
{
	if(dimensions.height > 0 && dimensions.width > 0) {
		return YES;
	}
	
	return NO;
}
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
    [data setLength:0];
	if(file_name) [file_name release];
	file_name = [[response suggestedFilename] retain];
	NSLog(@"%@", file_name);
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
    NSLog(@"Succeeded! Received %d bytes of data, writing to %@",[data length], file_name);
	
    // release the connection, and the data object
    [connection release];
    //[receivedData release];
	//[data writeToFile:file_name atomically:NO];
	//[data release];
	
	finished = YES;
}

- (BOOL)isFinished
{
	return finished;
}

- (BOOL)loadAndReturnError:(NSError **)error
{
//FlickrPhoto *process_photo_node(NSXMLNode *node)
//{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	
//	NSRunLoop *run_loop = [NSRunLoop currentRunLoop];
//	BOOL shouldKeepRunning = YES;
//	
//	NSString *value = [[photo_elem attributeForName:@"url_sq"] stringValue];
//	if(value == nil) {
//		NSLog(@"Photo URL was nil");
//		[pool drain];
//		return nil;
//	}
//	
//	// Retrieve the image
//	FlickrPhoto *photo = [[FlickrPhoto alloc] init];
//	NSURL *photoUrl = [NSURL URLWithString:value];
//	NSURLRequest *photoRequest = [NSURLRequest requestWithURL:photoUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:photoRequest delegate:photo];
//	if(!connection) {
//		NSLog(@"Error starting UrlConnection");
//		return nil;
//	}
//	
//	// Pump the run loop because we're not a GUI app
//	// TODO: This will keep allocating date objects, perhaps should drain the pool in the loop
//	while (shouldKeepRunning && [run_loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:60.0]])
//	{
//		if([photo isFinished]) shouldKeepRunning = NO;
//	}
//	
//	// TODO: Check if photo is valid
//	
//	[pool drain];
//	return [photo autorelease];
//}
	return NO;
}

- (NSData *)data
{
	return [NSData dataWithData:data];
}
	
@end
