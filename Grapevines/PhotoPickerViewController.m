//
//  PhotoPickerViewController.m
//  iOSPhotoSkeleton
//
//  Skeleton created by Michael MacDougall on 11/29/12.
//
//  Full implementation by Justin Wagner

#import "PhotoPickerViewController.h"
#import "Encode.h"
#import "Decode.h"
#import "Constants.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

@interface PhotoPickerViewController ()

@end

@implementation PhotoPickerViewController

@synthesize imageView, uiImagePicker, customLibrary;

//intializes the photopicker vc with a specified type
- (id)initWithType:(NSString *) type
{
    self = [super init];
    if (self) {
        self.type = type;
        // Custom initialization
    }
    return self;
}

//sets navigation bar title based on type attribute
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if([_type  isEqual: @"encodeImage"])
    {
        [self.navigationItem setTitle:@"Hide an Image"];
    }
    else if([_type  isEqual: @"encodeText"])
    {
        [self.navigationItem setTitle:@"Hide a Message"];
    }
    else if([_type  isEqual: @"decode"])
    {
        [self.navigationItem setTitle:@"Reveal Hidden Item"];
    }
}


//allocates a custom photo library object to be named "Grapvines".
//sets up the uiImagepicker object to choose images to encode or decode.
//displays a keyboard to input text to encode if type attribute is encodeText.
//displays the imagepicker for all other type attributes.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    customLibrary = [[ALAssetsLibrary alloc] init];
    
    uiImagePicker = [[UIImagePickerController alloc]init];
    uiImagePicker.delegate = self;
    uiImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    uiImagePicker.mediaTypes = @[(NSString *) kUTTypeImage,
    (NSString *) kUTTypeMovie];
    
    uiImagePicker.allowsEditing = NO;
    
	// Do any additional setup after loading the view.
    UIImage *background = [UIImage imageNamed:@"stack_of_photos_blue.png"];
    UIImage *backgroundSelected = [UIImage imageNamed:@"stack_of_photos_blue_highlighted.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(fromLibraryButton:) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setBackgroundImage:background forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundSelected forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0,0,30,30);
    
    
    UIBarButtonItem *libraryButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = libraryButton;

    if([_type isEqual: @"encodeText"])
    {
        [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.0];
    }
    else if([_type isEqual: @"encodeImage"])
    {
        [self performSelector:@selector(showImagePicker) withObject:nil afterDelay:0.0];
    }
    else if([_type isEqual: @"decode"])
    {
        [self performSelector:@selector(showImagePicker) withObject:nil afterDelay:0.0];
    }
}

//method call to present the image picker as the current view
-(void)showImagePicker
{
    [self.navigationController presentViewController:uiImagePicker animated:YES completion:nil];
}

//displays an alert view that allows for input of text message for encoding
-(void)showKeyboard
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Input Message"
                                                    message: @"This message will be hidden inside the image."
                                                   delegate: self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    alert.tag = TAG_EncodeText;
    [alert show];
}

//button action to open the photo library again to repick the image
- (IBAction)fromLibraryButton:(id)sender
{
    uiImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    _imageToHide = nil;

    [self showImagePicker];
}

////button action to open camera
//- (IBAction)fromCameraButton:(id)sender;
//{
//    uiImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//    [self showImagePicker];
//}

//action from pressing save button. Allows user to have confirmation of image being saved
- (IBAction)saveButton:(id)sender;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Save Image?"
                                                    message: @"The encoded image will be saved to the Grapevines library."
                                                   delegate: self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    alert.tag = TAG_SaveImage;
    [alert show];
}

//action from pressing save button. Allows user to have confirmation of image being saved
- (IBAction)saveHideButton:(id)sender;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Save Image?"
                                                    message: @"The decoded image will be saved to your photo library."
                                                   delegate: self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    alert.tag = TAG_SaveHideImage;
    [alert show];
}

//displays the image picker for the carrier image in an image in image encode
- (IBAction)carrierImageButton:(id)sender;
{
    [self performSelector:@selector(showImagePicker) withObject:nil afterDelay:0.0];
}

