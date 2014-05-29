//
//  Decode.m
//  Grapevines
//
//  Created by Justin Wagner on 2/27/14.
//  Copyright (c) 2014 Justin Wagner. All rights reserved.
//

#import "Decode.h"
#import "Constants.h"

@implementation Decode

//DECODE IMAGE
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//extracts the pixel bits of a hidden image from a carrier image
//and recreates that image to then be returned by the function
+ (UIImage *) decodeImage:(UIImage *) inImage
{
    int count = 0, index = 0, heightIndex = 0, widthIndex = 0;
    int widthLength = 0, heightLength = 0, widthLengthInt = 0, heightLengthInt = 0;
    
    bool end = false, firstCheck = false;
    
    //width and height of carrier image
    NSUInteger width = inImage.size.width;
    NSUInteger height = inImage.size.height;
    
    //designates the bytes in each row of the image
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
    
    //array for holding the pixel bits to check against for width and height values
    //use of width for size is arbitrary.
    unsigned char *lengthCheckArray = (unsigned char *) calloc(width, sizeof(unsigned char));
    
    //byte arrays to eventually hold the width and height values of the image
    //array will be converted to string and then to an int value.
    unsigned char *widthHoldArray = (unsigned char *) calloc(width, sizeof(unsigned char));
    unsigned char *heightHoldArray = (unsigned char *) calloc(width, sizeof(unsigned char));
    
//    int y= 0, x = 0;
//    
//    for(int i = 0; i<32; i++)
//    {
//        
//        unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];
//        
//        printf("%d Debug\n", pixel[i]);
//    }
    

    //initial iteration through pixel data of the encoded image to extract
    //the width and height values of the image. loop ends when the value 8
    //is found in the pixel bits (00001000 or 0020) which is set during encode to deliminate
    //the width and height from the actual data of the hidden image/text
    for(int y = 0; !end; y++)
    {
        for(int x = 0; !end; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];
            
            //extracts the last two bits of each pixel's A, R, G, and B values and
            //saves them in the lengthcheckarray
            
            if(!end)
            {
                
                lengthCheckArray[ALPHA] = pixel[ALPHA]%4;
            }
            
            if(!end)
            {
                
                lengthCheckArray[RED] = pixel[RED]%4;
                
            }
            
            if(!end)
            {
                
                lengthCheckArray[GREEN] = pixel[GREEN]%4;
            }
            
            if(!end)
            {
                
                lengthCheckArray[BLUE] = pixel[BLUE]%4;
            }
            
            //combines the values of the ARGB bits to extract the width and height info
            if(!end)
            {
                //converts byte info to usuable int value for boolean checks
                unsigned char check = ((lengthCheckArray[ALPHA] * 4 + lengthCheckArray[RED]) * 4 + lengthCheckArray[GREEN]) * 4 + lengthCheckArray[BLUE];
                
                //extracts and transforms bytes in width array to a usuable integer value
                //once the delimiter of 4 (00000100 or 0010) is hit
                if(check == 4)
                {
                    widthLength = strlen((char *) widthHoldArray);
                    
                    NSString* widthLengthStr = [[NSString alloc] initWithBytes:widthHoldArray length:widthLength encoding:NSASCIIStringEncoding];
                    
                    widthLengthInt = [widthLengthStr intValue];
                    
                    firstCheck = true;
                }
                
                //extracts and transforms bytes in height array to a
                //usuable integer value once the delimiter of 8 is hit
                else if(check == 8)
                {
                    heightLength = strlen((char *) heightHoldArray);
                    
                    NSString* heightLengthStr = [[NSString alloc] initWithBytes:heightHoldArray length:heightLength encoding:NSASCIIStringEncoding];
                    
                    heightLengthInt = [heightLengthStr intValue];
                    
                    end = true;
                }
                
                //adds bytes to widthHoldArray
                else if (!firstCheck)
                {
                    widthHoldArray[widthIndex] = ((lengthCheckArray[ALPHA] * 4 + lengthCheckArray[RED]) * 4 + lengthCheckArray[GREEN]) * 4 + lengthCheckArray[BLUE];
                    
                    widthIndex++;
                }
                
                //adds bytes to heightHoldArray
                else if (firstCheck)
                {
                    heightHoldArray[heightIndex] = ((lengthCheckArray[ALPHA] * 4 + lengthCheckArray[RED]) * 4 + lengthCheckArray[GREEN]) * 4 + lengthCheckArray[BLUE];
                    
                    heightIndex++;
                }
                
                index = heightIndex + widthIndex;
            }
        }
    }
    
    //determines the length of the info for the width and the height of the image
    int lengthArrayLength = strlen((char *) widthHoldArray) + strlen((char *) heightHoldArray);
    
    //determines the total amount of pairs of pixel bits in the hidden image
    int lengthInt = (widthLengthInt * heightLengthInt * 4) + index + 2;
    
    index = 0;
    int cindex = 0; //char array index for pixelArray data (hidden image)
    
    free(lengthCheckArray);
    free(widthHoldArray);
    free(heightHoldArray);
    
    //array to hold argb bytes from each pixel
    unsigned char *argbArray = (unsigned char *) calloc(lengthInt * 4, sizeof(unsigned char));
    
    //array to hold the pixel bits for the hidden image
    unsigned char *pixelArray = (unsigned char *) calloc(lengthInt, sizeof(unsigned char));
    
    for(int y = 0; y < height && count < lengthInt * 4; y++)
    {
        for(int x = 0; x < width && count < lengthInt * 4; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];
            
            //extracts the last two bits of each pixel's A, R, G, and B values and
            //saves them in the argbarray
            
            if(count < lengthInt * 4)
            {
                argbArray[ALPHA] = pixel[ALPHA]%4;
                count++;
            }
            
            if(count < lengthInt * 4)
            {
                argbArray[RED] = pixel[RED]%4;
                count++;
            }
            
            if(count < lengthInt * 4)
            {
                argbArray[GREEN] = pixel[GREEN]%4;
                count++;
            }
            
            if(count < lengthInt * 4)
            {
                argbArray[BLUE] = pixel[BLUE]%4;
                count++;
            }
            
            //generates an array of pixel bits of the hidden image after passing over
            //the pixel bits in the source that held the width and height values
            if(count <= lengthInt * 4 && index > lengthArrayLength + 1)
            {
                
                pixelArray[cindex] = ((argbArray[ALPHA] * 4 + argbArray[RED]) * 4 + argbArray[GREEN]) * 4 + argbArray[BLUE];
                
                cindex++;
            }
            else
                index++;
        }
    }
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //creates a new bitmap context that generates the hidden image
    //and saves it as a new uiimage which is then returned by the function
    
    width = widthLengthInt;
    height = heightLengthInt-2;
    
    bytesPerRow = width * kBytesPerPixel;
    
