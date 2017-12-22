//
//  OnTheMapMapViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/6/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit
import MapKit

class OnTheMapMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        reloadMap()
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        reloadMap()
    }
    
    func reloadMap() {
        guard OTMClient.sharedInstance.isInternetAvailable() else {
            OTMClient.sharedInstance.showAlertMessage(title: "", message: "There is no internet connection", viewController: self, shouldPop: false)
            return
        }
        LoaderController.sharedInstance.showLoader(mapView)
        mapView.removeAnnotations(mapView.annotations)
        let _ = OTMClient.sharedInstance.getStudentLocations { (locations, error) in
            if let locations = locations {
                Students.sharedInstance = locations
                var annotations = [MKPointAnnotation]()
                for dictionary in Students.sharedInstance {
                    
                    if let latdouble = dictionary.latitude, let longdouble = dictionary.longitude {
                        let lat = CLLocationDegrees(latdouble)
                        let long = CLLocationDegrees(longdouble)
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        let firstName = dictionary.firstName
                        let lastName = dictionary.lastName
                        let url = dictionary.mediaURL
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(firstName ?? "No") \(lastName ?? "Name")"
                        annotation.subtitle = url
                        annotations.append(annotation)
                        performUIUpdatesOnMain {
                            self.mapView.addAnnotations(annotations)
                            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                            LoaderController.sharedInstance.removeLoader()
                        }
                        
                    }
                    else {
                        LoaderController.sharedInstance.removeLoader()
                        print("No location found for \(dictionary.firstName ?? "No") \(dictionary.lastName ?? "Name")")
                    }
                }
                
            } else {
                LoaderController.sharedInstance.removeLoader()
                OTMClient.sharedInstance.showAlertMessage(title: "", message: "No student found", viewController: self, shouldPop: false)
            }
        }
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func pinLocationClicked(_ sender: Any) {
        let _ = OTMClient.sharedInstance.getAStudentLocation { (success, errorString) in
            if success {
                // case already has a location
                if errorString == nil {
                    let alert = UIAlertController(title: "", message: "You have already posted a student location. Would you like to overWrite your current position?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Overwrite", comment: "Default action"), style: .`default`, handler: { _ in
                        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "NewPinViewController")
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: {(alertAction: UIAlertAction!) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                // case no old location found
                else {
                    print(errorString!)
                    performUIUpdatesOnMain {
                        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "NewPinViewController")
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    
                }
            }
            else {
                // IF NOT SUCCESS
                OTMClient.sharedInstance.showAlertMessage(title: "", message: errorString!, viewController: self, shouldPop: false)
                print(errorString!)
                return
            }
        }
        
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
        
        
    }
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: { (success) in
                    if success == false {
                        print("FAIL TO OPEN URL")
                        return
                    }})
            }
        }
    }
    
}


