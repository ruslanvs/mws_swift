//
//  DataModel.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/20/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import UIKit
import CoreData

class SchoolModel {
    private var managedObjectContext = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    private var appDelegate = ( UIApplication.shared.delegate as! AppDelegate )
    
    static let shared = SchoolModel()
    
    func getAllSchools( whereIsDeletedIs is_deleted: Bool? = nil ) -> [School] {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "School" )
        
        if is_deleted == false {
            let predicate = NSPredicate( format: "is_deleted == 0" ) //>> a workaround with a hardcoded parameter
            request.predicate = predicate
        }
        
//        if let is_deleted = is_deleted {
//            print ( "is_deleted is:", is_deleted )
//            let predicate = NSPredicate( format: "is_deleted == %@", false ) //>> Why does this produce a nil in the request?
//            request.predicate = predicate
//        }

        do {
            return try managedObjectContext.fetch( request ) as! [School]
        } catch {
            print ( error )
            return []
        }
    }
    
    func getLastUpdatedAt() -> Date {
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "School" )
        let sortDescriptor = NSSortDescriptor( key: "updated_at", ascending: false )
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        
        var school = [School]() //>> can I do this as a constant?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let earliestDate = dateFormatter.date(from: "1988-01-01")
        
        do {
            school = try managedObjectContext.fetch( request ) as! [School]
        } catch {
            print ( "Error:", error )
            return Date()
        }
        
        guard let date = school.count > 0 ? school[0].updated_at : earliestDate else {
            print( "error assigning a date" )
            return Date()
        }
        
        return date
    }
    
    func batchUpdateSchools( jsonSchools: [jsonDecodedSchool] ) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "School" )
        
        for jsonSchool in jsonSchools {
            let predicate = NSPredicate( format: "id == %@", jsonSchool.id as CVarArg )
            request.predicate = predicate
            
            var coreDataSchoolArr = [School]()
            
            do {
                coreDataSchoolArr = try managedObjectContext.fetch(request) as! [School]
            } catch {
                print ( error )
            }
            
            let coreDataSchool: School
            
            if coreDataSchoolArr.count == 1 {
                coreDataSchool = coreDataSchoolArr[0]
            } else if coreDataSchoolArr.count == 0 {
                coreDataSchool = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext ) as! School
            } else {
                print( "error in fetching a school from Core Data" )
                return
            }
            
            coreDataSchool.title = jsonSchool.title
            coreDataSchool.id = jsonSchool.id
            coreDataSchool.is_deleted = jsonSchool.is_deleted
            coreDataSchool.created_at = jsonSchool.created_at
            coreDataSchool.updated_at = jsonSchool.updated_at
            
        }
        saveContext()
    }
    
    func delete( item: School ) {
        managedObjectContext.delete( item )
        saveContext()
    }
    
    func saveContext() {
        appDelegate.saveContext()
    }
}
