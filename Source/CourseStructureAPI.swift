//
//  ServerAPI.swift
//  edX
//
//  Created by Akiva Leffert on 5/20/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

public struct CourseOutlineAPI {
    public struct Parameters {
        let fields : [String]
        let blockCount : [String]
        let blockJSON : [String:AnyObject]
        
        var query : [String:JSON] {
            return [
                    "fields" : JSON(",".join(fields)),
                    "block_count" : JSON(",".join(blockCount)),
                    "block_json" : JSON(blockJSON)
            ]
        }
    }
    
    static func fromData(response : NSHTTPURLResponse?, data : NSData?) -> Result<CourseOutline> {
        return Result(jsonData : data, error : NSError.oex_courseContentLoadError()) {
            return CourseOutline(json: $0)
        }
    }
    
    static func requestWithCourseID(courseID : String) -> NetworkRequest<CourseOutline> {
        let parameters = Parameters(
            fields : ["graded", "responsive_ui", "format"],
            blockCount : [CourseBlock.Category.Video.rawValue],
            blockJSON : [CourseBlock.Category.Video.rawValue : ["profile" : OEXVideoEncoding.knownEncodingNames()]]
        )
        return NetworkRequest(
            method : .GET,
            path : "api/course_structure/v0/courses/{courseID}/blocks+navigation/".oex_formatWithParameters(["courseID" : courseID]),
            requiresAuth : true,
            query : parameters.query,
            deserializer : fromData
        )
    }
}
