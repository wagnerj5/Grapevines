//
//  InfoViewController.m
//  Grapevines
//
//  Created by Justin Wagner on 4/10/14.
//  Copyright (c) 2014 Justin Wagner. All rights reserved.
//

#import "InfoViewController.h"

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [self.navigationItem setTitle:@"Grapevines"];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self showInfo];
}

//creates the texview to display info about the app to the user
- (void)showInfo
{
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth-screenWidth+20, screenHeight-screenHeight+20, screenWidth-40, screenHeight-40)];
    
    [_textView setEditable:NO];
    [_textView setTextColor:[UIColor colorWithRed:80.0f / 255.0f green:52.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f]];
    [_textView setBackgroundColor:[UIColor clearColor]];
    
    NSString* text = @"GRAPEVINES\nDeveloper: Justin Wagner\nMentor: Dr. Andrea Salgian\n\n\nThird Party Libraries:\n\nALAssetsLibrary+CustomPhotoAlbum library:\n\nhttp://www.touch-code-magazine.com/ios5-saving-photos-in-custom-photo-album-category-for-download/\n\nSVProgressHUD library:\n\nhttps://github.com/samvermette/SVProgressHUD\n\n\nSpecial thanks to Mike MacDougall for use of his PhotoPicker skeleton class\n\n";
    
    [_textView setText:text];
    
    [self.view addSubview:_textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
