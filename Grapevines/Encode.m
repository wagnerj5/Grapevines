//
//  Encode.m
//  Grapevines
//
//  Created by Justin Wagner on 2/13/14.
//  Copyright (c) 2014 Justin Wagner. All rights reserved.
//

#import "Encode.h"
#import "Constants.h"

@implementation Encode

//hides a text string within a carrier image
+ (UIImage *) encodeImage:(UIImage *) inImage withText:(NSString *) inText
{
    int count = 0;
    
    //length of the user's input message to be hidden as a string
    NSString* textLength = [NSString stringWithFormat:@"%u", [inText length]];
    
    int lengthInfoSize = [textLength length] + 1; //# of bits the length information needs for storage
    
    int encodingSize = [inText length] * 4 + (lengthInfoSize * 4); //total size of the data to be stored
    
    //array designated to hold the text string's byte data
    unsigned char *charArray = (unsigned char*) calloc(encodingSize, sizeof(unsigned char));
    
    //converts the input text into bits and puts them in charArray
    charArray = [self convertAscii:inText];
    
    //width and height of the carrier image
    NSUInteger width = inImage.size.width;
    NSUInteger height = inImage.size.height;
    
    NSUInteger bytesPerRow = kBytesPerPixel * width;
    
    // the pixels will be saved to this array
    unsigned char *pixelData = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with ARGB pixels
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 width,
                                                 height,
                                                 kBitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst);
    
    // set the bitmap to our context which will fill in the pixels array
    CGImageRef imageRef = [inImage CGImage];
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    //loops throught the carrier image's pixels and clears the last two bits from them
    //and then replaces those two bits with bits of information of the message being hidden
    for(int y = 0; y < height && count < encodingSize; y++)
    {
        for(int x = 0; x < width && count < encodingSize; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];

            
            if(count < encodingSize)
            {
                pixel[ALPHA] = (pixel[ALPHA]/4) * 4 + charArray[count];
                count++;
            }
            
            if(count < encodingSize)
            {
                pixel[RED] = (pixel[RED]/4) * 4 + charArray[count];
                count++;
            }
            
            if(count < encodingSize)
            {
                pixel[GREEN] = (pixel[GREEN]/4) * 4 + charArray[count];
                count++;
            }
            
            if(count < encodingSize)
            {
                pixel[BLUE] = (pixel[BLUE]/4) * 4 + charArray[count];
                count++;
            }
        }
    }
    
    // create a new CGImageRef from the context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    free(charArray);
    free(pixelData);
    
    //generates a new uiimage with the hidden text to be returned by the function
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);

    
    return resultUIImage;
}

+ (unsigned char *) convertAscii: (NSString *) inText
{
    int index = 0;
    
    //length of the input text in string form
    NSString* textLength = [NSString stringWithFormat:@"%u", [inText length]];
    
    //length of the text string's length information saved in the beginning pixels
    int lengthInfoSize = [textLength length] + 1;
    
    //number of bytes needed to hold the text string bytes and the length info bytes
    int encodingSize = [inText length] * 4 + (lengthInfoSize * 4);
    
    //holds the bit pairs of each character byte
    unsigned char * argbArray = (unsigned char*) calloc(encodingSize, sizeof(unsigned char));
    
    //converts length of text input into an ascii value so that
    //the decoder knows how many pixels hold the secret message
    //strips four pairs of two bits from each byte and saves them
    //to the argbArray
    for(int i=0; i<[textLength length]; i++)
    {
        unsigned char length = [textLength characterAtIndex:i];

        argbArray[index]    = length/64;         //alpha
        argbArray[index+1]  = (length%64)/16;    //red
        argbArray[index+2]  = (length%16)/4;     //green
        argbArray[index+3]  = length%4;          //blue
        index+=4;
    }
    
    //sets end of text EOT character as delimeter for real message
    
    argbArray[index]    = 0;      //alpha
    argbArray[index+1]  = 0;      //red
    argbArray[index+2]  = 0;      //green
    argbArray[index+3]  = 3;      //blue
    index+=4;

    //converts an NSString's characters into unsigned chars,
    //splitting each character (byte) into 4 pairs of two bits
    //so they can be hidden in the last two bits of the image's
    //argb data
    for (int i=0; i<[inText length]; i++)
    {
        unsigned char character = [inText characterAtIndex:i];
        
        argbArray[index]    = character/64;         //alpha
        argbArray[index+1]  = (character%64)/16;    //red
        argbArray[index+2]  = (character%16)/4;     //green
        argbArray[index+3]  = character%4;          //blue
        index+=4;
    }
    
    return argbArray;
}

