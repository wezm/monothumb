//
//  Photo.h
//  monothumb
//
//  Created by Wesley Moore on 28/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FlickrPhoto : NSObject {
//	NSString *identifier;
//	NSString *owner;
	NSString *title;
	NSURL *url;
//	NSURL *mediumUrl;
	NSSize dimensions;
//	NSSize mediumDimensions;
	NSMutableData *data;
	BOOL finished;
	NSString *file_name;
}

@property(retain) NSURL	*url;
@property(retain) NSString *title;
@property(assign) NSSize dimensions;


// <photo id="4302502138" owner="40215689@N00" secret="f126101e85" server="2705" farm="3"
// title="_MG_7957" ispublic="1" isfriend="0" isfamily="0" 
// url_sq="http://farm3.static.flickr.com/2705/4302502138_f126101e85_s.jpg"
// height_sq="75" width_sq="75"
// url_m="http://farm3.static.flickr.com/2705/4302502138_f126101e85.jpg"
// height_m="333" width_m="500" />

- (id)initWithXMLElement:(NSXMLElement *)element;
//- (id)initWithDict:(NSDictionary *)attributes;
- (BOOL)isValid;
//- (NSURL *)photoPageURL;

- (BOOL)loadAndReturnError:(NSError **)error;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (BOOL)isFinished;
- (NSData *)data;

@end
