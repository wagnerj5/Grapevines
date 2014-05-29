//
//  Decode.h
//  Grapevines
//
//  Created by Justin Wagner on 2/26/14.
//  Copyright (c) 2014 Justin Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Decode : NSObject

//extracts hidden text from a carrier image
+ (NSString *) decodeText:(UIImage *) inImage;

//extracts a hidden image from a carrier image
+ (UIImage *) decodeImage:(UIImage *) inImage;

//checks to see if a carrier image has hidden text
+ (BOOL) hasHiddenText:(UIImage *) inImage;

//checks to see if a carrier image has hidden image
+ (BOOL) hasHiddenImage:(UIImage *) inImage;

@end