//hides an image into a carrier image
+ (UIImage *) encodeImage:(UIImage *) shownImage withImage:(UIImage *) hiddenImage
{
    int count = 0;
    
    //shown (carrier) image width + height
    NSUInteger widthS = shownImage.size.width;
    NSUInteger heightS = shownImage.size.height;
    
    //hidden image width + height
    NSUInteger widthH = hiddenImage.size.width;
    NSUInteger heightH = hiddenImage.size.height;
    
    //bytes per row of the shown image
    NSUInteger bytesPerRowS = kBytesPerPixel * widthS;
    //bytes per row of the hidden image
    NSUInteger bytesPerRowH = kBytesPerPixel * widthH;
    
    //amount of pixels in the shown image
    NSUInteger sizeS = widthS * heightS;
    //amount of pixels in the hidden image
    NSUInteger sizeH = widthH * heightH;
    
    //NSLog(@"Size H : %d\n", sizeH);
    //NSLog(@"Size S : %d\n", sizeS);
    //NSLog(@"Bool: %d", sizeS/4 < sizeH);
    
    //amount of pixel bits in the shown image in string format
    NSString* pixelNum = [NSString stringWithFormat:@"%u", sizeH * 4 * 4];
    
    //length of the pixelNum string
    int pixelNumStrLength = [pixelNum length];
    
    //resizes the image to be hidden until its size
    //in pixels is less than a fourth of the size of
    //the shown image's size so that all the pixel info
    //can be saved in the last two bits of the carrier image
    while((sizeS/4 < sizeH + pixelNumStrLength + 2))
    {
        //resizes the hidden image's width and height by 1.2
        CGSize newSize = CGSizeMake(widthH/1.2, heightH/1.2);
    
        //recreates the new hidden image with its new width
        //and height values and updates all relevant variables
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [hiddenImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        hiddenImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        widthH = newSize.width;
        heightH = newSize.height;
    
        sizeH = widthH * heightH;
    
        bytesPerRowH = kBytesPerPixel * widthH;
        
        pixelNum = [NSString stringWithFormat:@"%u", sizeH * 4 * 4];
        
//        NSLog(@"Width H : %d\n", widthH);
//        NSLog(@"Height H : %d\n", heightH);
//        NSLog(@"Size H : %d\n", sizeH);
        
        pixelNumStrLength = [pixelNum length];
    }
    
    //size of hidden image data
    int encodingSize = (sizeH * 4 * 4) + (pixelNumStrLength * 4);
    
    //array to hold the bits of the hidden image
    unsigned char *hideData = (unsigned char*) calloc(encodingSize, sizeof(unsigned char));
    
    //converts the hidden image to bytes to be saved in the carrier image
    hideData = [self convertImagetoBytes:hiddenImage];
    
    // the pixels will be saved to this array
    unsigned char *pixelData = (unsigned char *) calloc(widthS * heightS * 4, sizeof(unsigned char));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with ARGB pixels
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 widthS,
                                                 heightS,
                                                 kBitsPerComponent,
                                                 bytesPerRowS,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Big |
                                                 kCGImageAlphaPremultipliedFirst);
    
    // set the bitmap to our context which will fill in the pixels array
    CGImageRef imageRef = [shownImage CGImage];
    CGContextDrawImage(context, CGRectMake(0, 0, widthS, heightS), imageRef);
    
    //clears the last two bits of the carrier image's argb data
    //and replaces it with the hidden image data bit pairs.
    for(int y = 0; y < heightS && count < encodingSize; y++)
    {
        for(int x = 0; x < widthS && count < encodingSize; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRowS * y) + x * kBytesPerPixel];
            
//            if(count < encodingSize)
//            {
//                printf("%d Pixels BEFORE:\n", count/4);
//                printf("Alpha: %d\n", pixel[ALPHA]);
//                printf("Red: %d\n", pixel[RED]);
//                printf("Green: %d\n", pixel[GREEN]);
//                printf("Blue: %d\n", pixel[BLUE]);
//            }
            
            if(count < encodingSize)
            {
                pixel[ALPHA] = (pixel[ALPHA]/4) * 4 + hideData[count];
                count++;
            }
            
            if(count < encodingSize)
            {
                pixel[RED] = (pixel[RED]/4) * 4 + hideData[count];
                count++;
            }
            
            if(count < encodingSize)
            {
                pixel[GREEN] = (pixel[GREEN]/4) * 4 + hideData[count];
                count++;
            }
            
            if(count < encodingSize)
            {
                pixel[BLUE] = (pixel[BLUE]/4) * 4 + hideData[count];
                count++;
            }
            
//            if(count <= encodingSize)
//            {
//                printf("%d Pixels AFTER:\n", count/4);
//                printf("Alpha: %d\n", pixel[ALPHA]);
//                printf("Red: %d\n", pixel[RED]);
//                printf("Green: %d\n", pixel[GREEN]);
//                printf("Blue: %d\n", pixel[BLUE]);
//                printf("--------------------------------\n");
//            }
        }
    }
//    
//    int y= 0, x = 0;
//    
//    for(int i = 0; i<32; i++)
//    {
//        
//        unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRowS * y) + x * kBytesPerPixel];
//        
//        printf("%d Debug\n", pixel[i+ALPHA]);
//    }
//    
//    printf("\n\n\n");

    
    // create a new CGImageRef from the context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    free(hideData);
    free(pixelData);
    
    //creates a new uiimage from the new image data that holds
    //the hidden information to be returned by the method
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    
//    NSLog(@"Encoding done!");
    
    return resultUIImage;
}


