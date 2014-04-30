cordova-plugin-assets-picker
============================

Phonegap Assets Picker Plugin, supports multiple selection of photos from album using [CTAssetsPickerController][ctassetspickercontroller]. API specs is following [cordova-plugin-local-notifications][cordova-plugin-local-notifications]

### Plugin's Purpose
The purpose of the plugin is to create a fast and reliable view of photos on the mobile phones.


## Supported Platforms
- **iOS**<br>

## Dependencies
[Cordova][cordova] will check all dependencies and install them if they are missing.


## Installation
The plugin can either be installed into the local development environment or cloud based through [PhoneGap Build][PGB].

### Adding the Plugin to your project
Through the [Command-line Interface][CLI]:
```bash
# ~~ from master ~~
cordova plugin add https://github.com/donaldp24/cordova-plugin-assets-picker.git && cordova prepare
```
or to use the last stable version:
```bash
# ~~ stable version ~~
cordova plugin add com.michael.cordova.plugin.assets-picker && cordova prepare
```

### Removing the Plugin from your project
Through the [Command-line Interface][CLI]:
```bash
cordova plugin rm com.michael.cordova.plugin.assets-picker
```

### PhoneGap Build
Add the following xml to your config.xml to always use the latest version of this plugin:
```xml
<gap:plugin name="com.michael.cordova.plugin.assets-picker" />
```
or to use an specific version:
```xml
<gap:plugin name="com.michael.cordova.plugin.assets-picker" version="0.8.1" />
```
More informations can be found [here][PGB_plugin].


## ChangeLog

#### Version 0.8.1 (not yet released)
- [feature:] added FILE_URI feature
- [feature:] added getById function
- [enhanced:] changed parameter "selectedAssets" of options to "overlay"

#### Version 0.8.0 (not yet released)
- [feature:] Create plugin


## Using the plugin
The plugin creates the object ```window.plugin.snappi.assetspicker``` with the following methods:

### Plugin initialization
The plugin and its methods are not available before the *deviceready* event has been fired.

```javascript
document.addEventListener('deviceready', function () {
    // window.plugin.snappi.assetspicker is now available
}, false);
```

### getPicture
Retrieves multiple photos from the device's album.<br>
Selected images are returned as an array of identifiers of image, image data (or URIs) and exif of image files.<br>

```javascript
window.plugin.snappi.assetspicker.getPicture([onSuccess][onsuccess], [onCancel][oncancel], [options][options]);
```

This function opens photo chooser dialog, from which multiple photos from the album can be selected.
The return array will be sent to the [onSuccess][onsuccess] function, each item has dictionary value as following formats;
```javascript
{
id : identifier,
data : imageData,
exif : {
    DateTimeOriginal : dateTimeOriginal,
    PixelXDimension : pixelXDimension,
    PixelYDimension : pixelYDimension,
    Orientation : orientation
};
```

##### id
identifier string of selected photo.
##### data
The data of image is one of the following formats, depending on the options you specify:
- A String containing the Base64 encoded photo image.
- A String representing the image file location on local storage (default).

##### exif
- DateTimeOriginal : datetime when the image was taken. formatted as "yyyy-MM-dd HH:mm:ss" ("2014-01-31 11:02:59")
- PixelXDimension : width (pixels) of the image.
- PixelYDimension : height (pixels) of the image.
- Orientation : The key to retrieve the orientation of the asset. The corresponding value is an number containing an asset's orientation as described by the TIFF format.

#### Example
```javascript
function pickPictures()
{
    var options = {
        quality: 75,
        destinationType: Camera.DestinationType.DATA_URL,
        encodingType: Camera.EncodingType.JPEG,
        targetWidth: 100,
        targetHeight: 100
    };
    window.plugin.snappi.assetspicker.getPicture(onSuccess, onCancel, options);
}
```

### getById
Retrieve a photo with AssetsId.<br>

```javascript
window.plugin.snappi.assetspicker.getById(AssetId, [onGetById][ongetbyid], [onCancel][oncancel], [options][options]);
```

