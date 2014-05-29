//
//  Encode.h
//  Grapevines
//
//  Created by Justin Wagner on 2/13/14.
//  Copyright (c) 2014 Justin Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encode : NSObject

//method to encode a text message into an image
+ (UIImage *) encodeImage:(UIImage *) inImage withText:(NSString *) inText;

//method to encode an image into an image
+ (UIImage *) encodeImage:(UIImage *) shownImage withImage:(UIImage *) hiddenImage; 

//converts a text string to a byte array
+ (unsigned char *) convertAscii: (NSString *) inText;

@end
