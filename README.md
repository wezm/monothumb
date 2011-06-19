monothumb
=========

monothumb is a tool used to produce the monochrome thumbnails on the front
page of my website: [http://www.wezm.net](http://www.wezm.net). It uses the
Flickr API to retreive recent uploads, create a monochrome version, write the
monochrome version along with the original color version to a single output
image and finally save a copy of the Flickr API response XML. Some Javascript
on the site uses the image and XML to render the thumbnails with a color
rollover.

There is actually two implementations of the tool in this repo. The one on the 
master branch is implemented in Objective-C and makes use of Core Image. The
other is implemented in Lua and uses Lua bindings to imlib2.