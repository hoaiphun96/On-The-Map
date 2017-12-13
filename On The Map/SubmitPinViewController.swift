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
    
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var map: MKMapView!
    var newlocation: String!
    var newLat: CLLocationDegrees?
    var newLong: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // GET THE LAT AND LONG BASED ON
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(newlocation!, completionHandler: {(placemarks, error) -> Void in
            if let placemark = placemarks?[0] {
                self.newLat = placemark.location!.coordinate.latitude
                self.newLong = placemark.location!.coordinate.longitude
                
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
                let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.newLat!, self.newLong!)
                let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                self.map.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                self.map.addAnnotation(annotation)
            }
            else {
                OTMClient.sharedInstance().showAlertMessage(title: "Try again", message: "Location not found", viewController: self, shouldPop: true)
            }
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
      
        }
   
   
    @IBAction func cancelClicked(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        print("NEW LOCATION WHEN CLICKING SUBMIT", self.newlocation)
        let parameters = ["latitude": self.newLat!,
                          "longitude": self.newLong!,
                          "mapString": self.newlocation!,
                          "mediaURL": self.mediaURL!.text!] as [String : AnyObject]
        //if pin existed, call put, update updatedAt
        if OTMClient.sharedInstance().myAccount.objectId != nil {
            let _ = OTMClient.sharedInstance().puttingStudentLocation(parameters, completionHandlerForPutStudentLocation: { (success, errorString) in
                if errorString != nil {
                    print(errorString!)
                    return
                }
                print("AFTER UPDATING WITH A NEW PIN",OTMClient.sharedInstance().myAccount)
              
            })
        }
        else {
        //else called post, updated createdAt, objectID
        let _ = OTMClient.sharedInstance().postStudentLocation(parameters: parameters, completionHandlerForPin: { (success, errorString) in
            if errorString != nil {
                print(errorString!)
                return
            }
            print("AFTER POSTING A NEW PIN",OTMClient.sharedInstance().myAccount.createdAt!,OTMClient.sharedInstance().myAccount.objectId!)
            })
        }
        OTMClient.sharedInstance().myAccount.mapString = newlocation
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    
}