//    NSLog(@"width: %d\n", width);
//    NSLog(@"height: %d\n", height);
    
    CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(pixelArray,
                                                width,
                                                height,
                                                kBitsPerComponent,
                                                bytesPerRow,
                                                cs,
                                                kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(cs);
    
    
    CGImageRef cgImage=CGBitmapContextCreateImage(bitmap);
    CGContextRelease(bitmap);
    
    UIImage * newimage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    free(pixelData);
    free(argbArray);
    free(pixelArray);
    
//    NSLog(@"Decoding done!");
    
    return newimage;
}

//DECODE TEXT
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//extracts the bits that hold a hidden message from a carrier image
//and then recreates that text string from those bits, which is then returned
+ (NSString *) decodeText:(UIImage *) inImage
{
    int count = 0, index = 0;
    
    bool end = false;
    
    //width and height of carrier image
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
    
    //array for holding each byte of the saved text length information to check for the delimeter
    //between that info and the actual text message's bits
    unsigned char *lengthCheckArray = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    
    //holds the length of the text string to be transformed into a useable integer
    unsigned char *lengthHoldArray = (unsigned char *) calloc(height * width, sizeof(unsigned char));
    
    //initial iteration through the pixel bits of the carrier image to extract
    //the message's length saved in the beginning pixels. Stops when it finds the
    //delimeter of 3 (0003 or 00000011)
    for(int y = 0; !end; y++)
    {
        for(int x = 0; !end; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];

            if(!end)
            {
                lengthCheckArray[ALPHA] = pixel[ALPHA]%4;
            }
            
            if(!end)
            {
                lengthCheckArray[RED] = pixel[RED]%4;
            }
            
            if(!end)
            {
                lengthCheckArray[GREEN] = pixel[GREEN]%4;
            }
            
            if(!end)
            {
                lengthCheckArray[BLUE] = pixel[BLUE]%4;
            }

            if(!end)
            {
                lengthHoldArray[index] = ((lengthCheckArray[ALPHA] * 4 + lengthCheckArray[RED]) * 4 + lengthCheckArray[GREEN]) * 4 + lengthCheckArray[BLUE];
                
                if(lengthHoldArray[index] == 3)
                {
                    end = true;
                }
                else
                    index++;
            }
        }
    }
    
    index = 0;
    int cindex = 0; //char array index
    
    //length of the array holding the bits of information
    //designating the length of the text string
    int lengthArrayLength = strlen((char *) lengthHoldArray);
    
    //transforms the bits of the length of the text string into a string
    //of length
    NSString* inTextLength = [[NSString alloc] initWithBytes:lengthHoldArray length:lengthArrayLength-1 encoding:NSASCIIStringEncoding];
    
    //generates the integer value holding the length of the text string
    int intInTextLength = [inTextLength intValue] + lengthArrayLength;
    
    free(lengthCheckArray);
    free(lengthHoldArray);
    
    //holds the bits decoded from the image's argb values
    unsigned char *argbArray = (unsigned char *) calloc(intInTextLength * 4, sizeof(unsigned char));
    
    //holds the bytes of the hidden text string from combining the extracted bit pairs into bytes
    unsigned char *charArray = (unsigned char *) calloc(intInTextLength, sizeof(unsigned char));
    
    //iterates through the carrier image's pixel bits and starts to extract and combine the hidden
    //bits from each ARGB pixel into the bytes of the hidden text string. Skips over the saved text string
    //length information bits at the beginning.
    for(int y = 0; y < height && count < intInTextLength * 4; y++)
    {
        for(int x = 0; x < width && count < intInTextLength * 4; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];
            
            
            if(count < intInTextLength * 4)
            {
                argbArray[ALPHA] = pixel[ALPHA]%4;
                count++;
            }
            
            if(count < intInTextLength * 4)
            {
                argbArray[RED] = pixel[RED]%4;
                count++;
            }
            
            if(count < intInTextLength * 4)
            {
                argbArray[GREEN] = pixel[GREEN]%4;
                count++;
            }
            
            if(count < intInTextLength * 4)
            {
                argbArray[BLUE] = pixel[BLUE]%4;
                count++;
            }
            
            if(count <= intInTextLength * 4 && index >= lengthArrayLength)
            {

                charArray[cindex] = ((argbArray[ALPHA] * 4 + argbArray[RED]) * 4 + argbArray[GREEN]) * 4 + argbArray[BLUE];
                
                cindex++;
            }
            else
                index++;
        }
    }
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //gets the length of the array holding all the text string's character bytes
    int arrayLength = strlen((char *) charArray);
    
    //recreates the message into a useable string from the character bytes of the charArray
    //and then returns it for the method
    NSString* outText = [[NSString alloc] initWithBytes:charArray length:arrayLength encoding:NSASCIIStringEncoding];
    
    free(pixelData);
    free(argbArray);
    free(charArray);
    
    return outText;
}

