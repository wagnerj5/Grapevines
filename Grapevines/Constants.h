//
//  Constants.h
//  Grapevines
//
//  Created by Justin Wagner on 2/26/14.
//  Copyright (c) 2014 Justin Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

//constants for ARGB pixels
typedef enum
{
    ALPHA = 0,
    RED = 1,
    GREEN = 2,
    BLUE = 3
    
} PIXELS;

//Alert view tags
typedef enum
{
    TAG_SaveImage,
    TAG_SaveHideImage,
    TAG_EncodeText,
    TAG_Encode
    
} ALERT_TAG;

//bits per byte
extern int const kBitsPerComponent;

//bytes per pixel
extern int const kBytesPerPixel;


@end
