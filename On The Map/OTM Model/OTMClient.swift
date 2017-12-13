//
//  OTMClient.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/5/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//
import UIKit
import Foundation
class OTMClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    // authentication state
    var sessionID : String?
    var username: String?
    var password: String?
    
    //Student Locations and this Student Location Model
    var studentInformationModel = [StudentInformation]()
    var myAccount = StudentInformation()

    func authenticateWithViewController(_ viewController: UIViewController,_ parameters: [String:AnyObject], completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username!)\", \"password\": \"\(password!)\"}}".data(using: .utf8)
    
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error!)
                completionHandlerForAuth(false, "Login Failed")
                return
            }

            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            let parsedResult: [String:AnyObject]!
            do {
            parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForAuth(false, "Could not parse the data as JSON: '\(newData.debugDescription)'")
                return
            }
            
            if let _ = parsedResult["status"], let errorMessage = parsedResult["error"] {
                completionHandlerForAuth(false, "\(errorMessage)")
                return
            }
            
            let thissession = parsedResult["session"] as! [String: String]
            self.sessionID = thissession["id"]
            let thisaccount = parsedResult["account"] as! [String: AnyObject]
            let key = thisaccount["key"]
            self.myAccount.uniqueKey = key as? String
            
            completionHandlerForAuth(true,nil)
        } 
        
        task.resume()
        return task
    }
    
    // MARK: POSTING NEW LOCATION
    func postStudentLocation(parameters: [String: AnyObject],completionHandlerForPin: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(self.myAccount.uniqueKey!)\", \"firstName\": \"\(self.myAccount.firstName!)\", \"lastName\": \"\(self.myAccount.lastName!)\",\"mapString\": \"\(parameters[OTMClient.JSONResponseKeys.MapString]!)\", \"mediaURL\": \"\(parameters[OTMClient.JSONResponseKeys.MediaURL]!)\",\"latitude\": \(parameters[OTMClient.JSONResponseKeys.Latitute]!), \"longitude\": \(parameters[OTMClient.JSONResponseKeys.Longitude]!)}".data(using: .utf8)

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error!)
                completionHandlerForPin(false, "Pin Failed")
                return
            }
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForPin(false, "Could not parse the data as JSON: '\(data.debugDescription)'")
                return
            }
            self.myAccount.createdAt = parsedResult["createdAt"] as? String
            self.myAccount.objectId = parsedResult["objectId"] as? String
            self.myAccount.mediaURL = parameters["mediaURL"] as? String
            
            completionHandlerForPin(true, nil)
           
        }
        task.resume()
        return task
    }
    
    // MARK: GET USER INFO
    func getStudentLocations(completionHandlerForGetStudentLocations: @escaping (_ locations: [StudentInformation]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error!)
                completionHandlerForGetStudentLocations(nil, "Get Students Location Failed")
                return
            }
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForGetStudentLocations(nil, "Could not parse the data as JSON: '\(data.debugDescription)'")
                return
            }

            if let results = parsedResult?["results"] as? [[String:AnyObject]] {
                let studentInformations = StudentInformation.studentInformationsFromResults(results)
                completionHandlerForGetStudentLocations(studentInformations, nil)
            } else {
                //TODO: CHECK THIS CASE
                completionHandlerForGetStudentLocations(nil,"Cannot parse GetStudentLocations")
                return
            }
        }
        task.resume()
        return task
    }
    
    // MARK: Get public user data
    func getPublicUserData (completionHandlerForGetPublicUserData: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(self.myAccount.uniqueKey!)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error!)
                completionHandlerForGetPublicUserData(false, "Get Public User Data failed")
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
                
            } catch {
                completionHandlerForGetPublicUserData(false, "Could not parse the data as JSON: '\(newData.debugDescription)'")
                return
            }
            let thisuser = parsedResult["user"]
            self.myAccount.firstName = thisuser!["first_name"] as? String
            self.myAccount.lastName = thisuser!["last_name"] as? String
            completionHandlerForGetPublicUserData(true, nil)
        }
        task.resume()
        return task
    }
    
    // MARK: PUTTING A STUDENT LOCATION
    func puttingStudentLocation(_ parameters: [String: AnyObject], completionHandlerForPutStudentLocation: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(self.myAccount.objectId!)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(self.myAccount.uniqueKey!)\", \"firstName\": \"\(self.myAccount.firstName!)\", \"lastName\": \"\(self.myAccount.lastName!)\",\"mapString\": \"\(self.myAccount.mapString!)\", \"mediaURL\": \"\(parameters["mediaURL"]!)\",\"latitude\": \(parameters["latitude"]!), \"longitude\": \(parameters["longitude"]!)}".data(using: .utf8)
        print("{\"uniqueKey\": \"\(self.myAccount.uniqueKey!)\", \"firstName\": \"\(self.myAccount.firstName!)\", \"lastName\": \"\(self.myAccount.lastName!)\",\"mapString\": \"\(self.myAccount.mapString!)\", \"mediaURL\": \"\(parameters["mediaURL"]!)\",\"latitude\": \(parameters["latitude"]!), \"longitude\": \(parameters["longitude"]!)}")
    
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                print("Posting new location failed")
                completionHandlerForPutStudentLocation(false, error?.localizedDescription)
                return
            }
            // TODO: UPDATE updatedAt
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForPutStudentLocation(false, "Could not parse the data as JSON: '\(data.debugDescription)'")
                return
            }
            print("PARSED RESULT AT PUT NEW LOCATION", parsedResult)
            self.myAccount.updatedAt = parsedResult[OTMClient.JSONResponseKeys.UpdatedAt] as? String
            self.myAccount.mediaURL = parameters["mediaURL"] as? String
            self.myAccount.mapString = parameters["mapString"] as? String
            completionHandlerForPutStudentLocation(true, nil)
        }
        task.resume()
        return task
    }
    
    //
    func getAStudentLocation(completionHandlerForGetAStudentLocation: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let txtAppend = String(self.myAccount.uniqueKey!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where={\"uniqueKey\":\"\(txtAppend!)\"}"
        let url = NSURL(string: (urlString as NSString).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
      
        var request = URLRequest(url: url! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerForGetAStudentLocation(false, "getAStudentLocation failed")
                print("getastudentlocation failed")
                return
            }
            let parsedResult: [String:AnyObject]
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                print("GET A STUDENT LOCATION PARSEDRESULT", parsedResult)
            } catch {
                completionHandlerForGetAStudentLocation(false, "Could not parse the data as JSON: '\(data.debugDescription)'")
                return
            }
            //UPDATE LOCATION, CREATED AT
            let results = parsedResult["results"] as! [[String: AnyObject]]
            if results.count > 0 {
                self.myAccount = StudentInformation(dictionary: results[0])
                completionHandlerForGetAStudentLocation(true, nil)
            }
            else {
                completionHandlerForGetAStudentLocation(true, "No past location posted")
            } 
        }
        task.resume()
        return task
    }
    
    func showAlertMessage(title: String, message: String, viewController: UIViewController, shouldPop: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            if shouldPop {
                viewController.navigationController?.popViewController(animated: true)
            }
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}
