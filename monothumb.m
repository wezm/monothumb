#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>
#import "FlickrPhoto.h"
#import "FlickrClient.h"

FlickrPhoto *process_photo_node(NSXMLNode *node);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSError *errors;

	FlickrClient *flickr = [[FlickrClient alloc] init];
	
	[flickr fetchPhotos]; // XXX: rename this method: getRecentPhotos, photostream...?
	
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
		// TODO: photo should fetch its data here
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
		CGPoint dest_point = {idx * 75, 0};
		[core_image_context drawImage:result atPoint:dest_point fromRect:src_rect];
		dest_point.y = 75;
		[core_image_context drawImage:image atPoint:dest_point fromRect:src_rect];
	}];
	
	NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:NSImageCompressionFactor, [NSNumber numberWithFloat:0.9], NSImageProgressive, [NSNumber numberWithBool:YES], NSImageFallbackBackgroundColor, [NSColor whiteColor], nil];
	NSData *final_image = [dest representationUsingType:NSJPEGFileType properties:properties];
	[final_image writeToFile:@"output.jpg" options:0 error:&errors];
	
    [pool drain];
    return 0;
}
