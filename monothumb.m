#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

void process_photo_node(NSXMLNode *node);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSError *errors;
	NSURL *api_url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=aa003631cc50bd47f27f242d30bcd22f&user_id=40215689%40N00&per_page=20&extras=url_sq,url_m"];
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithContentsOfURL:api_url options:NSXMLNodeOptionsNone error:&errors];
	NSXMLElement *e;
	NSString *stat;
	NSArray *photo_nodes;
	
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

	//NSLog(@"%@", photo_nodes);
	[photo_nodes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSXMLNode *node = (NSXMLNode *)obj;
		process_photo_node(node);
	}];
	
    [pool drain];
    return 0;
}

void process_photo_node(NSXMLNode *node)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSRunLoop *run_loop = [NSRunLoop currentRunLoop];
	BOOL shouldKeepRunning = YES;
	
	if ([node kind] != NSXMLElementKind) {
		NSLog(@"Expecting XML element, got something else");
		return;
	}
	NSXMLElement *photo_elem = (NSXMLElement *)node;
	
	NSString *value = [[photo_elem attributeForName:@"url_sq"] stringValue];
	if(value == nil) {
		NSLog(@"Photo URL was nil");
		[pool drain];
		return;
	}

	// Retrieve the image
	FlickrPhoto *photo = [[FlickrPhoto alloc] init];
	NSURL *photoUrl = [NSURL URLWithString:value];
	NSURLRequest *photoRequest = [NSURLRequest requestWithURL:photoUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:photoRequest delegate:photo];
	if(!connection) {
		NSLog(@"Error starting UrlConnection");
	}
	
	while (shouldKeepRunning && [run_loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
	{
		if([photo isFinished]) shouldKeepRunning = NO;
	}
	
	[pool drain];
}
