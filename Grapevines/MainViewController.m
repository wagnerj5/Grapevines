//
//  MainViewController.m
//  Grapevines
//
//  Created by Justin Wagner on 2/10/14.
//  Copyright (c) 2014 Justin Wagner. All rights reserved.
//
//  Main view controller that is displayed on app startup. Has a Hide and a Reveal button
//  for encoding and decoding hidden images and messages respectively. Pressing the Hide
//  button displays an alert view asking whether the user is hiding an image or a message.
//  The Reveal action automatically detects what hidden item is within the chosen image.
//  By clicking on one of the buttons, the MainViewController pushes a "type" attribute
//  to the Photopickerviewcontroller to determine which encoding or decoding function
//  should be used.
//
//

#import "MainViewController.h"
#import "PhotoPickerViewController.h"
#import "Constants.h"
#import "InfoViewController.h"

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

//Hides navigation bar.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //sets background color to clear to show background.png image
    self.view.backgroundColor = [UIColor clearColor];
    
    //calls methods to create and display the Hide and Reveal Buttons
    [self createEncodeButton];
    [self createDecodeButton];
    [self createInfoButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//creates a button that opens the info view controller which displays info about the app
- (void)createInfoButton
{
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    [info addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    float X_Co = screenWidth-30;
    float Y_Co = screenHeight-10;
    info.frame = CGRectMake(X_Co, Y_Co, 15.0, 15.0);
    info.tintColor = [UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f];
    [self.view addSubview:info];
}

//creates a purple Hide button in top center of screen
- (void)createEncodeButton
{
    UIButton *encode = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [encode setTitle:@"  Hide  " forState:UIControlStateNormal];
    [encode addTarget:self action:@selector(encodeApp) forControlEvents:UIControlEventTouchUpInside];
    float X_Co = (self.view.frame.size.width - 40.0)/4;
    encode.frame = CGRectMake(X_Co, screenHeight/3.25, 160.0, 40.0);
    UIFont *font = [UIFont fontWithName:@"Zapfino" size:24];
    [encode.titleLabel setFont:font];
    encode.tintColor = [UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f];
    [encode setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [self.view addSubview:encode];
    
}

//creates a purple Reveal button in bottom center of screen
- (void)createDecodeButton
{
    UIButton *decode = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [decode setTitle:@"  Reveal  " forState:UIControlStateNormal];
    [decode addTarget:self action:@selector(decodeApp) forControlEvents:UIControlEventTouchUpInside];
    float X_Co = (self.view.frame.size.width - 40.0)/4;
    decode.frame = CGRectMake(X_Co, screenHeight - screenHeight/3.25, 160.0, 40.0);
    UIFont *font = [UIFont fontWithName:@"Zapfino" size:24];
    [decode.titleLabel setFont:font];
    decode.tintColor = [UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f];
    [decode setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [self.view addSubview:decode];
    
}

- (void)showInfo
{
    InfoViewController* vc = [[InfoViewController alloc] init];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

//method called when Hide button is pressed. Displays an alert asking for the
//typing of encoding to be done: Image or Text. Sends a "type" attribute with
//the pushed photopickerviewcontroller to determine encoding function.
- (void)encodeApp
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Hide text or image?"
                                                    message: @""
                                                   delegate: self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Image", @"Text", nil];
    alert.tag = TAG_Encode;
    [alert show];
}

//method called when Reveal button is pressed. Sends "decode" as the type. Exact
//decoding type is determined in photopicker vc.
- (void)decodeApp
{
    PhotoPickerViewController* vc = [[PhotoPickerViewController alloc] initWithType:@"decode"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

//Determines what actions to take depending upon which button is pressed on
//the displayed alert view for pressing the Hide Button. 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_Encode && buttonIndex == 1)
    {
        PhotoPickerViewController* vc = [[PhotoPickerViewController alloc] initWithType:@"encodeImage"];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else if (alertView.tag == TAG_Encode && buttonIndex == 2)
    {
        PhotoPickerViewController* vc = [[PhotoPickerViewController alloc] initWithType:@"encodeText"];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }
}


@end
