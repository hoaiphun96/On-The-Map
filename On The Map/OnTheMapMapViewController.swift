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
        let _ = OTMClient.sharedInstance().getStudentLocations { (locations, error) in
            if let locations = locations {
                OTMClient.sharedInstance().studentInformationModel = locations
                var annotations = [MKPointAnnotation]()
                for dictionary in OTMClient.sharedInstance().studentInformationModel {
                    if let latdouble = dictionary.latitude, let longdouble = dictionary.longitude{
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
                        }
                        
                    }
                    else {
                        print("Can't find longitude and latitude in \(dictionary)'s data")
                    }
                }
                
            } else {
                print("No locations found")
            }
        }
    }
    
    
    @IBAction func pinLocationClicked(_ sender: Any) {
        // TODO: check if a pin already existed
        let _ = OTMClient.sharedInstance().getAStudentLocation { (success, errorString) in
            if success {
                // case already has a location
                if errorString == nil {
                    // TODO: SHOW ALERT AND ASK IF YOU WANT TO UPDATE (OVERWRITE, CANCEL), IF OVERWRITE CALL POST NEW PIN FUNCTION ELSE DISMISS ALERT
                    let alert = UIAlertController(title: nil, message: "You Have Already Posted A Student Location. Would You Like To OverWrite Your Current Position?", preferredStyle: .alert)
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
                print("THIS URL", toOpen)
                app.open(URL(string: toOpen)!, options: [:], completionHandler: { (success) in
                    if success == false {
                        print("FAIL TO OPEN URL")
                        return
                    }})
            }
        }
    }
    
}


