var TiDeepLearning = require('ti.deeplearning');

TiDeepLearning.initializeNetwork({
	name: 'jetpac.ntwk' // Search and download from the DeepBelief SDK Github page
});

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

var btn = Ti.UI.createButton({
    title: 'Compute image'
});

btn.addEventListener('click', function() {
    TiDeepLearning.classifyImage({
		image: 'macintosh.jpg',
        minimumThreshold: 0.01,
        decay: 0.75, 
		callback: function(e) {
			Ti.API.info(e.result);
		}
	});
});

win.add(btn);
win.open();
