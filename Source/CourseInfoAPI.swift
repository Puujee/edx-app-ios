//
//  CourseInfoAPI.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 23/06/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit


public struct CourseInfoAPI {
    
    static func handoutsDeserializer(response : NSHTTPURLResponse?, data : NSData?) -> Result<String> {
        return data.toResult(nil).flatMap {data -> Result<AnyObject> in
            var error : NSError? = nil
            let result : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &error)
            return result.toResult(error)
            }.flatMap {json in
                let jsonObject = JSON(json)
                return jsonObject["handouts_html"].string.toResult(NSError.oex_unknownError())
        }
    }
    
    public static func getHandoutsFromURLString(URLString: String!) -> NetworkRequest<String> {
        return NetworkRequest(
            method: HTTPMethod.GET,
            path : URLString,
            requiresAuth : true,
            deserializer: handoutsDeserializer)
    }
}