This function gets a Assets with AssetsId.
The return picture will be sent to the [onGetById][ongetbyid] function, returned picture is a dictionary value as following formats;
```javascript
{
id : identifier,
data : imageData,
exif : {
    DateTimeOriginal : dateTimeOriginal,
    PixelXDimension : pixelXDimension,
    PixelYDimension : pixelYDimension,
    Orientation : orientation
};
```

##### Parameters
Same as an item of returned array on [onSuccess][onsuccess] callback.

#### Example
```javascript
function getAPictureWithId(AssetId)
{
    var options = {
        quality: 75,
        destinationType: Camera.DestinationType.DATA_URL,
        encodingType: Camera.EncodingType.JPEG,
        targetWidth: 100,
        targetHeight: 100
    };
    window.plugin.snappi.assetspicker.getById(AssetId, onGetById, onCancel, options);
}
```


### onSuccess
onSuccess callback function that provides the selected images.
```javascript
function(dataArray) {
    // Do something with the images
}
```
#### Parameters
- dataArray: array of image with identifier and image data
```javascript
{
id : identifier,	// unique identifier string of the image
data : imageData,	// image data, Base64 encoding of the image data, OR the image file URI, depending on options used. (String)
exif : {
    DateTimeOriginal : dateTimeOriginal, 	// datetime when the image was taken
    PixelXDimension : pixelXDimension,		// width (pixels) of the image
    PixelYDimension : pixelYDimension,		// height (pixels) of the image
    Orientation : orientation			// orientation number
};
```

#### Example
```javascript
// Show selected images
//
function onSuccess(dataArray) {
    for (i = 0; i <= dataArray.length; i++) {
         var item = dataArray[i];
         var imageId = item.id;
         
         // get picture by Id
         window.plugin.snappi.assetspicker.getById(item.id, onGetById, onCancel, options);
    }
}
```


### onCancel
onCancel callback function that provides a cancel or error message.
```javascript
function(message) {
    // Show a helpful message
    alert(message);
}
```
#### Parameters
- message: The message is provided by the device. (String)


### onGetById
onGetById callback function that provide the selected image.
```javascript
function(imageData) {
    // Do something with the image
}
```
#### Parameters
- imageData: image data of selected image, just like an item of returned array on [onSucess][onsuccess] callback.
```javascript
{
id : identifier,	// unique identifier string of the image
data : imageData,	// image data, Base64 encoding of the image data, OR the image file URI, depending on options used. (String)
exif : {
    DateTimeOriginal : dateTimeOriginal, 	// datetime when the image was taken
    PixelXDimension : pixelXDimension,		// width (pixels) of the image
    PixelYDimension : pixelYDimension,		// height (pixels) of the image
    Orientation : orientation			// orientation number
};
```

#### Example
```javascript
// Show selected images
//
function onGetById(imageData) {
    var image = document.getElementById(imageData.id);
    image.src = "data:image/jpeg;base64," + imageData.data;
}
```

### options
Optional parameters to customize the settings.
```javascript
{ quality : 75, 
  destinationType : Camera.DestinationType.DATA_URL, 
  sourceType : Camera.PictureSourceType.CAMERA, 
  allowEdit : true,
  encodingType: Camera.EncodingType.JPEG,
  targetWidth: 100,
  targetHeight: 100,
  popoverOptions: CameraPopoverOptions,
  saveToPhotoAlbum: false,
  scrollToDate: new Date(),
  overlay: {overlayName: AssetsIdsArray}
  };
```

