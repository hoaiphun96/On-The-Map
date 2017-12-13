//
//  OTMStudentInformations.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/6/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

struct StudentInformation {
    
    // MARK: Properties
        var createdAt : String?
        var firstName : String?
        var lastName : String?
        var latitude : Float?
        var longitude : Float?
        var mediaURL : String?
        var objectId: String?
        var uniqueKey: String?
        var updatedAt: String?
        var mapString: String?
    
    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init(dictionary: [String:AnyObject]) {
        createdAt = dictionary[OTMClient.JSONResponseKeys.CreatedAt] as? String
        firstName = dictionary[OTMClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[OTMClient.JSONResponseKeys.LastName] as? String
        latitude = dictionary[OTMClient.JSONResponseKeys.Latitute] as? Float
        longitude = dictionary[OTMClient.JSONResponseKeys.Longitude] as? Float
        mediaURL = dictionary[OTMClient.JSONResponseKeys.MediaURL] as? String
        objectId = dictionary[OTMClient.JSONResponseKeys.ObjectID] as? String
        updatedAt = dictionary[OTMClient.JSONResponseKeys.UpdatedAt] as? String
        uniqueKey = dictionary[OTMClient.JSONResponseKeys.UniqueKey] as? String
        mapString = dictionary[OTMClient.JSONResponseKeys.MapString] as? String
        
    }
    init() {
        createdAt = nil
        firstName = nil
        lastName = nil
        latitude = nil
        longitude = nil
        mediaURL = nil
        objectId = nil
        updatedAt = nil
        uniqueKey = nil
        mapString = nil
    }
    static func studentInformationsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var StudentInformations = [StudentInformation]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            if StudentInformations.contains(StudentInformation(dictionary: result)) == false {
                StudentInformations.append(StudentInformation(dictionary: result))
            }
        }
        return StudentInformations
    }
}

// MARK: - TMDBMovie: Equatable

extension StudentInformation: Equatable {}

func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.uniqueKey == rhs.uniqueKey
}

    

