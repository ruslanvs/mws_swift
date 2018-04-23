//
//  APISyncController.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/22/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import Foundation

class APISyncController {
    
    static func initialSync(){
        APIInterface.getAllSchools(completionHandler: {
            data, response, error in do {
                if let jsonResult = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers ) as? NSArray {
                    for school in jsonResult {
                        let schoolDict = school as! NSDictionary
                        print( schoolDict )
                        let title = (schoolDict["title"] as! String)
                        let id = (schoolDict["id"] as! String)
                        SchoolModel.shared.create( title: title, id: id )
                    }
                }
            } catch {
                print( "something went wrong" )
            }
        })

    }
    
    static func incrementalSync(){
        
    }
    
}
