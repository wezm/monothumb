#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

FlickrPhoto *process_photo_node(NSXMLNode *node);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSError *errors;
	NSURL *api_url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=aa003631cc50bd47f27f242d30bcd22f&user_id=40215689%40N00&per_page=20&extras=url_sq,url_m"];
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithContentsOfURL:api_url options:NSXMLNodeOptionsNone error:&errors];
	NSXMLElement *e;
	NSString *stat;
	NSArray *photo_nodes;
	NSMutableArray *photos;
	
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
	
	//NSLog(@"%@", photo_nodes);
	[photo_nodes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSXMLNode *node = (NSXMLNode *)obj;
		FlickrPhoto *photo = process_photo_node(node);
		if(photo != nil) [photos addObject:photo];
	}];

	// Create the destination graphics context
	CGColorSpaceRef rgb = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	size_t pixel_width = 75 * 20;
	size_t pixel_height = 75 * 2;
	size_t bytes_per_row = pixel_width * 4;
	CGContextRef bitmap = CGBitmapContextCreate(NULL, pixel_width, pixel_height, 8, bytes_per_row, rgb, kCGImageAlphaNoneSkipLast);
	if(bitmap == NULL) {
		NSLog(@"Error creating output bitmap context");
		[xml release];
		[pool drain];
		return 1;
	}
	
	[photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		FlickrPhoto *photo = (FlickrPhoto *)obj;
//		CGSize thumb_size = {75, 75};
//		CGLayerRef thumb_layer = CGLayerCreateWithContext(bitmap, thumb_size, NULL);
//		CGContextRef layer_context = CGLayerGetContext(thumb_layer);

		NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:[photo data]];
//		NSRect thumb_rect = NSMakeRect(0, 0, 75, 75);
//		CGImageRef *image = [thumb CGImageForProposedRect:&thumb_rect context:layer_context hints:nil];
//		if(image == NULL) {
//			NSLog(@"Error getting CGImage from NSImage");
//			stop = YES;
//		}
		NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
		CIContext *core_image_context = [context CIContext];
		
	}];
	
    [pool drain];
    return 0;
}

FlickrPhoto *process_photo_node(NSXMLNode *node)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSRunLoop *run_loop = [NSRunLoop currentRunLoop];
	BOOL shouldKeepRunning = YES;
	
	if ([node kind] != NSXMLElementKind) {
		NSLog(@"Expecting XML element, got something else");
		return nil;
	}
	NSXMLElement *photo_elem = (NSXMLElement *)node;
	
	NSString *value = [[photo_elem attributeForName:@"url_sq"] stringValue];
	if(value == nil) {
		NSLog(@"Photo URL was nil");
		[pool drain];
		return nil;
	}

	// Retrieve the image
	FlickrPhoto *photo = [[FlickrPhoto alloc] init];
	NSURL *photoUrl = [NSURL URLWithString:value];
	NSURLRequest *photoRequest = [NSURLRequest requestWithURL:photoUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:photoRequest delegate:photo];
	if(!connection) {
		NSLog(@"Error starting UrlConnection");
		return nil;
	}
	
	// Pump the run loop because we're not a GUI app
	// TODO: This will keep allocating date objects, perhaps should drain the pool in the loop
	while (shouldKeepRunning && [run_loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:60.0]])
	{
		if([photo isFinished]) shouldKeepRunning = NO;
	}
	
	// TODO: Check if photo is valid
	
	[pool drain];
	return [photo autorelease];
}
