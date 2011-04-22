#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>
#import "FlickrPhoto.h"
#import "FlickrClient.h"

void usage() {
	fprintf(stderr, "Usage: monothumb output.jpg\n");
}

void print_error(NSString *message, NSError *error) {
	if(message != nil) NSLog(@"%@:", message);
	if(error == nil) return;
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSError *underlying_error = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
	NSLog(@"%@", [error localizedDescription]);
	print_error(nil, underlying_error);

	[pool drain];
}

int main (int argc, const char * argv[]) {
	if (argc < 2) {
		usage();
		return 2;
	}
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSError *error = nil;
	BOOL ok;

	NSString *output_path = [NSString stringWithUTF8String:argv[1]];
	FlickrClient *flickr = [[FlickrClient alloc] init];
	
	ok = [flickr fetchPhotosAndReturnError:&error]; // XXX: rename this method: getRecentPhotos, photostream...?
	if(!ok) {
		print_error(@"Unable to get Flickr photostream", error);
		[pool drain];
		return 1;
	}
	
	// Create the destination image
	NSInteger pixel_width = 75 * 20;
	NSInteger pixel_height = 75 * 2;
	NSInteger bytes_per_row = pixel_width * 4;
	NSBitmapImageRep *dest = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																	 pixelsWide:pixel_width
																	 pixelsHigh:pixel_height
																  bitsPerSample:8 
																samplesPerPixel:3
																	   hasAlpha:NO
																	   isPlanar:NO
																 colorSpaceName:NSCalibratedRGBColorSpace
																	bytesPerRow:0
																   bitsPerPixel:32];
	if(dest == nil)
	{
		NSLog(@"Unable to allocate destination image rep");
		[pool drain];
		return 1;
	}

	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:dest];
	CIContext *core_image_context = [context CIContext];

	[[flickr photos] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		FlickrPhoto *photo = (FlickrPhoto *)obj;
        NSLog(@"%@", photo.title);

		NSError *error = nil;
        if(![photo loadAndReturnError:&error]) {
            NSString *error_message = [error localizedDescription];
            NSLog(@"Error loading photo %@: %@", photo.url, error_message);
            *stop = YES;
            return;
        }
		CIImage *image = [CIImage imageWithData:[photo data]];

		// Apply the monochrome filter
		CIFilter *mono_filter = [CIFilter filterWithName:@"CIColorMonochrome"];
		if(mono_filter == nil)
		{
			NSLog(@"Error getting CIColorMonochrome filter");
			[flickr release];
			[pool drain];
			return;
		}
		
		[mono_filter setDefaults];
		[mono_filter setValue:image forKey:@"inputImage"];
		CIColor *grey = [CIColor colorWithRed:0.5 green:0.5 blue:0.5];
		[mono_filter setValue:grey forKey:@"inputColor"];
		//[mono_filter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputIntensity"];
		
		CIImage *result = [mono_filter valueForKey:@"outputImage"];
		
		// Draw the result in the destination context
		CGRect src_rect = NSRectToCGRect(NSMakeRect(0, 0, 75, 75));
		CGPoint dest_point = {idx * 75, 75};
		[core_image_context drawImage:result atPoint:dest_point fromRect:src_rect];
		dest_point.y = 0;
		[core_image_context drawImage:image atPoint:dest_point fromRect:src_rect];
	}];
	
	NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:NSImageCompressionFactor, [NSNumber numberWithFloat:0.9], NSImageProgressive, [NSNumber numberWithBool:YES], NSImageFallbackBackgroundColor, [NSColor whiteColor], nil];
	NSData *final_image = [dest representationUsingType:NSJPEGFileType properties:properties];
	[final_image writeToFile:output_path options:0 error:&error];

	// Write out the Flickr XML as well
    NSString *xml_output_path = [[output_path stringByDeletingPathExtension] stringByAppendingPathExtension:@"xml"];
    [[flickr.xml XMLData] writeToFile:xml_output_path atomically:NO];
    
    [pool drain];
    return 0;
}
