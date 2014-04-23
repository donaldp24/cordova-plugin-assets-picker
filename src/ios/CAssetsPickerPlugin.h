//
//  CAssetsPickerPlugin.h
//  AssetsPlugin
//
//  Created by Donald Pae on 4/22/14.
//
//

#import <Cordova/CDVPlugin.h>
#import "CTAssetsPickerController.h"

typedef enum {
    DestinationTypeDataURL = 0,
    DestinationTypeFileURI = 1
}DestinationType;

typedef enum {
    EncodingTypeJPEG = 0,
    EncodingTypePNG = 1
}EncodingType;

@interface CAssetsPickerPlugin : CDVPlugin <UINavigationControllerDelegate, CTAssetsPickerControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) CTAssetsPickerController *picker;
@property (strong, nonatomic) CDVInvokedUrlCommand* latestCommand;
@property (readwrite, assign) BOOL hasPendingOperation;
@property (nonatomic, strong) UIPopoverController *popover;

- (void)getPicture:(CDVInvokedUrlCommand *)command;

@end
