cordova-plugin-assets-picker
============================

Phonegap Assets Picker Plugin, supports multiple selection of photos from album.

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
<gap:plugin name="com.michael.cordova.plugin.assets-picker" version="0.8.0" />
```
More informations can be found [here][PGB_plugin].


## ChangeLog
#### Version 0.8.0 (not yet released)
- [feature:] Create plugin


## Using the plugin
The plugin creates the object ```navigator.camera``` with the following methods:

### Plugin initialization
The plugin and its methods are not available before the *deviceready* event has been fired.

```javascript
document.addEventListener('deviceready', function () {
    // navigator.camera is now available
}, false);
```

### getPicture
Retrieves multiple photos from the device's album.<br>
Selected images are returned as an array of identifiers of images and base64 encoded Strings or as an array of identifiers and the URIs of image files.<br>

```javascript
navigator.camera.getPicture([onSuccess][onsuccess], [onCancel][oncancel], [options][options]);
```

This function opens photo chooser dialog, from which multiple photos from the album can be selected.
The return array will be sent to the [onSuccess][onsuccess] function, each item has dictionary value as following formats;
```javascript
{
id : identifier,
data : imageData
};
```

##### id
identifier string of selected photo.
##### data
The data of image is one of the following formats, depending on the options you specify:
- A String containing the Base64 encoded photo image.
- A String representing the image file location on local storage (default).

### onSuccess
onSuccess callback function that provides the selected images.
```javascript
function(dataArray) {
    // Do something with the images
}
```
#### Parameters
- dataArray: array of image with identifier and image data, 
```javascript
{
id : identifier,	// unique identifier string of the image
data : imageData	// image data, Base64 encoding of the image data, OR the image file URI, depending on options used. (String)
};
```

## Examples

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

This software is released under the [Apache 2.0 License][apache2_license].

© 2013-2014 appPlant UG, Inc. All rights reserved


[onsucces]: #onSuccess