- quality: Quality of saved image. Range is [0, 100]. (Number)
- destinationType: Choose the format of the return value. Defined in Camera.DestinationType (Number)
```javascript
    Camera.DestinationType = {
        DATA_URL : 0,                // Return image as base64 encoded string
        FILE_URI : 1                 // Return image file URI
    };
```
- sourceType: Set the source of the picture. Defined in Camera.PictureSourceType (Number)
```javascript
Camera.PictureSourceType = {
    PHOTOLIBRARY : 0,
    CAMERA : 1,
    SAVEDPHOTOALBUM : 2
};
```
- allowEdit: Allow simple editing of image before selection. (Boolean)
- encodingType: Choose the encoding of the returned image file. Defined in Camera.EncodingType (Number)
```javascript
    Camera.EncodingType = {
        JPEG : 0,               // Return JPEG encoded image
        PNG : 1                 // Return PNG encoded image
    };
```
- targetWidth: Width in pixels to scale image. Could be used with targetHeight. Aspect ratio is keeped. (Number)
- targetHeight: Height in pixels to scale image. Could be used with targetWidth. Aspect ratio is keeped. (Number)
- mediaType: Set the type of media to select from. Only works when PictureSourceType is PHOTOLIBRARY or SAVEDPHOTOALBUM. Defined in nagivator.camera.MediaType (Number)
```javascript
Camera.MediaType = { 
    PICTURE: 0,             // allow selection of still pictures only. DEFAULT. Will return format specified via DestinationType
    VIDEO: 1,               // allow selection of video only, WILL ALWAYS RETURN FILE_URI
    ALLMEDIA : 2            // allow selection from all media types
};
```
- correctOrientation: Rotate the image to correct for the orientation of the device during capture. (Boolean)
- saveToPhotoAlbum: Save the image to the photo album on the device after capture. (Boolean)
- scrollToDate: Scroll to indicated date when open photo chooser dialog.
- overlay: Array of IDs of images to be with overlay. Show overlay icons on these images when open photo chooser dialog. IDs could be returned [onSuccess][onsuccess] callback. 
- popoverOptions: iOS only options to specify popover location in iPad. Defined in CameraPopoverOptions.

#### CameraPopoverOptions

Parameters only used by iOS to specify the anchor element location and arrow direction of popover used on iPad when selecting images from the library or album.
```javascript
{ x : 0, 
  y :  32,
  width : 320,
  height : 480,
  arrowDir : Camera.PopoverArrowDirection.ARROW_ANY
};
```

- x: x pixel coordinate of element on the screen to anchor popover onto. (Number)
- y: y pixel coordinate of element on the screen to anchor popover onto. (Number)
- width: width, in pixels, of the element on the screen to anchor popover onto. (Number)
- height: height, in pixels, of the element on the screen to anchor popover onto. (Number)
- arrowDir: Direction the arrow on the popover should point. Defined in Camera.PopoverArrowDirection (Number)
```javascript
    Camera.PopoverArrowDirection = {
        ARROW_UP : 1,        // matches iOS UIPopoverArrowDirection constants
        ARROW_DOWN : 2,
        ARROW_LEFT : 4,
        ARROW_RIGHT : 8,
        ARROW_ANY : 15
    };
```
**Note:** The size of the popover may change to adjust to the direction of the arrow and orientation of the screen. Make sure to account for orientation changes when specifying the anchor element location.
#### Example
```javascript
 var popover = new CameraPopoverOptions(300,300,100,100,Camera.PopoverArrowDirection.ARROW_ANY);
 var options = { quality: 50, destinationType: Camera.DestinationType.DATA_URL,sourceType: Camera.PictureSource.SAVEDPHOTOALBUM, popoverOptions : popover };

 navigator.camera.getPicture(onSuccess, onCancel, options);

 function onSuccess(dataArray) {
	for (i = 0; i <= dataArray.length; i++) {
         var item = dataArray[i];
         var imageId = item.id;
         var image = document.getElementById(imageId);
         image.src = "data:image/jpeg;base64," + item.data;
    }
 }

 function onCancel(message) {
     alert('Failed because: ' + message);
 }
```

