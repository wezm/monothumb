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

- (void)testFetchPhotosParseError
{
	client.xml = nil;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertEqualStrings(@"Error parsing the photo XML", [error localizedDescription], nil);
}

- (void)testFetchPhotosMissingStat
{
	client.xml = error_xml;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertEqualStrings(@"GET", [error localizedDescription], nil);
}

- (void)testFetchPhotosStatNotOk
{
	client.xml = error_xml;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertEqualStrings(@"GET", [error localizedDescription], nil);
}

- (void)testFetchPhotosXPathError
{
	client.xml = error_xml;
	[client fetchPhotosAndReturnError:&error];
	
	GHAssertNotNil(error, @"Error should not be nil");
	GHAssertEqualStrings(@"GET", [error localizedDescription], nil);
}

//- (void)testParseSimple {
//	char *request_string = "GET / HTTP/1.1\r\n\r\n";
//	NSData *request = [NSData dataWithBytes:request_string length:strlen(request_string)+1]; // +1 to include terminating NUL char
//	size_t bytes_read = [parser executeOnData:request startingAt:0];
//	
//	//GHTestLog(@"%s vs. %s", @encode(__typeof__(bytes_read)), @encode(__typeof__([parser bytesRead])));
////    assert nread == http.length, "Failed to parse the full HTTP request"
//	GHAssertEquals(bytes_read, [request length], @"Failed to parse the full HTTP request");
////    assert parser.finished?, "Parser didn't finish"
//	GHAssertTrue([parser isFinished], @"Parser didn't finish");
////    assert !parser.error?, "Parser had error"
//	GHAssertFalse([parser hasError], @"Parser had error");
////    assert nread == parser.nread, "Number read returned from execute does not match"
//	GHAssertEquals(bytes_read, [parser bytesRead], @"Number read returned from execute does not match");
//
//	NSDictionary *req = [parser requestParams];
//	GHAssertEqualStrings(@"HTTP/1.1", [req objectForKey:@"SERVER_PROTOCOL"], nil);
////    assert_equal 'HTTP/1.1', req['SERVER_PROTOCOL']
//	GHAssertEqualStrings(@"/", [req objectForKey:@"REQUEST_PATH"], nil);
////    assert_equal '/', req['REQUEST_PATH']
//	GHAssertEqualStrings(@"HTTP/1.1", [req objectForKey:@"HTTP_VERSION"], nil);
////    assert_equal 'HTTP/1.1', req['HTTP_VERSION']
//	GHAssertEqualStrings(@"/", [req objectForKey:@"REQUEST_URI"], nil);
////    assert_equal '/', req['REQUEST_URI']
//	GHAssertEqualStrings(@"CGI/1.2", [req objectForKey:@"GATEWAY_INTERFACE"], nil);
////    assert_equal 'CGI/1.2', req['GATEWAY_INTERFACE']
//	GHAssertEqualStrings(@"GET", [req objectForKey:@"REQUEST_METHOD"], nil);
////    assert_equal 'GET', req['REQUEST_METHOD']    
//	GHAssertNil([req objectForKey:@"FRAGMENT"], nil);
////    assert_nil req['FRAGMENT']
//	GHAssertNil([req objectForKey:@"QUERY_STRING"], nil);
////    assert_nil req['QUERY_STRING']
////    
////    parser.reset
////    assert parser.nread == 0, "Number read after reset should be 0"
//}
//
//- (void)testParseStupidHeaders {
//	/*
//	 parser = HttpParser.new
//	 req = {}
//	 should_be_good = "GET / HTTP/1.1\r\naaaaaaaaaaaaa:++++++++++\r\n\r\n"
//	 nread = parser.execute(req, should_be_good, 0)
//	 assert_equal should_be_good.length, nread
//	 assert parser.finished?
//	 assert !parser.error?
//	 
//	 nasty_pound_header = "GET / HTTP/1.1\r\nX-SSL-Bullshit:   -----BEGIN CERTIFICATE-----\r\n\tMIIFbTCCBFWgAwIBAgICH4cwDQYJKoZIhvcNAQEFBQAwcDELMAkGA1UEBhMCVUsx\r\n\tETAPBgNVBAoTCGVTY2llbmNlMRIwEAYDVQQLEwlBdXRob3JpdHkxCzAJBgNVBAMT\r\n\tAkNBMS0wKwYJKoZIhvcNAQkBFh5jYS1vcGVyYXRvckBncmlkLXN1cHBvcnQuYWMu\r\n\tdWswHhcNMDYwNzI3MTQxMzI4WhcNMDcwNzI3MTQxMzI4WjBbMQswCQYDVQQGEwJV\r\n\tSzERMA8GA1UEChMIZVNjaWVuY2UxEzARBgNVBAsTCk1hbmNoZXN0ZXIxCzAJBgNV\r\n\tBAcTmrsogriqMWLAk1DMRcwFQYDVQQDEw5taWNoYWVsIHBhcmQYJKoZIhvcNAQEB\r\n\tBQADggEPADCCAQoCggEBANPEQBgl1IaKdSS1TbhF3hEXSl72G9J+WC/1R64fAcEF\r\n\tW51rEyFYiIeZGx/BVzwXbeBoNUK41OK65sxGuflMo5gLflbwJtHBRIEKAfVVp3YR\r\n\tgW7cMA/s/XKgL1GEC7rQw8lIZT8RApukCGqOVHSi/F1SiFlPDxuDfmdiNzL31+sL\r\n\t0iwHDdNkGjy5pyBSB8Y79dsSJtCW/iaLB0/n8Sj7HgvvZJ7x0fr+RQjYOUUfrePP\r\n\tu2MSpFyf+9BbC/aXgaZuiCvSR+8Snv3xApQY+fULK/xY8h8Ua51iXoQ5jrgu2SqR\r\n\twgA7BUi3G8LFzMBl8FRCDYGUDy7M6QaHXx1ZWIPWNKsCAwEAAaOCAiQwggIgMAwG\r\n\tA1UdEwEB/wQCMAAwEQYJYIZIAYb4QgEBBAQDAgWgMA4GA1UdDwEB/wQEAwID6DAs\r\n\tBglghkgBhvhCAQ0EHxYdVUsgZS1TY2llbmNlIFVzZXIgQ2VydGlmaWNhdGUwHQYD\r\n\tVR0OBBYEFDTt/sf9PeMaZDHkUIldrDYMNTBZMIGaBgNVHSMEgZIwgY+AFAI4qxGj\r\n\tloCLDdMVKwiljjDastqooXSkcjBwMQswCQYDVQQGEwJVSzERMA8GA1UEChMIZVNj\r\n\taWVuY2UxEjAQBgNVBAsTCUF1dGhvcml0eTELMAkGA1UEAxMCQ0ExLTArBgkqhkiG\r\n\t9w0BCQEWHmNhLW9wZXJhdG9yQGdyaWQtc3VwcG9ydC5hYy51a4IBADApBgNVHRIE\r\n\tIjAggR5jYS1vcGVyYXRvckBncmlkLXN1cHBvcnQuYWMudWswGQYDVR0gBBIwEDAO\r\n\tBgwrBgEEAdkvAQEBAQYwPQYJYIZIAYb4QgEEBDAWLmh0dHA6Ly9jYS5ncmlkLXN1\r\n\tcHBvcnQuYWMudmT4sopwqlBWsvcHViL2NybC9jYWNybC5jcmwwPQYJYIZIAYb4QgEDBDAWLmh0\r\n\tdHA6Ly9jYS5ncmlkLXN1cHBvcnQuYWMudWsvcHViL2NybC9jYWNybC5jcmwwPwYD\r\n\tVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NhLmdyaWQt5hYy51ay9wdWIv\r\n\tY3JsL2NhY3JsLmNybDANBgkqhkiG9w0BAQUFAAOCAQEAS/U4iiooBENGW/Hwmmd3\r\n\tXCy6Zrt08YjKCzGNjorT98g8uGsqYjSxv/hmi0qlnlHs+k/3Iobc3LjS5AMYr5L8\r\n\tUO7OSkgFFlLHQyC9JzPfmLCAugvzEbyv4Olnsr8hbxF1MbKZoQxUZtMVu29wjfXk\r\n\thTeApBv7eaKCWpSp7MCbvgzm74izKhu3vlDk9w6qVrxePfGgpKPqfHiOoGhFnbTK\r\n\twTC6o2xq5y0qZ03JonF7OJspEd3I5zKY3E+ov7/ZhW6DqT8UFvsAdjvQbXyhV8Eu\r\n\tYhixw1aKEPzNjNowuIseVogKOLXxWI5vAi5HgXdS0/ES5gDGsABo4fqovUKlgop3\r\n\tRA==\r\n\t-----END CERTIFICATE-----\r\n\r\n"
//	 parser = HttpParser.new
//	 req = {}
//	 #nread = parser.execute(req, nasty_pound_header, 0)
//	 #assert_equal nasty_pound_header.length, nread
//	 #assert parser.finished?
//	 #assert !parser.error?
//	*/
//
//	char *request_string = "GET / HTTP/1.1\r\naaaaaaaaaaaaa:++++++++++\r\n\r\n";
//	NSData *request = [NSData dataWithBytes:request_string length:strlen(request_string)+1]; // +1 to include terminating NUL char
//	size_t bytes_read = [parser executeOnData:request startingAt:0];
//	
//	GHAssertEquals(bytes_read, [request length], @"Failed to parse the full HTTP request");
//	GHAssertTrue([parser isFinished], @"Parser didn't finish");
//	GHAssertFalse([parser hasError], @"Parser had error");
//}
//
//- (void)testParseNastyPoundHeader {
//	char *request_string = "GET / HTTP/1.1\r\nX-SSL-Bullshit:   -----BEGIN CERTIFICATE-----\r\n\tMIIFbTCCBFWgAwIBAgICH4cwDQYJKoZIhvcNAQEFBQAwcDELMAkGA1UEBhMCVUsx\r\n\tETAPBgNVBAoTCGVTY2llbmNlMRIwEAYDVQQLEwlBdXRob3JpdHkxCzAJBgNVBAMT\r\n\tAkNBMS0wKwYJKoZIhvcNAQkBFh5jYS1vcGVyYXRvckBncmlkLXN1cHBvcnQuYWMu\r\n\tdWswHhcNMDYwNzI3MTQxMzI4WhcNMDcwNzI3MTQxMzI4WjBbMQswCQYDVQQGEwJV\r\n\tSzERMA8GA1UEChMIZVNjaWVuY2UxEzARBgNVBAsTCk1hbmNoZXN0ZXIxCzAJBgNV\r\n\tBAcTmrsogriqMWLAk1DMRcwFQYDVQQDEw5taWNoYWVsIHBhcmQYJKoZIhvcNAQEB\r\n\tBQADggEPADCCAQoCggEBANPEQBgl1IaKdSS1TbhF3hEXSl72G9J+WC/1R64fAcEF\r\n\tW51rEyFYiIeZGx/BVzwXbeBoNUK41OK65sxGuflMo5gLflbwJtHBRIEKAfVVp3YR\r\n\tgW7cMA/s/XKgL1GEC7rQw8lIZT8RApukCGqOVHSi/F1SiFlPDxuDfmdiNzL31+sL\r\n\t0iwHDdNkGjy5pyBSB8Y79dsSJtCW/iaLB0/n8Sj7HgvvZJ7x0fr+RQjYOUUfrePP\r\n\tu2MSpFyf+9BbC/aXgaZuiCvSR+8Snv3xApQY+fULK/xY8h8Ua51iXoQ5jrgu2SqR\r\n\twgA7BUi3G8LFzMBl8FRCDYGUDy7M6QaHXx1ZWIPWNKsCAwEAAaOCAiQwggIgMAwG\r\n\tA1UdEwEB/wQCMAAwEQYJYIZIAYb4QgEBBAQDAgWgMA4GA1UdDwEB/wQEAwID6DAs\r\n\tBglghkgBhvhCAQ0EHxYdVUsgZS1TY2llbmNlIFVzZXIgQ2VydGlmaWNhdGUwHQYD\r\n\tVR0OBBYEFDTt/sf9PeMaZDHkUIldrDYMNTBZMIGaBgNVHSMEgZIwgY+AFAI4qxGj\r\n\tloCLDdMVKwiljjDastqooXSkcjBwMQswCQYDVQQGEwJVSzERMA8GA1UEChMIZVNj\r\n\taWVuY2UxEjAQBgNVBAsTCUF1dGhvcml0eTELMAkGA1UEAxMCQ0ExLTArBgkqhkiG\r\n\t9w0BCQEWHmNhLW9wZXJhdG9yQGdyaWQtc3VwcG9ydC5hYy51a4IBADApBgNVHRIE\r\n\tIjAggR5jYS1vcGVyYXRvckBncmlkLXN1cHBvcnQuYWMudWswGQYDVR0gBBIwEDAO\r\n\tBgwrBgEEAdkvAQEBAQYwPQYJYIZIAYb4QgEEBDAWLmh0dHA6Ly9jYS5ncmlkLXN1\r\n\tcHBvcnQuYWMudmT4sopwqlBWsvcHViL2NybC9jYWNybC5jcmwwPQYJYIZIAYb4QgEDBDAWLmh0\r\n\tdHA6Ly9jYS5ncmlkLXN1cHBvcnQuYWMudWsvcHViL2NybC9jYWNybC5jcmwwPwYD\r\n\tVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NhLmdyaWQt5hYy51ay9wdWIv\r\n\tY3JsL2NhY3JsLmNybDANBgkqhkiG9w0BAQUFAAOCAQEAS/U4iiooBENGW/Hwmmd3\r\n\tXCy6Zrt08YjKCzGNjorT98g8uGsqYjSxv/hmi0qlnlHs+k/3Iobc3LjS5AMYr5L8\r\n\tUO7OSkgFFlLHQyC9JzPfmLCAugvzEbyv4Olnsr8hbxF1MbKZoQxUZtMVu29wjfXk\r\n\thTeApBv7eaKCWpSp7MCbvgzm74izKhu3vlDk9w6qVrxePfGgpKPqfHiOoGhFnbTK\r\n\twTC6o2xq5y0qZ03JonF7OJspEd3I5zKY3E+ov7/ZhW6DqT8UFvsAdjvQbXyhV8Eu\r\n\tYhixw1aKEPzNjNowuIseVogKOLXxWI5vAi5HgXdS0/ES5gDGsABo4fqovUKlgop3\r\n\tRA==\r\n\t-----END CERTIFICATE-----\r\n\r\n";
//	NSData *request = [NSData dataWithBytes:request_string length:strlen(request_string)+1]; // +1 to include terminating NUL char
//	[parser executeOnData:request startingAt:0];
//	
//	GHAssertTrue([parser hasError], @"Parser should be in an error state");
//}
//
//- (void)testParseError {
//	char *request_string = "GET / SsUTF/1.1";
//	NSData *request = [NSData dataWithBytes:request_string length:strlen(request_string)+1]; // +1 to include terminating NUL char
//	[parser executeOnData:request startingAt:0];
//	
//	GHAssertTrue([parser hasError], @"Parser should be in an error state");
//	GHAssertNotNil([parser parserError], @"Parser should have an error object");
//	GHAssertFalse([parser isFinished], @"Parser didn't finish");
//}
//
//- (void)testFragementInUri {
//	char *request_string = "GET /forums/1/topics/2375?page=1#posts-17408 HTTP/1.1\r\n\r\n";
//	NSData *request = [NSData dataWithBytes:request_string length:strlen(request_string)+1]; // +1 to include terminating NUL char
//	size_t bytes_read = [parser executeOnData:request startingAt:0];
//	
//	GHAssertEquals(bytes_read, [request length], @"Failed to parse the full HTTP request");
//	GHAssertTrue([parser isFinished], @"Parser didn't finish");
//	GHAssertFalse([parser hasError], @"Parser is in error state");
//	NSDictionary *req = [parser requestParams];
//	GHAssertNotNil(req, nil);
//	GHAssertEqualStrings(@"/forums/1/topics/2375?page=1", [req objectForKey:@"REQUEST_URI"], nil);
//	GHAssertEqualStrings(@"posts-17408", [req objectForKey:@"FRAGMENT"], nil);
//}
//
//- (void)testHorribleQueries {
//	
//}

@end
