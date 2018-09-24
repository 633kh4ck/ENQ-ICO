let path = require('path');
require('fs').readdirSync(__dirname).forEach(function(file) {
	if (file.match(/\.js$/) !== null && file !== 'index.js') {
		module.exports[path.basename(file, '.js')] = require(path.join(__dirname, file));
	}
});