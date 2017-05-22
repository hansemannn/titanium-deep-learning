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