//
- (void)decodeTextAction
{
    NSString* text;
    
    text = [Decode decodeText:_image];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth-screenWidth/1.03, screenHeight-90, screenWidth - (screenWidth-screenWidth/1.03)*2, 60.0)];
    [_textView setEditable:NO];
    [_textView setText:text];
    [_textView setTextColor:[UIColor whiteColor]];
    [_textView setBackgroundColor:[UIColor clearColor]];
    
    [_textView setScrollEnabled:YES];
    
    [self.view addSubview:_textView];
}

//creates the save button to save encoded images
- (void)createSaveButton
{
    _save = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [_save setTitle:@"Save Image" forState:UIControlStateNormal];
    [_save addTarget:self action:@selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
    _save.frame = CGRectMake(screenWidth-screenWidth/1.03, screenHeight-30, screenWidth - (screenWidth-screenWidth/1.03)*2, 30.0);
    _save.tintColor = [UIColor whiteColor];
    _save.backgroundColor = [UIColor purpleColor];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = _save.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:169.0f / 255.0f green:147.0f / 255.0f blue:212.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [_save.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [_save layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
    [self.view addSubview:_save];
}

//creates the save button to save decoded images
- (void)createSaveHideButton
{
    _saveHide = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [_saveHide setTitle:@"Save Image" forState:UIControlStateNormal];
    [_saveHide addTarget:self action:@selector(saveHideButton:) forControlEvents:UIControlEventTouchUpInside];
    _saveHide.frame = CGRectMake(screenWidth-screenWidth/1.03, screenHeight-30, screenWidth - (screenWidth-screenWidth/1.03)*2, 30.0);
    _saveHide.tintColor = [UIColor whiteColor];
    _saveHide.backgroundColor = [UIColor purpleColor];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = _saveHide.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:169.0f / 255.0f green:147.0f / 255.0f blue:212.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [_saveHide.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [_saveHide layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
    [self.view addSubview:_saveHide];
}

//creates the carrier button for choosing the carrier (shown) image in
//an image hidden in image encoding
- (void)createCarrierButton
{
    _carrier = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [_carrier setTitle:@"Carrier Image" forState:UIControlStateNormal];
    [_carrier addTarget:self action:@selector(carrierImageButton:) forControlEvents:UIControlEventTouchUpInside];
    _carrier.frame = CGRectMake(screenWidth-screenWidth/1.03, screenHeight-30, screenWidth - (screenWidth-screenWidth/1.03)*2, 30.0);
    _carrier.tintColor = [UIColor whiteColor];
    _carrier.backgroundColor = [UIColor purpleColor];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = _carrier.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:169.0f / 255.0f green:147.0f / 255.0f blue:212.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [_carrier.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [_carrier layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
    [self.view addSubview:_carrier];
}

//creates the save button to save decoded images
- (void)createGradient
{
    _gradient= [UIButton buttonWithType:UIButtonTypeSystem];
    _gradient.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textView.frame.size.height);
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = _textView.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:169.0f / 255.0f green:147.0f / 255.0f blue:212.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [_gradient.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [_gradient layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    [self.view insertSubview:_gradient belowSubview:_textView];
}

//displays the image picker and calls encoding/decoding methods from Encode and Decode classes
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_textView removeFromSuperview];
    
    BOOL doesContain = [self.view.subviews containsObject:_gradient];
    
    if(doesContain)
    {
        [_gradient removeFromSuperview];
    }
    //determines media type that was selected
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        //sets image to the image selected by the user
        _image = info[UIImagePickerControllerOriginalImage];

        //determines encoding type (image or text) to specify what
        //decoding method to use on the image. If neither type is found
        //sends user back to main screen with error message.
        if([_type isEqual:@"decode"] || [_type isEqual:@"decodeText"] || [_type isEqual:@"decodeImage"])
        {
            BOOL check = [Decode hasHiddenText:_image];
            
            if(check)
            {
                _type = @"decodeText";
            }
            else
            {
                check = [Decode hasHiddenImage:_image];
                
                if(check)
                {
                    _type = @"decodeImage";
                }
                else
                    _type = @"error";
            }
        }
        
        //displays error message and returns user to main screen
        //if no encoded text or image is found.
        if([_type isEqual:@"error"])
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                              message:@"Nothing hidden could be found."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popViewControllerAnimated:YES];
        }
        
        //encodes the chosen image with the message input by the user
        //also creates a save button to save the encoded image
        if([_type isEqual: @"encodeText"])
        {
            BOOL doesContain = [self.view.subviews containsObject:_save];
            
            if(!doesContain)
            {
                [self createSaveButton];
            }
                
            _image = [Encode encodeImage:_image withText:_textField.text];
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Message successfully hidden!"
                                                              message:@"Keep it secret. Keep it safe."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }
        
        //displays first image picker setup for encoding image w/ image
        //the chosen image is set to imageToHide. also creates a carrier
        //button for choosing the carrier image for imageToHide
        if([_type isEqual: @"encodeImage"] && _imageToHide == nil)
        {
            
            _imageToHide = _image;
            
            BOOL doesContain = [self.view.subviews containsObject:_carrier];
            
            if(!doesContain)
            {
                [self createCarrierButton];
            }

        }
        
        //calls method to encode the chosen carrier image with imageToHide
        //removes the carrier button and library button from the view.
        //creates a save button if one is not already in the view
        else if([_type isEqual: @"encodeImage"] && _imageToHide != nil)
        {
            [SVProgressHUD show];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.view setUserInteractionEnabled:NO];
                self.navigationController.navigationBar.userInteractionEnabled = NO;
                _image = [Encode encodeImage:_image withImage:_imageToHide];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view setUserInteractionEnabled:YES];
                    self.navigationController.navigationBar.userInteractionEnabled = YES;
                    [SVProgressHUD dismiss];
                    _imageToHide = nil;
                    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Image successfully hidden!"
                                                                      message:@"Keep it secret. Keep it safe."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                    [message show];

                });
            });
            
            BOOL doesContain = [self.view.subviews containsObject:_save];
            
            if(!doesContain)
            {
                [self createSaveButton];
            }
            
            [_carrier removeFromSuperview];
            [_library removeFromSuperview];
            
        }
        
        //calls the method to decode text and sets the
        //navigation bar title to Hidden Text for the user
        if([_type isEqual:@"decodeText"])
        {
            [self.navigationItem setTitle:@"Hidden Text"];
            
            BOOL doesContain = [self.view.subviews containsObject:_saveHide];
            
            if(doesContain)
            {
                [_saveHide removeFromSuperview];
            }
                
            [self decodeTextAction];

        }
        
        [imageView removeFromSuperview];
        
        //calls the method to reveal a hidden image
        //and sets the title to Hidden Image
        if([_type isEqual: @"decodeImage"])
        {
            [self.navigationItem setTitle:@"Hidden Image"];
            
            BOOL doesContain = [self.view.subviews containsObject:_saveHide];
            
            if(!doesContain)
            {
                [self createSaveHideButton];
            }

            [SVProgressHUD show];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.view setUserInteractionEnabled:NO];
                self.navigationController.navigationBar.userInteractionEnabled = NO;
                _image = [Decode decodeImage:_image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view setUserInteractionEnabled:YES];
                    self.navigationController.navigationBar.userInteractionEnabled = YES;
                    [SVProgressHUD dismiss];
                    [imageView removeFromSuperview];
                    
                    //creates a CGRect frame for holding the imageView
                    CGRect myImageRect = CGRectMake(screenWidth-screenWidth/1.03, screenHeight-screenHeight/1.18, screenWidth - (screenWidth-screenWidth/1.03)*2, screenHeight-150);
                    
                    imageView.image = nil;
                    
                    imageView = [[UIImageView alloc] initWithFrame:myImageRect];
                    
                    imageView.frame = CGRectMake(imageView.frame.origin.x, screenHeight-screenHeight/1.18, imageView.frame.size.width, imageView.frame.size.height);
                    
                    //resizes image to fit in screen display area if too large
                    if (_image.size.width > imageView.frame.size.width || _image.size.height > imageView.frame.size.height)
                    {
                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                    else
                    {
                        imageView.contentMode = UIViewContentModeCenter;
                    }
                    
                    [imageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
                    [imageView.layer setBorderWidth:2.0];
                    imageView.image = _image;
                    
                    CGSize imgSize = _image.size;
                    
                    float ratio2=imageView.frame.size.height/imgSize.height;
                    float scaledWidth=imgSize.width*ratio2;
                    if(scaledWidth < imageView.frame.size.width)
                    {
                        //update height of your imageView frame with scaledWidth
                        
                        imageView.frame = CGRectMake(imageView.frame.origin.x, screenHeight-screenHeight/1.18, scaledWidth, imageView.frame.size.height);
                        
                        self.imageView.center = self.view.center;
                    }
                    
                    //resizes the image's frame to the size of the image
                    float ratio=imageView.frame.size.width/imgSize.width;
                    float scaledHeight=imgSize.height*ratio;
                    if(scaledHeight < imageView.frame.size.height)
                    {
                        //update height of your imageView frame with scaledHeight
                        
                        imageView.frame = CGRectMake(imageView.frame.origin.x, screenHeight-screenHeight/1.18, imageView.frame.size.width, scaledHeight);
                    }
                    
                    // Round imageview corners
                    CALayer *btnLayer = [imageView layer];
                    [btnLayer setMasksToBounds:YES];
                    [btnLayer setCornerRadius:5.0f];
                    
                    [self.view addSubview:imageView];
                    
                    //generates a tap recognizer that allows the user to tap
                    //the picture shown to bring back up the photo picker.
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                             initWithTarget:self action:@selector(fromLibraryButton:)];
                    [tapRecognizer setNumberOfTouchesRequired:1];
                    
                    imageView.userInteractionEnabled = YES;
                    [imageView addGestureRecognizer:tapRecognizer];
                    
                });
            });
        }
        
        if(![_type isEqual: @"decodeImage"])
        {
            //creates a CGRect frame for holding the imageView
            CGRect myImageRect = CGRectMake(screenWidth-screenWidth/1.03, screenHeight-screenHeight/1.18, screenWidth - (screenWidth-screenWidth/1.03)*2, screenHeight-150);
        
            imageView.image = nil;
        
            imageView = [[UIImageView alloc] initWithFrame:myImageRect];
        
            imageView.frame = CGRectMake(imageView.frame.origin.x, screenHeight-screenHeight/1.18, imageView.frame.size.width, imageView.frame.size.height);
        
            //resizes image to fit in screen display area if too large
            if (_image.size.width > imageView.frame.size.width || _image.size.height > imageView.frame.size.height)
            {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            else
            {
                imageView.contentMode = UIViewContentModeCenter;
            }
            
            [imageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
            [imageView.layer setBorderWidth:2.0];
            imageView.image = _image;
        
            CGSize imgSize = _image.size;
        
            float ratio2=imageView.frame.size.height/imgSize.height;
            float scaledWidth=imgSize.width*ratio2;
            if(scaledWidth < imageView.frame.size.width)
            {
                //update height of your imageView frame with scaledWidth
            
                imageView.frame = CGRectMake(imageView.frame.origin.x, screenHeight-screenHeight/1.18, scaledWidth, imageView.frame.size.height);
            
                self.imageView.center = self.view.center;
            }
        
            //resizes the image's frame to the size of the image
            float ratio=imageView.frame.size.width/imgSize.width;
            float scaledHeight=imgSize.height*ratio;
            if(scaledHeight < imageView.frame.size.height)
            {
                //update height of your imageView frame with scaledHeight
            
                imageView.frame = CGRectMake(imageView.frame.origin.x, screenHeight-screenHeight/1.18, imageView.frame.size.width, scaledHeight);
            }
        
            // Round imageview corners
            CALayer *btnLayer = [imageView layer];
            [btnLayer setMasksToBounds:YES];
            [btnLayer setCornerRadius:5.0f];
        
            [self.view addSubview:imageView];
            
            //generates a tap recognizer that allows the user to tap
            //the picture shown to bring back up the photo picker.
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(fromLibraryButton:)];
            [tapRecognizer setNumberOfTouchesRequired:1];
            
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tapRecognizer];
        }
        
        if([_type isEqual:@"decodeText"])
        {
            _textView.frame = CGRectMake(screenWidth-screenWidth/1.03, imageView.frame.origin.y + imageView.frame.size.height + 10, screenWidth - (screenWidth-screenWidth/1.03)*2, screenHeight - (imageView.frame.origin.y + imageView.frame.size.height));
            
            // Round button corners
            CALayer *viewLayer = [_textView layer];
            [viewLayer setMasksToBounds:YES];
            [viewLayer setCornerRadius:5.0f];
            
            // Apply a 1 pixel, black border
            [viewLayer setBorderWidth:1.0f];
            [viewLayer setBorderColor:[[UIColor blackColor] CGColor]];
            
            BOOL doesContain = [self.view.subviews containsObject:_gradient];
            
            if(!doesContain)
            {
                [self createGradient];
            }
        }
    
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Video Unsupported"
                                                          message:@"Videos are unsupported at this point"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//pops the view controller to the main screen if no image was selected
