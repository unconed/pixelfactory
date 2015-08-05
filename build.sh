#!/bin/bash
browserify -t coffeeify --extension=".coffee" controller/index.coffee > build/controller.js
