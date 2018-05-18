//
//  APISyncController.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/22/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import Foundation

protocol JsonDecodedSql: Decodable {
    var is_deleted: Bool {get}
    var id: UUID {get}
    var created_at: Date {get}
    var updated_at: Date {get}
}

struct JsonDecodedSchoolStruct: JsonDecodedSql  {
    let is_deleted: Bool
    let id: UUID
    let created_at: Date
    let updated_at: Date
    let title: String
}

struct JsonDecodedStudentStruct: JsonDecodedSql {
    let is_deleted: Bool
    let id: UUID
    let created_at: Date
    let updated_at: Date
    let school_id: UUID
    let name: String
    let score: Int16
}

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
    
    static func sync<CDT, JDT: JsonDecodedSql>( completionHandler: @escaping () -> (), entityName: String, coreDataEntity: CDT.Type, decodingType: JDT.Type ){
    
        print( "Generic Sync" )
        
        let lastUpdatedAtDate = "\(CoreDataInterface.shared.getLastUpdatedAtDate(entityName: entityName, type: coreDataEntity))".replacingOccurrences(of: " ", with: "_")
        print( "Last updated_at date:", lastUpdatedAtDate )
        
        let entityNameForAPI = entityName.lowercased()
        
        let urlString = "http://localhost:8000/\(entityNameForAPI)s_updated_after/\(lastUpdatedAtDate)"
        
        guard let url = URL(string: urlString) else {
            print ("url setting error")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            do {
                let jsonItems = try
                    decoder.decode([JDT].self, from: data)
                print( "updated items:", jsonItems )
                
                if jsonItems.count > 0 {
                    update( jsonItems: jsonItems, entityName: entityName, coreDataEntity: coreDataEntity )
                }
                
            } catch let err {
                print( "JSON parsing error:", err )
            }
            
            completionHandler()
            
            }.resume()
    }
    
    class func update<T, JDT>( jsonItems: [JDT], entityName: String, coreDataEntity: T.Type ) {
    }
    
    static func syncSchools( completionHandler: @escaping () -> () ){
        print( "Sync Schools" )
        
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

class SchoolAPISyncController: APISyncController {
    override class func update<T, JDT>( jsonItems: [JDT], entityName: String, coreDataEntity: T.Type ) {
        _ = SchoolCoreDataInterface.schoolSingleton.batchUpdate( jsonItems: jsonItems, entityName: entityName, coreDataEntity: coreDataEntity )
    }
}

class StudentAPISyncController: APISyncController {
    override class func update<T, JDT>( jsonItems: [JDT], entityName: String, coreDataEntity: T.Type ) {
        _ = StudentCoreDataInterface.studentSingleton.batchUpdate( jsonItems: jsonItems, entityName: entityName, coreDataEntity: coreDataEntity )
    }
}
