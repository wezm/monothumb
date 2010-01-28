//
//  PhotoXMLDelegate.h
//  monothumb
//
//  Created by Wesley Moore on 28/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlickrPhoto.h"

@interface PhotoXMLDelegate : NSObject <NSXMLParserDelegate> {
	NSMutableArray *photos;
	FlickrPhoto *photo;
	BOOL responseOk;
	BOOL expectingErrorElement;
}

@end