//checks to see if the carrier image has hidden text
//returns true if the delimeter for hidden text is found
//returns false if it is not found
+ (BOOL) hasHiddenText:(UIImage *) inImage
{
    BOOL hasHiddenText, end = false;
    int checkCount = 0;
    
    //width and height of carrier
    NSUInteger width = inImage.size.width;
    NSUInteger height = inImage.size.height;
    
    //bytes per row in the image
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
    
    unsigned char *checkArray = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    
    //loops until a recreated byte has been found the equal 3 or 4,
    //which are the delimeters for the length information of
    //hidden text and hidden images respectively
    for(int y = 0; !end; y++)
    {
        for(int x = 0; !end; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];
            
            //takes last two bits from A,R,G, and B values to recreate byte
            checkArray[ALPHA] = pixel[ALPHA]%4;
            checkArray[RED] = pixel[RED]%4;
            checkArray[GREEN] = pixel[GREEN]%4;
            checkArray[BLUE] = pixel[BLUE]%4;
            
            unsigned char check = ((checkArray[ALPHA] * 4 + checkArray[RED]) * 4 + checkArray[GREEN]) * 4 + checkArray[BLUE];
            
            checkCount++;
            
            //checks if byte is equal to 3 (delimeter for text message)
            if(check == 3)
            {
                end = true;
                
                hasHiddenText = true;
            }
            
            if(checkCount > 40)
            {
                end = true;
                
                hasHiddenText = false;
            }
        }
    }
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelData);
    free(checkArray);
    
    return hasHiddenText;
}

+ (BOOL) hasHiddenImage:(UIImage *) inImage
{
    BOOL hasHiddenImage, end = false;
    int checkCount = 0;
    
    //width and height of carrier
    NSUInteger width = inImage.size.width;
    NSUInteger height = inImage.size.height;
    
    //bytes per row in the image
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
    
    unsigned char *checkArray = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    
    //loops until a recreated byte has been found the equal 3 or 4,
    //which are the delimeters for the length information of
    //hidden text and hidden images respectively
    for(int y = 0; !end; y++)
    {
        for(int x = 0; !end; x++)
        {
            unsigned char *pixel = (unsigned char *) &pixelData[(bytesPerRow * y) + x * kBytesPerPixel];
            
            //takes last two bits from A,R,G, and B values to recreate byte
            checkArray[ALPHA] = pixel[ALPHA]%4;
            checkArray[RED] = pixel[RED]%4;
            checkArray[GREEN] = pixel[GREEN]%4;
            checkArray[BLUE] = pixel[BLUE]%4;
            
            unsigned char check = ((checkArray[ALPHA] * 4 + checkArray[RED]) * 4 + checkArray[GREEN]) * 4 + checkArray[BLUE];
            
            checkCount++;
            
            //checks if byte is equal to 3 (delimeter for text message)
            if(check == 4)
            {
                end = true;
                
                hasHiddenImage = true;
            }
            
            if(checkCount > 40)
            {
                end = true;
                
                hasHiddenImage = false;
            }
        }
    }
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelData);
    free(checkArray);
    
    return hasHiddenImage;
}


@end
