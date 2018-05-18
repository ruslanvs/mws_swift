//
//  CoreDataInterface.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 5/10/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import UIKit
import CoreData

class CoreDataInterface {
    
    private var managedObjectContext = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    private var appDelegate = ( UIApplication.shared.delegate as! AppDelegate )
    
    static let shared = CoreDataInterface()
    
    func getAll<T> ( whereIsDeletedIs is_deleted: Bool? = nil, fromEntityName entityName: String, type: T.Type ) -> [T] {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: entityName )
        
        if is_deleted == false {
            let predicate = NSPredicate( format: "is_deleted == 0" ) //>> a workaround with a hardcoded parameter
            request.predicate = predicate
        }
        
        do {
            return try managedObjectContext.fetch( request ) as! [T]
        } catch {
            print( error )
            return []
        }
    }
    
    func getOne<T>( withId id: UUID, fromEntityName entityName: String, type: T.Type ) -> T? {
    
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: entityName )
        let predicate = NSPredicate( format: "id == %@", id as CVarArg )
        request.predicate = predicate
        
        do {
            let items = try managedObjectContext.fetch( request ) as! [T]
            if items.count > 0 {
                return items[0]
            } else {
                return nil
            }
        } catch {
            print( error )
            return nil
        }
    }
    
    func getLastUpdatedAtDate<T>(entityName: String, type: T.Type) -> Date {

        let request = NSFetchRequest<NSFetchRequestResult>( entityName: entityName )

        let sortDescriptor = NSSortDescriptor( key: "updated_at", ascending: false )
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1

        var coreDataItems = [T]()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let earliestDate = dateFormatter.date(from: "1988-01-01")
        
        do {
            coreDataItems = try managedObjectContext.fetch( request ) as! [T]
        } catch {
            print ( "Error:", error )
            return Date()
        }
        
        guard let date = coreDataItems.count > 0 ? (coreDataItems[0] as! SQLObject).updated_at : earliestDate else {
            print( "error assigning a date" )
            return Date()
        }
        
        return date
    }
    
    func batchUpdate<T, JDT>( jsonItems: [JDT], entityName: String, coreDataEntity: T.Type ) {
        print ("Generic batch update")
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: entityName )
        
        for jsonItem in jsonItems {
            
            let predicate = NSPredicate( format: "id == %@", (jsonItem as! JsonDecodedSql).id as CVarArg )
            request.predicate = predicate
            
            var coreDataItems = [T]()
            
            do {
                coreDataItems = try managedObjectContext.fetch(request) as! [T]
            } catch {
                print ( error )
            }
            
            var coreDataItem: T
            
            if coreDataItems.count == 1 {
                coreDataItem = coreDataItems[0]
            } else if coreDataItems.count == 0 {
                coreDataItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext ) as! T
            } else {
                print( "error fetching from Core Data" )
                return
            }
            
            let item = assignValuesByKeys( coreDataItem: coreDataItem, jsonItem: jsonItem )
            setRelationships( for: item )
        }
        saveContext()
    }
    
    func assignValuesByKeys<T, JDT>( coreDataItem: T, jsonItem: JDT ) -> T {
        print( "an abstract method hit" )
        return coreDataItem
    }
    
    func setRelationships<T>( for item: T ){
        print( "an abstract method hit" )
    }

//    func delete( item: School ) {
//        managedObjectContext.delete( item )
//        saveContext()
//    }
    
    func saveContext() {
        appDelegate.saveContext()
    }
}

class SchoolCoreDataInterface: CoreDataInterface {
    
    static let schoolSingleton = SchoolCoreDataInterface()
    
    override func assignValuesByKeys<T, JDT>(coreDataItem: T, jsonItem: JDT) -> T {
        print( "Schools assign values by keys function" )
        guard let school = coreDataItem as? School else {return coreDataItem}
        guard let jsonItem = jsonItem as? JsonDecodedSchoolStruct else {return coreDataItem}
        
        school.title = jsonItem.title
        school.id = jsonItem.id
        school.is_deleted = jsonItem.is_deleted
        school.created_at = jsonItem.created_at
        school.updated_at = jsonItem.updated_at
        
        return coreDataItem
    }    
}

class StudentCoreDataInterface: CoreDataInterface {
    
    static let studentSingleton = StudentCoreDataInterface()
    
    override func assignValuesByKeys<T, JDT>(coreDataItem: T, jsonItem: JDT) -> T {
        print( "Student assign values by keys function" )
        
        guard let student = coreDataItem as? Student else {return coreDataItem}
        guard let jsonItem = jsonItem as? JsonDecodedStudentStruct else {return coreDataItem}
        
        student.name = jsonItem.name
        student.score = jsonItem.score
        student.school_id = jsonItem.school_id
        student.id = jsonItem.id
        student.is_deleted = jsonItem.is_deleted
        student.created_at = jsonItem.created_at
        student.updated_at = jsonItem.updated_at
        
        return coreDataItem
    }
    
    override func setRelationships<T>( for item: T ){
        guard let student = item as? Student else {return}
        guard let school_id = student.school_id else {return}
        let school = self.getOne(withId: school_id, fromEntityName: "School", type: School.self)
        student.school = school
    }
}
