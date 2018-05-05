//
//  APISyncController.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/22/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import Foundation

struct jsonDecodedSchool: Decodable {
    let id: UUID
    let title: String
    let created_at: Date
    let updated_at: Date
}

protocol APISyncControllerDelegate: class {
    func tableViweReloadData()
}


class APISyncController {
    
    static func initialSync( completionHandler: @escaping () -> () ) {
        print( "Performing initial sync" )
        
        let urlString = "http://localhost:8000/schools"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in

            guard let data = data else { return }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
            let schoolsDecoder = JSONDecoder()
            schoolsDecoder.dateDecodingStrategy = .formatted(dateFormatter)

            do {
                let schools = try
                schoolsDecoder.decode([jsonDecodedSchool].self, from: data)

                for school in schools {
                    _ = SchoolModel.shared.create( title: school.title, id: school.id, created_at: school.created_at, updated_at: school.updated_at )
                }
                
            } catch let jsonDecodingErr {
                print( "JSON parsing error:", jsonDecodingErr )
            }

            completionHandler()
            
        }.resume()
        
    }
    
    static func incrementalSync( completionHandler: @escaping () -> () ){
        print( "Performing incremental sync" )
        
        let lastUpdatedAt = "\(SchoolModel.shared.getLastUpdatedAt())".replacingOccurrences(of: " ", with: "_")
        print( "Last updated_at:", lastUpdatedAt )
        
        let urlString = "http://localhost:8000/schools_updated_after/\(lastUpdatedAt)"
        
        guard let url = URL(string: urlString) else {
            print ("url setting error")
            return
        }
        print("url set to:", url)
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            print("API request")
            guard let data = data else {return}
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
            let schoolsDecoder = JSONDecoder()
            schoolsDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            do {
                let schools = try
                    schoolsDecoder.decode([jsonDecodedSchool].self, from: data)
                print( "updated schools:", schools )
                
                if schools.count > 0 {
                    _ = SchoolModel.shared.batchUpdateSchools( jsonSchools: schools )
                }
                                
            } catch let jsonDecodingErr {
                print( "JSON parsing error:", jsonDecodingErr )
            }
            
            completionHandler()
            
        }.resume()
        
        
    }
    
}
