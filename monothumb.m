#import <Foundation/Foundation.h>
#import "PhotoXMLDelegate.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSURL *api_url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=aa003631cc50bd47f27f242d30bcd22f&user_id=40215689%40N00&per_page=20&extras=url_sq,url_m"];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:api_url];
	
	//NSAssert(parser != nil, @"Parser is nil");
	
	PhotoXMLDelegate *xml_delegate = [[PhotoXMLDelegate alloc] init];
	[parser setDelegate:xml_delegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];

	
	
	[parser parse];
	
    [pool drain];
    return 0;
}
