//
//  OTMConstants.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/6/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

extension OTMClient {
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Login
        static let Username = "username"
        static let Password = "password"
        
        // MARK: results
        static let Results = "results"
        
        // MARK: Student Location
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MediaURL = "mediaURL"
        static let MapString = "mapString"
        static let Latitute = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ACL = "ACL"
}
}