//converts an image to argb byte format for
//splitting the argb bytes into bits to be saved
//in the last two bits of the argb bytes of the carrier image
+ (unsigned char *) convertImagetoBytes: (UIImage *) image
{
    //hidden image size information
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    NSUInteger size = width * height;
    NSUInteger bytesPerRow = kBytesPerPixel * width;
    
    //array to hold hidden image's pixel data
    unsigned char *imageData = (unsigned char*) calloc(width * height * 4, sizeof(unsigned char));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = [image CGImage];
    
    //bitmap context for the image
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                width,
                                                height,
                                                kBitsPerComponent,
                                                bytesPerRow,
                                                colorSpace,
                                                kCGBitmapByteOrder32Big |
                                                kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    int index = 0;
    
    //string format of the width and height
    NSString* widthNum = [NSString stringWithFormat:@"%u", width];
    NSString* heightNum = [NSString stringWithFormat:@"%u", height];
    
    //length of the width string and height string
    int widthNumStrLength = [widthNum length];
    int heightNumStrLength = [heightNum length];
    
    //size of width and height information
    int encodingInfoSize = ((widthNumStrLength + heightNumStrLength) + 2) * 4;
    
    //size of full encoding (argb pixel bits + size info)
    int encodingSize = (size * 4 * 4) + (encodingInfoSize);
    
    //array to hold argb pixel data
    unsigned char *argbData = (unsigned char*) calloc(encodingSize, sizeof(unsigned char));
    
//    NSLog(@"Size: %d", size);
//    
//    NSLog(@"EncodingSize: %d", encodingSize);
    
    //saves the width value by splitting the bytes
    //into 4 pairs of two bits each to be saved in the
    //cleared last two bits of each byte in the
    //carrier image's pixels.
    for (int i=0; i<[widthNum length]; i++)
    {
        unsigned char value = [widthNum characterAtIndex:i];
//        
//        printf("\n--->%c<---\n", value);
//        printf("--->%d<---\n", value);
        
        argbData[index]    = value/64;         //alpha
        argbData[index+1]  = (value%64)/16;    //red
        argbData[index+2]  = (value%16)/4;     //green
        argbData[index+3]  = value%4;          //blue
        
//        printf("%d ", argbData[index]);
//        printf("%d ", argbData[index+1]);
//        printf("%d ", argbData[index+2]);
//        printf("%d ", argbData[index+3]);
//        
//        printf("Index: %d \n", index);
        
        index+=4;
    }
    
    //sets delimeter of width information
    
    argbData[index]    = 0;         //alpha
    argbData[index+1]  = 0;         //red
    argbData[index+2]  = 1;         //green
    argbData[index+3]  = 0;         //blue
    
//    printf("%d ", argbData[index]);
//    printf("%d ", argbData[index+1]);
//    printf("%d ", argbData[index+2]);
//    printf("%d ", argbData[index+3]);
//    
//    printf("Index: %d \n", index);
    
    index+=4;
    
    //saves the height value by splitting the bytes
    //into 4 pairs of two bits each to be saved in the
    //cleared last two bits of each byte in the
    //carrier image's pixels.
    for (int i=0; i<[heightNum length]; i++)
    {
        unsigned char value = [heightNum characterAtIndex:i];
        
//        printf("\n--->%c<---\n", value);
//        printf("--->%d<---\n", value);
//        
        argbData[index]    = value/64;         //alpha
        argbData[index+1]  = (value%64)/16;    //red
        argbData[index+2]  = (value%16)/4;     //green
        argbData[index+3]  = value%4;          //blue
        
//        printf("%d ", argbData[index]);
//        printf("%d ", argbData[index+1]);
//        printf("%d ", argbData[index+2]);
//        printf("%d ", argbData[index+3]);
//        
//        printf("Index: %d \n", index);
        
        index+=4;
    }
    
    //sets delimeter of height information
    
    argbData[index]    = 0;         //alpha
    argbData[index+1]  = 0;         //red
    argbData[index+2]  = 2;         //green
    argbData[index+3]  = 0;          //blue
    
//    printf("%d ", argbData[index]);
//    printf("%d ", argbData[index+1]);
//    printf("%d ", argbData[index+2]);
//    printf("%d ", argbData[index+3]);
//    
//    printf("Index: %d \n", index);
    
    index+=4;
    
    //splits the hidden image bytes into 4
    //pairs of two bits each to be saved in the
    //cleared last two bits of each byte in the
    //carrier image's pixels.
    for (int i=0; i<size * 4; i++)
    {
        unsigned char value = imageData[i];
        
//        printf("--->%d<---\n", value);
        
        argbData[index]    = value/64;         //alpha
        argbData[index+1]  = (value%64)/16;    //red
        argbData[index+2]  = (value%16)/4;     //green
        argbData[index+3]  = value%4;          //blue
        
//        printf("%d ", argbData[index]);
//        printf("%d ", argbData[index+1]);
//        printf("%d ", argbData[index+2]);
//        printf("%d ", argbData[index+3]);
//        
//        printf("Index: %d \n", index);
        
        index+=4;
    }

    free (imageData);
    
    return argbData;
}

@end
