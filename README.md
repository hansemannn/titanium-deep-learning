# Titanium Deep-Learning
Use the JetPac DeepBeliefSDK framework in Appcelerator Titanium.

> **Note**: This module does not support apps running with app-thinning enabled so far. It will be part of upcoming versions and is scheduled already.

## Example
```js
var TiDeepLearning = require('ti.deeplearning');

TiDeepLearning.initializeNetwork({
    name: 'jetpac.ntwk' // Search and download from the DeepBelief SDK Github page
});

TiDeepLearning.classifyImage({
    image: 'macintosh.jpg',
    minimumThreshold: 0.01,
    decay: 0.75, 
    callback: function(e) {
        Ti.API.info(e.result);
    }
});
```
The above example with return an array with predictions, like this:
```
(
    {
        label = printer;
        value = "0.1368110626935959";
    },
    {
        label = monitor;
        value = "0.06563640385866165";
    },
    {
        label = "desktop computer";
        value = "0.143329456448555";
    },
    {
        label = screen;
        value = "0.4579531848430634";
    },
    {
        label = iPod;
        value = "0.01504476089030504";
    },
    {
        label = "cash machine";
        value = "0.02499096281826496";
    },
    {
        label = safe;
        value = "0.01404030714184046";
    },
    {
        label = "entertainment center";
        value = "0.01761411875486374";
    },
    {
        label = television;
        value = "0.06137070804834366";
    }
)
```
Note that the values highly depend on your network and complexity of classification. 
For a full example, check the demos in `example/app.js`.

## Author
Hans Knoechel ([@hansemannnn](https://twitter.com/hansemannnn) / [Web](http://hans-knoechel.de))

## License
MIT

## Contributing
Code contributions are greatly appreciated, please submit a new [pull request](https://github.com/hansemannn/titanium-deep-learning/pull/new/master)!
