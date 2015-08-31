#!/bin/bash
browserify -t coffeeify --extension=".coffee" controller/index.coffee > build/controller.js
browserify -t coffeeify --extension=".coffee" iframe/index.coffee > build/iframe.js

browserify -t coffeeify --extension=".coffee" iframe/sandbox.coffee > build/sandbox.js
browserify -t coffeeify --extension=".coffee" iframe/graphwarp.coffee > build/graphwarp.js
browserify -t coffeeify --extension=".coffee" iframe/pixels.coffee > build/pixels.js
