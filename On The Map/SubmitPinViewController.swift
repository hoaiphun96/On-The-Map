//
//  SubmitPinViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/7/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit
import MapKit
class SubmitPinViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var map: MKMapView!
    var newlocation: String!
    var newmediaurl: String!
    var newLat: CLLocationDegrees?
    var newLong: CLLocationDegrees?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        let button = UIBarButtonItem(title: "Add Location", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIWebView.goBack))
        self.navigationItem.backBarButtonItem = button
        self.navigationController?.navigationBar.topItem?.title = "Add Location"
        
    }
    
    func findLocation() {
        LoaderController.sharedInstance.showLoader(map)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(newlocation, completionHandler: {(placemarks, error) -> Void in
            if let placemark = placemarks?[0] {
                self.newLat = placemark.location!.coordinate.latitude
                self.newLong = placemark.location!.coordinate.longitude
                
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
                let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.newLat!, self.newLong!)
                let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                self.map.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                performUIUpdatesOnMain {
                    self.map.addAnnotation(annotation)
                }
                self.map.addAnnotation(annotation)
                LoaderController.sharedInstance.removeLoader()
            }
            else {
                LoaderController.sharedInstance.removeLoader()
                OTMClient.sharedInstance.showAlertMessage(title: "Try again", message: OTMClient.sharedInstance.isInternetAvailable() ? "There was an error finding your location" : "There is no internet connection" , viewController: self, shouldPop: true)
            }
            })
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cancelClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    @IBAction func finishClicked(_ sender: Any) {
        
        let parameters = ["latitude": self.newLat!,
                          "longitude": self.newLong!,
                          "mapString": self.newlocation,
                          "mediaURL": self.newmediaurl] as [String : AnyObject]
        //if pin existed, call put, update updatedAt
        if OTMClient.sharedInstance.myAccount.objectId != nil {
            let _ = OTMClient.sharedInstance.puttingStudentLocation(parameters, completionHandlerForPutStudentLocation: { (success, errorString) in
                if errorString != nil {
                    print(errorString!)
                    OTMClient.sharedInstance.showAlertMessage(title: "", message: "There was an error updating your location, please try again", viewController: self, shouldPop: true)
                    return
                }
                
            })
        }
        else {
            //else called post, updated createdAt, objectID
            let _ = OTMClient.sharedInstance.postStudentLocation(parameters: parameters, completionHandlerForPin: { (success, errorString) in
                if errorString != nil {
                    print(errorString!)
                    OTMClient.sharedInstance.showAlertMessage(title: "", message: "There was an error posting your location, please try again", viewController: self, shouldPop: true)
                    return
                }
            })
        }
        OTMClient.sharedInstance.myAccount.mapString = newlocation
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[1], animated: true)
    }
    
    
}
