//
//  APISyncController.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/22/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import Foundation

struct jsonDecodedSchool: Decodable {
    let is_deleted: Bool
    let id: UUID
    let title: String
    let created_at: Date
    let updated_at: Date
}

struct jsonDecodedStudent: Decodable {
    let is_deleted: Bool
    let id: UUID
    let school_id: UUID
    let name: String
    let score: Decimal
    let created_at: Date
    let updated_at: Date
}


class APISyncController {
    
//    static func syncStudents( completionHandler: @escaping () -> () ){
//        print( "Sync" )
//
//        let lastUpdatedAtOfStudents = "\(StudentModel.shared.getLastUpdatedAtOfSchools())".replacingOccurrences(of: " ", with: "_")
//        print( "Last updated_at date:", lastUpdatedAtOfStudents )
//
//        let urlString = "http://localhost:8000/students_updated_after/\(lastUpdatedAtOfStudents)"
//
//        guard let url = URL(string: urlString) else {
//            print ("url setting error")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { (data, response, err) in
//            guard let data = data else {return}
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
//            let schoolsDecoder = JSONDecoder()
//            schoolsDecoder.dateDecodingStrategy = .formatted(dateFormatter)
//
//            do {
//                let schools = try
//                    schoolsDecoder.decode([jsonDecodedSchool].self, from: data)
//                print( "updated schools:", schools )
//
//                if schools.count > 0 {
//                    _ = SchoolModel.shared.batchUpdateSchools( jsonSchools: schools )
//                }
//
//            } catch let jsonDecodingErr {
//                print( "JSON parsing error:", jsonDecodingErr )
//            }
//
//            completionHandler()
//
//            }.resume()
//    }
    
    static func syncSchools( completionHandler: @escaping () -> () ){
        print( "Sync" )
        
        let lastUpdatedAtOfSchools = "\(SchoolModel.shared.getLastUpdatedAtOfSchools())".replacingOccurrences(of: " ", with: "_")
        print( "Last updated_at date:", lastUpdatedAtOfSchools )
        
        let urlString = "http://localhost:8000/schools_updated_after/\(lastUpdatedAtOfSchools)"
        
        guard let url = URL(string: urlString) else {
            print ("url setting error")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
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
