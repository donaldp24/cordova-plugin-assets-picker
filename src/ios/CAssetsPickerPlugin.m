//
//  CAssetsPickerPlugin.m
//  AssetsPlugin
//
//  Created by Donald Pae on 4/22/14.
//
//

#import "CAssetsPickerPlugin.h"


@implementation CAssetsPickerPlugin {
    int _quality;
    DestinationType _destType;
    EncodingType _encodeType;
    NSDictionary *_overlays;
    NSDictionary *_overlayIcons;
    NSURL *_assetURL;
    int _targetWidth;
    int _targetHeight;
}


#pragma  mark - Interfaces

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
    
    [self initOptions];
    if ([command.arguments count]> 0)
    {
        NSDictionary *jsonData = [command.arguments objectAtIndex:0];
        [self getOptions:jsonData];
    }
    
    // set selected assets
    NSArray *selectedAssetObjs = [_overlays objectForKey:kPreviousSelectedName];
    if (selectedAssetObjs != nil)
        self.picker.selectedAssetObjs = [[NSMutableArray alloc] initWithArray:selectedAssetObjs];
    else
        self.picker.selectedAssetObjs  = [[NSMutableArray alloc] init];
    
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

- (void)getById:(CDVInvokedUrlCommand *)command
{
    self.hasPendingOperation = YES;
    
    self.latestCommand = command;
    
    [self initOptions];
    if ([command.arguments count] > 1)
    {
        // get id
        NSString *url = [command.arguments objectAtIndex:0];
        if (url != nil)
            _assetURL = [NSURL URLWithString:url];

        // get options
        NSDictionary *jsonData = [command.arguments objectAtIndex:1];
        [self getOptions:jsonData];
        
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:_assetURL resultBlock:^(ALAsset *asset) {
        
        // Unset the self.hasPendingOperation property
        self.hasPendingOperation = NO;
        
        CDVPluginResult *pluginResult = nil;
        NSString *resultJS = nil;
        
        NSDictionary *retValues = [self objectFromAsset:asset fromThumbnail:NO];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:retValues];
        resultJS = [pluginResult toSuccessCallbackString:command.callbackId];
        [self writeJavascript:resultJS];
        
        //
    } failureBlock:^(NSError *error) {
        
        // Unset the self.hasPendingOperation property
        self.hasPendingOperation = NO;
        
        CDVPluginResult *pluginResult = nil;
        NSString *resultJS = nil;
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        
        resultJS = [pluginResult toErrorCallbackString:command.callbackId];
        [self writeJavascript:resultJS];
        
    }];
}


#pragma mark - Utility Functions

- (void)initOptions
{
    // default values
    _quality = 75;
    _destType = DestinationTypeFileURI;
    _encodeType = EncodingTypeJPEG;
    _overlayIcons = [[NSMutableDictionary alloc] init];
    _overlays = [[NSMutableDictionary alloc] init];
    _targetWidth = -1;
    _targetHeight = -1;
}

- (void)getOptions: (NSDictionary *)jsonData
{
    // get parameters from argument.
 
    // quaility
    NSString *obj = [jsonData objectForKey:kQualityKey];
    if (obj != nil)
        _quality = [obj intValue];
    
    // destination type
    obj = [jsonData objectForKey:kDestinationTypeKey];
    if (obj != nil)
    {
        int destinationType = [obj intValue];
        NSLog(@"destinationType = %d", destinationType);
        _destType = destinationType;
    }
    
    // encoding type
    obj = [jsonData objectForKey:kEncodingTypeKey];
    if (obj != nil)
    {
        int encodingType = [obj intValue];
        _encodeType = encodingType;
    }
    
    // target width
    obj = [jsonData objectForKey:kTargetWidth];
    if (obj != nil)
    {
        _targetWidth = [obj intValue];
    }
    
    // target height
    obj = [jsonData objectForKey:kTargetHeight];
    if (obj != nil)
    {
        _targetHeight = [obj intValue];
    }
    
    // overlay
    NSDictionary *overlay = [jsonData objectForKey:kOverlayKey];
    if (overlay != nil)
    {
        NSArray *keys = [overlay allKeys];
        for (int i = 0; i < [keys count]; i++) {
            NSString *key = [keys objectAtIndex:i];
            NSArray *value = [overlay objectForKey:key];
            // for debug
            /*
            for (int j = 0; j < [value count]; j++)
            {
                NSString *url = [value objectAtIndex:j];
                url = url;
            }
             */
            [_overlays setValue:value forKey:key];
        }
    }
    
}

