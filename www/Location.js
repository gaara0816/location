var exec = require('cordova/exec');

exports.location = function (success, error) {
    exec(success, error, 'Location', 'location', []);
};
