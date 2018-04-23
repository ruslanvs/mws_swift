//
//  APIInterface.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/22/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import Foundation

class APIInterface {
    static func getAllSchools( completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error? ) -> Void ) {
        let url = URL( string: "http://localhost:8000/schools" )
        let session = URLSession.shared
        let task = session.dataTask( with: url!, completionHandler: completionHandler )
        task.resume()
    }
}
