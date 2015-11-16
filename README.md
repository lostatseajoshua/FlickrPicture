# FlickrPicture
Retrieve public Flickr photos based on your location.

## Installation
Xcode 7
Swift 2.1
iOS 9.0

##Configuration
To retrieve photos you will have to add your Flickr API key and add it to FlickrKit.swift file. Replace the variable of flickrAPIKey with your API key.

## Usage
Flickr Picture is an example project on how to call a restful API to retrieve data, in this example we are using Flickr API. The application calls the flickr.photos.search API to retireve photo data and parses the data. It then saves the photos into Core Data. The main UI uses a collection view with the help of a NSFetchResultsController to display the photos. CoreLocation is used to find the user's location and pass the lat and long into the call. If no location found the app defaults to use New York City, NY coordinates.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

TODO: Write history

## Credits
Joshua Alvarado
@alvaradojoshua0
alvaradjoshua0@gmail.com

## License
The MIT License (MIT)

Copyright (c) 2015 Joshua Alvarado

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
