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
    
    func getAll() -> [School] {
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "School" )
        
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
        
        do {
            let school = try managedObjectContext.fetch( request ) as! [School]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let earliestDate = dateFormatter.date(from: "2000-01-01")
            
            let date = school.count > 0 ? school[0].updated_at : earliestDate
            
            return date!
        } catch {
            print ( error )
            return Date()
        }
    }
    
    func create( title: String, id: UUID, created_at: Date, updated_at: Date ) -> School {
        print( "create" )
        let item = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext ) as! School
        item.title = title
        item.id = id
        item.created_at = created_at
        item.updated_at = updated_at
        saveContext()
        return item
    }
    
    func batchUpdateSchools( jsonSchools: [jsonDecodedSchool] ) {
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "School" )
        for jsonSchool in jsonSchools {
            let predicate = NSPredicate( format: "id == %@", jsonSchool.id as CVarArg )
            request.predicate = predicate
            
            do {
                var coreDataSchool = try managedObjectContext.fetch(request) as! [School]
                coreDataSchool[0].title = jsonSchool.title
                coreDataSchool[0].created_at = jsonSchool.created_at
                coreDataSchool[0].updated_at = jsonSchool.updated_at
            } catch {
                print ( error )
            }
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