## Full Example
```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <meta name="format-detection" content="telephone=no" />
        <!-- WARNING: for iOS 7, remove the width=device-width and height=device-height attributes. See https://issues.apache.org/jira/browse/CB-4323 -->
        <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />
        <link rel="stylesheet" type="text/css" href="css/index.css" />
        <title>Assets Picker Plugin</title>
    </head>
    <body>
        <div class="app">
            <h1>Apache Cordova</h1>
            <div id="deviceready" class="blink">
                <p class="event listening">Connecting to Device</p>
                <p class="event received">Device is Ready</p>
            </div>
        </div>
        <div style="position:absolute;left:0%;top:0%">
            <table id="imagetable">
            </table>
        </div>
        <div style="position:absolute;left:20%;top:50%">
            <input type="button" value="Pick" onclick="onPick()" style="width:100px;height=80px"/>
            <input type="button" value="Clear" onclick="onClear()" style="width:100px;height=80px"/>
        </div>
        <script type="text/javascript" src="cordova.js"></script>
        <script type="text/javascript" src="js/index.js"></script>
        <script type="text/javascript">
            app.initialize();
        </script>
        <script type="text/javascript">
            var selectedAssets = new Array();
            // called when "pick" button is clicked
            function onPick()
            {
                var assetsIds = new Array();
                if (selectedAssets != null && selectedAssets.length != 0)
                {
                    for (var i = 0; i < selectedAssets.length; i++)
                    {
                        assetsIds[i] = selectedAssets[i].id;
                    }
                }
                var overlayObj = {};
                
                overlayObj[Camera.Overlay.PREVIOUS_SELECTED] = assetsIds;
                
                var options = {
                    quality: 75,
                    destinationType: Camera.DestinationType.FILE_URI,
                    encodingType: Camera.EncodingType.JPEG,
                    targetWidth: 100,
                    targetHeight: 100,
                    overlay: overlayObj
                };
                alert('before calling');
                navigator.camera.getPicture(onSuccess, onFailure, options);
            }
        
        // called when "clear" button is clicked
        function onClear()
        {
            selectedAssets = new Array();
            document.getElementById("imagetable").innerHTML = "";
        }
        
        // success callback
        function onSuccess(dataArray)
        {
            selectedAssets = dataArray;
            var strTr = "";
            for (i = 0; i < selectedAssets.length; i++)
            {
                var obj = selectedAssets[i];
                strTr += "<tr><td><img id='" + obj.id + "' /></td><td>" + obj.exif.PixelXDimension + " x " + obj.exif.PixelYDimension + " : " + obj.exif.Orientation + "</td></tr>";
            }
            document.getElementById("imagetable").innerHTML = strTr;
            for (i = 0; i < selectedAssets.length; i++)
            {
                var obj = selectedAssets[i];
                //var image = document.getElementById(obj.id);
                //image.src = "data:image/jpeg;base64," + obj.data;
                
                var options = {
                    quality: 75,
                    destinationType: Camera.DestinationType.DATA_URL,
                    encodingType: Camera.EncodingType.JPEG,
                    targetWidth: 100,
                    targetHeight: 100
                };
                navigator.camera.getById(obj.id, onGetById, onFailure, options);
            }
        }
        
        // cancel callback
        function onFailure(message)
        {
            //alert(message);
        }
        
        // getById success callback
        function onGetById(data)
        {
            var image = document.getElementById(data.id);
            image.src = "data:image/jpeg;base64," + data.data;
        }
        </script>
    </body>
</html>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

This software is released under the [Apache 2.0 License][apache2_license].

© 2013-2014 appPlant UG, Inc. All rights reserved

[ctassetspickercontroller]: https://github.com/chiunam/CTAssetsPickerController
[cordova-plugin-local-notifications]: https://github.com/katzer/cordova-plugin-local-notifications
[cordova]: https://cordova.apache.org
[onsuccess]: #onSuccess
[oncancel]: #onCancel
[options]: #options
[ongetbyid]: #onGetById
[CLI]: http://cordova.apache.org/docs/en/3.0.0/guide_cli_index.md.html#The%20Command-line%20Interface
[PGB]: http://docs.build.phonegap.com/en_US/3.3.0/index.html
[apache2_license]: http://opensource.org/licenses/Apache-2.0
