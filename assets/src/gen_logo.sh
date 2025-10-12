#!/bin/bash

cp logo.png ../../ohos/AppScope/resources/base/media/foreground.png
magick logo.png -resize 128 ../../ohos/entry/src/main/resources/base/media/startIcon.png
cp ../../ohos/entry/src/main/resources/base/media/startIcon.png ../../ohos/entry/src/ohosTest/resources/base/media/startIcon.png
magick logo.png -resize 192 ../images/logo.webp