- (NSDictionary *)objectFromAsset:(ALAsset *)asset fromThumbnail:(BOOL)fromThumbnail
{
    NSMutableDictionary* retValues = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString *strUrl = [NSString stringWithFormat:@"%@", [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] ];
    // obj.id
    [retValues setObject:strUrl forKey:@"id"];
    
    // obj.data
    if (_destType == DestinationTypeDataURL) {
        NSString *strEncoded = @"";
        NSData *data = nil;
        
        UIImage *image = nil;
        if (fromThumbnail)
            image = [UIImage imageWithCGImage:asset.thumbnail];
        else
            image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
        
        if (_targetWidth <= 0 && _targetHeight <= 0)
        {
            image = image;
        }
        else if (_targetWidth <= 0)
        {
            CGFloat scale = _targetHeight / image.size.height;
            image = [CAssetsPickerPlugin scaleImage:image scale:scale];
        }
        else if (_targetHeight <= 0)
        {
            CGFloat scale = _targetWidth / image.size.width;
            image = [CAssetsPickerPlugin scaleImage:image scale:scale];
        }
        else
        {
            CGFloat scaleX = _targetWidth / image.size.width;
            CGFloat scaleY = _targetHeight / image.size.height;
            
            CGFloat scale = scaleX;
            if (scaleX > scaleY)
            {
                scale = scaleY;
            }
            image = [CAssetsPickerPlugin scaleImage:image scale:scale];
        }
        
        if (_encodeType == EncodingTypeJPEG)
        {
            data = UIImageJPEGRepresentation(image, _quality / 100.0f);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        strEncoded = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        [retValues setObject:strEncoded forKey:@"data"];
    }
    else {
        //[retValues setObject:[asset valueForProperty:ALAssetPropertyAssetURL] forKey:@"data"];
        [retValues setObject:strUrl forKey:@"data"];
    }
    
    // obj.exif
    NSMutableDictionary *exif = [NSMutableDictionary dictionaryWithCapacity:4];
    
    // obj.exif.DateTimeOriginal
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    if (date != nil)
    {
        [exif setObject:@"" forKey:kDateTimeOriginalKey];
    }
    else
    {
        [exif setObject:[CAssetsPickerPlugin date2str:date withFormat:DATETIME_FORMAT] forKey:kDateTimeOriginalKey];
    }
    
    //obj.exif.PixelXDimension
    //obj.exif.PixelYDimension
    if (_destType == DestinationTypeDataURL)
    {
        //
        if (asset.defaultRepresentation != nil)
        {
            [exif setObject:@(asset.defaultRepresentation.dimensions.width) forKey:kPixelXDimensionKey];
            [exif setObject:@(asset.defaultRepresentation.dimensions.height) forKey:kPixelYDimensionKey];
        }
        else
        {
            [exif setObject:@(0) forKey:kPixelXDimensionKey];
            [exif setObject:@(0) forKey:kPixelYDimensionKey];
        }
    }
    else
    {
        if (asset.defaultRepresentation != nil)
        {
            [exif setObject:@(asset.defaultRepresentation.dimensions.width) forKey:kPixelXDimensionKey];
            [exif setObject:@(asset.defaultRepresentation.dimensions.height) forKey:kPixelYDimensionKey];
        }
        else
        {
            [exif setObject:@(0) forKey:kPixelXDimensionKey];
            [exif setObject:@(0) forKey:kPixelYDimensionKey];
        }
    }
    
    //obj.exif.Orientation
    [exif setObject:[asset valueForProperty:ALAssetPropertyOrientation] forKey:kOrientationKey];
    
    [retValues setObject:exif forKey:kExifKey];
    
    return retValues;
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
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < assets.count; i++)
    {
        ALAsset *asset = [assets objectAtIndex:i];
        //NSDictionary *retValues = [self objectFromAsset:asset fromThumbnail:YES];
        NSDictionary *retValues = [self objectFromAsset:asset fromThumbnail:NO];
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

#pragma mark - Common Function

+ (NSString *)date2str:(NSDate *)convertDate withFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    
    return [dateFormatter stringFromDate:convertDate];
}

+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)scale
{
    CGSize newSize;
    newSize.width = image.size.width * scale;
    newSize.height = image.size.height *scale;
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
