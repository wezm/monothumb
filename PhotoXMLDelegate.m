//
//  PhotoXMLDelegate.m
//  monothumb
//
//  Created by Wesley Moore on 28/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhotoXMLDelegate.h"

@implementation PhotoXMLDelegate

- (id)init
{
	if((self = [super init]) != nil)
	{
		photos = [[NSMutableArray alloc] init];
		responseOk = NO;
		expectingErrorElement = NO;
	}
	
	return self;
}

//- (void)parserDidStartDocument:(NSXMLParser *)parser
//{
//	NSLog(@"Start document");
//}
//
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	NSLog(@"%@", photos);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	NSLog(@"Start element %@", elementName);
	if (responseOk) {
		if ([elementName compare:@"photo"] == NSOrderedSame) {
			if(photo != nil) {
				NSLog(@"Got new photo before last one finsihed");
				[parser abortParsing];
			}
			
			photo = [[FlickrPhoto alloc] initWithDict:attributeDict];
		}
	}
	else {
		if ([elementName compare:@"rsp"] == NSOrderedSame) {
			NSString *stat = [attributeDict objectForKey:@"stat"];
			if(stat != nil) {
				responseOk = [stat compare:@"ok"] == NSOrderedSame ? YES : NO;
				if(!responseOk) expectingErrorElement = YES;
			}
		}
	}

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSLog(@"End element %@", elementName);
	if (responseOk && [elementName compare:@"photo"] == NSOrderedSame) {
		[photos addObject:photo];
		[photo release];
		photo = nil;
	}
}

//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
//{
//	NSLog(@"Got text: %@", string);
//}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"A parsing error ocurred");
}
	
@end
