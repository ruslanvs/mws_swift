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

class APISyncController {
    
    static func initialSync(){
        
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
                    SchoolModel.shared.create( title: school.title, id: school.id, created_at: school.created_at, updated_at: school.updated_at )
                }
            } catch let jsonDecodingErr {
                print( "JSON parsing error:", jsonDecodingErr )
            }
        }.resume()
        
    }
    
    static func incrementalSync(){
        let lastUpdatedAt = "\(SchoolModel.shared.getLastUpdatedAt())".replacingOccurrences(of: " ", with: "_")
        print( "Incremental sync for after:", lastUpdatedAt )
        
        
        let urlString = "http://localhost:8000/schools_updated_after/\(lastUpdatedAt)"
//        let urlString = "http://localhost:8000/schools_updated_after/2018-05-02_19:30:27"
        print( "url string:", urlString )
        
        guard let url = URL(string: urlString) else {
            print ("url set error")
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
                print("updates schools:", schools)
                
            } catch let jsonDecodingErr {
                print( "JSON parsing error:", jsonDecodingErr )
            }
            
        }.resume()
        
        
        
        
    }
    
}
