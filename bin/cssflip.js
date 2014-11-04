#!/usr/bin/env node

var flip = require('css-flip');
var fs = require('fs');

process.argv.slice(2).forEach(function (fileName) {
  var css = fs.readFileSync(fileName, 'utf8');
  fs.writeFileSync(fileName + '.rtl', flip(css), 'utf8');
});
