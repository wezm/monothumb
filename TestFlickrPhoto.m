//
//  TestFlickrPhoto.m
//  monothumb
//
//  Created by Wesley Moore on 23/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhoto.h"

@interface TestFlickrPhoto : GHTestCase {
	FlickrPhoto *photo;
	NSXMLElement *elem;
//	NSXMLDocument *error_xml;
	id mock_connection;
}
@end

@implementation TestFlickrPhoto

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
	NSArray *keys = [NSArray arrayWithObjects:@"url_sq", @"height_sq", @"width_sq", @"title", nil];
	NSArray *values = [NSArray arrayWithObjects:@"http://example.com/", @"75", @"75", @"_MG_7957", nil];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	elem = [[NSXMLElement alloc] initWithName:@"photo"];
	[elem setAttributesAsDictionary:attributes];

	mock_connection = [OCMockObject mockForClass:[NSURLConnection class]];
}
//
- (void)tearDown {
    // Run after each test method
	[mock_connection verify];
	
	if(elem) [elem release];
	if(photo) [photo release];
}

- (void)testUrl
{
	photo = [[FlickrPhoto alloc] initWithXMLElement:elem];
	NSURL *url = [NSURL URLWithString:@"http://example.com/"];
	GHAssertEqualObjects(url, photo.url, @"Photo url is not equal");
}

- (void)testDimensions
{
	photo = [[FlickrPhoto alloc] initWithXMLElement:elem];
	NSSize size = NSMakeSize(75.0, 75.0);
	GHAssertEquals(size, photo.dimensions, @"Photo dimensions are not 75x75");
}

- (void)testTitle
{
	photo = [[FlickrPhoto alloc] initWithXMLElement:elem];
	GHAssertEqualStrings(@"_MG_7957", photo.title, @"Photo title doesn't match");
}

- (void)testValid
{
	photo = [[FlickrPhoto alloc] initWithXMLElement:elem];
	GHAssertTrue([photo isValid], nil);
}

- (void)testInvalid
{
	[elem removeAttributeForName:@"url_sq"];
	NSXMLNode *attr = [NSXMLNode attributeWithName:@"url_sq" stringValue:@"I'm not a valid URL"];
	[elem addAttribute:attr];
	photo = [[FlickrPhoto alloc] initWithXMLElement:elem];
	GHAssertNotNil(photo, nil);
	GHAssertFalse([photo isValid], nil);
}

- (void)testInitFailure
{
	[elem removeAttributeForName:@"url_sq"];
	photo = [[FlickrPhoto alloc] initWithXMLElement:elem];
	GHAssertNil(photo, nil);
}

//- (void)testSuccessfullyLoadAndReturnError
//{
//	NSError *error = nil;
//	photo = [[FlickrPhoto alloc] initWithXMLElement:elem];
//
//	// 	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:photoRequest delegate:self startImmediately:NO];
//	[[mock_connection expect] initWithRequest:OCMOCK_ANY delegate:photo];
//
//	BOOL result = [photo loadAndReturnError:&error];
//	GHAssertTrue(result, @"did not return YES");
//	GHAssertNil(error, @"Expected error to be nil");
//}

@end
