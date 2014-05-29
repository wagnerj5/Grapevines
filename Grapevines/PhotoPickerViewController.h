//
//  PhotoPickerViewController.h
//  iOSPhotoSkeleton
//
//  Skeleton created by Michael MacDougall on 11/29/12.
//
//  Full implementation by Justin Wagner

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoPickerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

//overridden intialization
- (id)initWithType:(NSString *) type;

//type property to determine encoding/decoding type
@property (strong, nonatomic) NSString *type;

//UIimages to hold images being worked with for encode and decode
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *imageToHide;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIImagePickerController *uiImagePicker;

//textfield and view for displaying decoded text
@property (nonatomic) UITextField *textField;
@property (nonatomic) UITextView *textView;

//sets up global uibuttons so they can be removed from
//the view more simply.
@property (nonatomic) UIButton *carrier;
@property (nonatomic) UIButton *save;
@property (nonatomic) UIButton *saveHide;
@property (nonatomic) UIButton *library;

@property (nonatomic) UIButton *gradient;

//custom photo album property
@property (strong, atomic) ALAssetsLibrary* customLibrary;

- (IBAction)fromLibraryButton:(id)sender;
//- (IBAction)fromCameraButton:(id)sender;

@end
