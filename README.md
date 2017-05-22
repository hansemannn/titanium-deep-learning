# Titanium Deep-Learning
Use the JetPac DeepBeliefSDK framework in Appcelerator Titanium.

## Example
```js
var TiDeepLearning = require('ti.deeplearning');

TiDeepLearning.initializeNetwork({
    name: 'my_network' // Needs to be in your resources: `my_network.ntwk`
});

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

var btn = Ti.UI.createButton({
    title: 'Trigger'
});

btn.addEventListener('click', function() {
    TiDeepLearning.classifyImage({
        image: 'my_image.jpg',
        callback: function(e) {
            Ti.API.info(e.result);
        }
    });
});

win.add(btn);
win.open();
```

For a full example, check the demos in `example/app.js`.

## Author
Hans Knoechel ([@hansemannnn](https://twitter.com/hansemannnn) / [Web](http://hans-knoechel.de))

## License
Apache 2.0

## Contributing
Code contributions are greatly appreciated, please submit a new [pull request](https://github.com/hansemannn/titanium-deep-learning/pull/new/master)!