//otherwise it just closes the photopicker
- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    if(_image == nil)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else
    {
        _imageToHide = _image;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//Determines what actions to take when an alert view button is pressed
//Alert views include: Save and EncodeText (keyboard)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Ok button is pressed. generates a png image from the UIimage data
    //This is to prevent loss of information in the alpha values for pixels
    //saves the image to the Grapevines album. Returns the user to the main
    //view controller once the image is saved.
    if (alertView.tag == TAG_SaveImage && buttonIndex == 1)
    {
        NSData* imageData =  UIImagePNGRepresentation(_image);
        UIImage* pngImage = [UIImage imageWithData:imageData];
        
        [customLibrary saveImage:pngImage toAlbum:@"Grapevines" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
        }];
        
        [[self navigationController] popViewControllerAnimated:NO];
    }
    
    //saves a decoded image to user's normal photo library
    else if (alertView.tag == TAG_SaveHideImage && buttonIndex == 1)
    {
        NSData* imageData =  UIImagePNGRepresentation(_image);
        UIImage* pngImage = [UIImage imageWithData:imageData];
        
        UIImageWriteToSavedPhotosAlbum(pngImage, nil, nil, nil);
        
        [[self navigationController] popViewControllerAnimated:NO];
    }
    //Ok button is pressed on message input alert
    //returns user to main view controller if input is null
    //displays image picker if input text was valid
    else if (alertView.tag == TAG_EncodeText && buttonIndex == 1)
    {
        _textField = [alertView textFieldAtIndex:0];
        
        if([_textField.text isEqual:@""])
        {
            [[self navigationController] popViewControllerAnimated:NO];
        }
        else
        {
            [self performSelector:@selector(showImagePicker) withObject:nil afterDelay:0.0];
        }
    }
    
    //cancel button pressed. pop to main view controller
    else if (alertView.tag == TAG_EncodeText && buttonIndex == 0)
    {
        [[self navigationController] popViewControllerAnimated:NO];
    }
}

//overrides navigation bar titles and back bar button titles
//based on encoding/decoding type
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([_type isEqual: @"encodeImage"] && _imageToHide == nil)
    {
        [viewController.navigationItem setTitle:@"Image to Hide"];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

        [viewController.navigationItem setBackBarButtonItem: backButton];
        
    }
    if([_type isEqual: @"encodeImage"] && _imageToHide != nil)
    {
        [viewController.navigationItem setTitle:@"Carrier Image"];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        [viewController.navigationItem setBackBarButtonItem: backButton];
    }
    if([_type isEqual: @"encodeText"])
    {
        [viewController.navigationItem setTitle:@"Carrier Image"];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        [viewController.navigationItem setBackBarButtonItem: backButton];
    }
}

//sets customlibrary to null when the
//photopicker vc is unloaded
- (void)viewDidUnload
{
    customLibrary = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
