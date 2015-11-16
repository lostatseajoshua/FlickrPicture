//
//  FlickrKit.swift
//  FlickerPicture
//
//  Created by Joshua Alvarado on 10/31/15.
//  Copyright © 2015 Joshua Alvarado. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrKit {
    
    private static let flickrAPIKey = "{Flickr API key here}"
    private static let flickrAPIBaseURL = "https://api.flickr.com/services/rest/?"
    private static let flickrPhotoSearchMethod = "method=flickr.photos.search"
    private static let flickrSinglePhotoURL = "https://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}_[mstb].jpg"

    private static let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    /**
     Retrieves single photo using a photo URL.
     
     - Parameter url: URL in string format.
     
     - Returns: optional UIImage.
     */
    private class func getPhotoDataWithURL(url: String) -> NSData? {

        if let photoURL = NSURL(string: url) {
            do {
                let imageData = try NSData(contentsOfURL: photoURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                return imageData
            } catch {
                return nil
            }
        }
        return nil
    }
    
    /**
     Asnychronous call to retrieve public Flickr photos based on a location.
     
     - Parameter lat: latitiude
     - Parameter long: longitude
     - Parameter completionHandler: block that is called with optional array of UIImages & optional error when call is complete. Returns void
     
     */
    class func getAllPublicPhotosInLocation(lat: Double, long: Double, completionHandler: (error: NSError?) -> Void) {
        
        let urlString = flickrAPIBaseURL + flickrPhotoSearchMethod + "&api_key=\(flickrAPIKey)&lat=\(lat)&lon=\(long)&content_type=1&per_page=15&format=json&nojsoncallback=1"
        let url = NSURL(string: urlString)!
        
        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithRequest(request, completionHandler: {
            (data, request, error) in
            if error == nil {
                do {
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSObject: AnyObject] {
                        if let photosDict = jsonDict[FlickrKit.FlickrJSONKeys.FKPhotosKey] as? [NSObject: AnyObject] {
                            if let photoArray = photosDict[FlickrKit.FlickrJSONKeys.FKPhotoKey] as? [[NSObject: AnyObject]] {
                                for photo in photoArray {
                                    if let secret = photo[FlickrKit.FlickrJSONKeys.FKSecretKey] as? String, let id = photo[FlickrKit.FlickrJSONKeys.FKIdKey] as? String, let server = photo[FlickrKit.FlickrJSONKeys.FKServerKey] as? String, let farm = photo[FlickrKit.FlickrJSONKeys.FKFarmKey] as? Int {
                                        let farmToString = "\(farm)"
                                        let photoURLString = "https://farm" + farmToString + ".static.flickr.com/" + server + "/" + id + "_" + secret + "_" + "m.jpg"
                                        if let imageData = getPhotoDataWithURL(photoURLString), let title = photo[FlickrKit.FlickrJSONKeys.FKPhotoTitleKey] as? String {
                                            FlickrKit.saveFlickrPhotoToCoreData(photoData: imageData, title: title, id: id)
                                        }
                                    }
                                }
                                completionHandler(error: nil)
                            }
                        }
                    }
                } catch let error as NSError {
                    //error hanlding
                    completionHandler(error: error)
                }
            } else {
               //error hanlding
                completionHandler(error: error)
            }
        }).resume()
    }

    /**
     Flickr JSON keys used to parse flickr.photos.search API JSON response
     Details here: https://www.flickr.com/services/api/flickr.photos.search.html
     */
    private struct FlickrJSONKeys {
        static let FKPhotosKey = "photos"
        static let FKPhotoKey = "photo"
        static let FKSecretKey = "secret"
        static let FKIdKey = "id"
        static let FKFarmKey = "farm"
        static let FKServerKey = "server"
        static let FKPhotoTitleKey = "title"
    }

    /**
     FlickrKit Core Data coordinator. Save a Flickr photo into core data for persistance
     
     - Parameter photoData: raw photo NSData
     - Parameter title: photo caption title
     - Parameter id: photo unique id
     
     */
    private class func saveFlickrPhotoToCoreData(photoData photoData: NSData, title: String, id: String) {
        
        let fetchRequest = NSFetchRequest(entityName: "FlickrPhoto")
        
        //check if photo exists already in Coredata
        do {
            if let fetchResults = try FlickrKit.appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [FlickrPhoto] {
                for photo in fetchResults {
                    if photo.id == id {
                        return
                    }
                }
            }
        } catch {
            print(error)
        }

        //save new photo into core data
        let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("FlickrPhoto", inManagedObjectContext: FlickrKit.appDelegate.managedObjectContext) as! FlickrPhoto
        newPhoto.title = title
        newPhoto.image = photoData
        newPhoto.id = id
        newPhoto.creationDate = NSDate()
        
        //save core data
        do {
            try FlickrKit.appDelegate.managedObjectContext.save()
        } catch {
            print("fata error saving core data \(error)")
        }
    }
    
}