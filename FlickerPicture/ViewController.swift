//
//  ViewController.swift
//  FlickerPicture
//
//  Created by Joshua Alvarado on 10/31/15.
//  Copyright © 2015 Joshua Alvarado. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationManager = CLLocationManager()
    let flickrPhotoCollectionViewCellID = "FlickrPhotoCell"
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    lazy var flickrPhotoFetchResultsController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "FlickrPhoto")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    
    var userLocation: CLLocation! {
        willSet {
            retrieveFlickrPicturesBasedOnLocation(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.dataSource = self
        collectionView.delegate = self
        locationManager.delegate = self
        do {
            try flickrPhotoFetchResultsController.performFetch()
        } catch {
            showAlert("Fatal error", message: "Unkown error in retrieving photos")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fetchFlickrImages(sender: UIButton) {
        self.retrieveUserLocation()
    }
    
    //MARK: Utilites
    func retrieveUserLocation() {
        activityIndicator.startAnimating()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .NotDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestLocation()
            case .Denied, .Restricted:
                activityIndicator.stopAnimating()
                //alert user to enable location services for this app
                showAlert("Location Services disabled", message: "For the best experience please enable location services")
            }
        } else {
            activityIndicator.stopAnimating()
            //alert user to enable location services to retrieve photos based on user location
            showAlert("Location Services disabled", message: "For the best experience please enable location services")
        }
    }
    
    func retrieveFlickrPicturesBasedOnLocation(location: CLLocation) {
        FlickrKit.getAllPublicPhotosInLocation(location.coordinate.latitude, long: location.coordinate.longitude) {
            error in
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
            })
            if error != nil {
                //error retrieving photos
                self.showAlert("Oh no!", message: "There was an error with the retrieval of the photos. Please try again.")
            }
        }
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            retrieveUserLocation()
        case .Denied, .Restricted:
            //alert user to enable location services for this app
            activityIndicator.stopAnimating()
            showAlert("Location Services disabled", message: "For the best experience please enable location services")
        case .NotDetermined:
            retrieveUserLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        //alert user of location error failure
        showAlert("Uh Oh", message: "There seems to be an error retrieving your location. A default location will be used to retrieve photos at this time.")
        //set location to a default location
        //coordinates of New York City, NY
        let defaultLocation = CLLocation(latitude: 40.7127, longitude: 74.0059)
        retrieveFlickrPicturesBasedOnLocation(defaultLocation)
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = flickrPhotoFetchResultsController.fetchedObjects?.count {
            return count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(flickrPhotoCollectionViewCellID, forIndexPath: indexPath) as! FlickrPhotoCollectionViewCell
        let flickrPhoto = flickrPhotoFetchResultsController.fetchedObjects![indexPath.row] as! FlickrPhoto
        if let data = flickrPhoto.image, image = UIImage(data: data) {
            cell.flickrPhotoImageView.image = image
        }
        if let title = flickrPhoto.title {
            cell.flickrPhotoTitleLabel.text = title
        }
        return cell
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    // First initialise an array of NSBlockOperations:
    var blockOperations: [NSBlockOperation] = []
    
    
    // In the did change object method:
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if type == NSFetchedResultsChangeType.Insert {
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Move {
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        }
    }
    
    // In the did change section method:
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        if type == NSFetchedResultsChangeType.Insert {
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
    }
    
    // And finally, in the did controller did change content method:
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: NSBlockOperation in self.blockOperations {
                operation.start()
            }
            }, completion: { (finished) -> Void in
                self.blockOperations.removeAll(keepCapacity: false)
        })
    }
    
    // I personally added some code in the deinit method as well, in order to cancel the operations when the ViewController is about to get deallocated:
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: NSBlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepCapacity: false)
    }
}


