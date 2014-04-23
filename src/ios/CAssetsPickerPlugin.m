//
//  CAssetsPickerPlugin.m
//  AssetsPlugin
//
//  Created by Donald Pae on 4/22/14.
//
//

#import "CAssetsPickerPlugin.h"

@implementation CAssetsPickerPlugin {
    int quality;
    DestinationType destType;
    EncodingType encodeType;
}

- (void)getPicture:(CDVInvokedUrlCommand *)command
{
    // Set the hasPendingOperation field to prevent the webview from crashing
	self.hasPendingOperation = YES;
    
	// Save the CDVInvokedUrlCommand as a property.  We will need it later.
	self.latestCommand = command;
    
    self.picker = [[CTAssetsPickerController alloc] init];
    self.picker.assetsFilter         = [ALAssetsFilter allAssets];
    self.picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    self.picker.delegate             = self;
    
    // default values
    quality = 75;
    destType = DestinationTypeFileURI;
    encodeType = EncodingTypeJPEG;
    
    // get parameters from argument.
    if (command.arguments.count >= 1)
    {
        NSDictionary *jsonData = [command.arguments objectAtIndex:0];
        
        // quaility
        NSString *obj = [jsonData objectForKey:@"quality"];
        if (obj != nil)
            quality = [obj intValue];
        
        // destination type
        obj = [jsonData objectForKey:@"destinationType"];
        if (obj != nil)
        {
            int destinationType = [obj intValue];
            NSLog(@"destinationType = %d", destinationType);
            destType = destinationType;
        }
        
        // encoding type
        obj = [jsonData objectForKey:@"encodingType"];
        if (obj != nil)
        {
            int encodingType = [obj intValue];
            encodeType = encodingType;
        }
        
        // selected assets
        NSArray *selectedAssetObjs = [jsonData objectForKey:@"selectedAssets"];
        if (selectedAssetObjs != nil)
            self.picker.selectedAssetObjs = [[NSMutableArray alloc] initWithArray:selectedAssetObjs];
    }
    //self.picker.selectedAssets       = [NSMutableArray arrayWithArray:selectedAssets];
    
    // iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.picker];
        self.popover.delegate = self;
        
        [self.popover presentPopoverFromRect:self.viewController.view.frame inView:self.viewController.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    }
    else
    {
        [self.viewController presentViewController:self.picker animated:YES completion:nil];
    }
    
    
}
#pragma mark - Assets Picker Delegate

/**
 *  the user finish picking photos or videos.
 *
 *  @param picker The controller object managing the assets picker interface.
 *  @param assets An array containing picked `ALAsset` objects.
 */
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (self.popover != nil)
        [self.popover dismissPopoverAnimated:YES];
    else
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    // Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;
    
    CDVPluginResult *pluginResult = nil;
    NSString *resultJS = nil;
    
    // make array of return objects
    // { id : asset's url,
    //   data : asset's data }
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < assets.count; i++)
    {
        ALAsset *asset = [assets objectAtIndex:i];
        
        NSMutableDictionary* retValues = [NSMutableDictionary dictionaryWithCapacity:2];
        NSString *strUrl = [NSString stringWithFormat:@"%@", [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] ];
        [retValues setObject:strUrl forKey:@"id"];
        if (destType == DestinationTypeDataURL) {
            NSString *strEncoded = @"";
            NSData *data = nil;
            if (encodeType == EncodingTypeJPEG)
                //data = UIImageJPEGRepresentation([UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]], quality / 100.0f);
                data = UIImageJPEGRepresentation([UIImage imageWithCGImage:asset.thumbnail], quality / 100.0f);
            else
                //data = UIImagePNGRepresentation([UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]]);
                data = UIImagePNGRepresentation([UIImage imageWithCGImage:asset.thumbnail]);
            strEncoded = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            [retValues setObject:strEncoded forKey:@"data"];
        }
        else {
            [retValues setObject:[asset valueForProperty:ALAssetPropertyAssetURL] forKey:@"data"];
        }
        
        [retArray addObject:retValues];
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:retArray];
    resultJS = [pluginResult toSuccessCallbackString:self.latestCommand.callbackId];
    [self writeJavascript:resultJS];
}


/**
 *  the user cancelled the pick operation.
 *
 *  @param picker The controller object managing the assets picker interface.
 */
- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    // Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;

    
    CDVPluginResult *pluginResult = nil;
    NSString *resultJS = nil;
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Canceled!"];
    resultJS = [pluginResult toErrorCallbackString:self.latestCommand.callbackId];
    [self writeJavascript:resultJS];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAssetForSelection:(ALAsset *)asset
{
    // disable video clips
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        // Enable video clips if they are at least 5s
        //NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        //return lround(duration) >= 5;
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    /*
    if (picker.selectedAssets.count >= 10)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Please select not more than 10 assets"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
     */
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    //return (picker.selectedAssets.count < 10 && asset.defaultRepresentation != nil);
    return (asset.defaultRepresentation != nil);
     
    return YES;
}

#pragma mark - Popover Controller Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}
@end
