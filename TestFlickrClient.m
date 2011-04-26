#import "FlickrClient.h"

@interface TestFlickrClient : GHTestCase {
	NSError *error;
	FlickrClient *client;
	NSXMLDocument *xml;
	NSXMLDocument *error_xml;
}
@end

@implementation TestFlickrClient

-(NSXMLDocument *)sampleXMLDocumentNamed:(NSString *)name
{
	NSError *errors;
	NSData *xml_data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:name withExtension:@"xml"]];
	return [[NSXMLDocument alloc] initWithData:xml_data options:NSXMLNodeOptionsNone error:&errors];
}	

- (void)setUpClass {
    // Run at start of all tests in the class
	xml = [self sampleXMLDocumentNamed:@"sample_response"];
	error_xml = [self sampleXMLDocumentNamed:@"sample_error_response"];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
	if(xml) [xml release];
	if(error_xml) [error_xml release];
}

- (void)setUp {
    // Run before each test method
	client = [[FlickrClient alloc] init];
	error = nil;
}
//
- (void)tearDown {
    // Run after each test method
	if(client != nil) [client release];
}

- (void)testFetchPhotosSuccess
{
	client.xml = xml;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNil(error, @"Error should be nil");
	GHAssertEquals((NSUInteger)20, [[client photos] count], @"Didn't create all 20 photos");
	
}

//- (void)testFetchPhotosParseError
//{
//	client.xml = nil;
//	[client fetchPhotosAndReturnError:&error];
//	
//	GHAssertNotNil(error, @"Error should not be nil");
//	GHAssertEqualStrings(@"Error parsing the photo XML", [error localizedDescription], nil);
//}

- (void)testFetchPhotosMissingStat
{
	NSString *xml_string = @"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<rsp nostat=\"missing\"></rsp>";
	NSXMLDocument *xml_doc = [[NSXMLDocument alloc] initWithXMLString:xml_string options:NSXMLNodeOptionsNone error:nil];
	client.xml = xml_doc;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertEqualStrings(@"Expected stat attribute but got nil", [error localizedDescription], nil);
}

- (void)testFetchPhotosStatNotOk
{
	client.xml = error_xml;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertEqualStrings(@"Stat not ok: fail", [error localizedDescription], nil);
}

- (void)pending_testFetchPhotosXPathError
{
	client.xml = error_xml;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertEqualStrings(@"Error getting photos elements", [error localizedDescription], nil);
}

@end
