//
//  Photo.m
//  monothumb
//
//  Created by Wesley Moore on 28/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhoto.h"
#import	"WMMonothumbError.h"

@interface FlickrPhoto (Private)

- (NSSize)sizeForHeightKey:(NSString *)heightKey widthKey:(NSString *)widthKey fromElement:(NSXMLElement *)e;
- (NSError *)errorWithCode:(NSInteger)code localizedDescription:(NSString *)description;

@end


@implementation FlickrPhoto

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
			[self release];
			return nil;
		}

		url = [[NSURL alloc] initWithString:value];
		dimensions = [self sizeForHeightKey:@"height_sq" widthKey:@"width_sq" fromElement:element];
		title = [[element attributeForName:@"title"] stringValue];
		data = [[NSMutableData alloc] init];
	}
	
	return self;
}

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
	if(url != nil && dimensions.height > 0 && dimensions.width > 0) {
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
	//NSLog(@"%@", file_name);
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
    // NSLog(@"Succeeded! Received %lu bytes of data, writing to %@", (unsigned long)[data length], file_name);
	
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
	NSRunLoop *run_loop = [NSRunLoop currentRunLoop];
	BOOL shouldKeepRunning = YES;
	
	// Retrieve the image
	NSURLRequest *photoRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:photoRequest delegate:self startImmediately:NO];
	if(!connection) {
		if(error != nil)
			*error = [self errorWithCode:WMFlickrClientUnexpectedXMLError localizedDescription:@"Error starting URLConnection"];
		return NO;
	}
	
	[connection scheduleInRunLoop:run_loop forMode:NSDefaultRunLoopMode];
    [connection start];
	
	// Pump the run loop because we're not a GUI app
	// TODO: This will keep allocating date objects, perhaps should drain the pool in the loop
	while (shouldKeepRunning && [run_loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:60.0]])
	{
		if([self isFinished]) shouldKeepRunning = NO;
	}
	
	// TODO: Check if photo is valid
	return [self isValid];
}

- (NSData *)data
{
	return [NSData dataWithData:data];
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
