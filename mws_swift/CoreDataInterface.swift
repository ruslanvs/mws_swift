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
            
            print ("we made it all the way here. Core Data item:", coreDataItem)
            
//            (coreDataItem as! School).title = (jsonItem as! JsonDecodedSchoolStruct).title
//            (coreDataItem as! School).id = (jsonItem as! JsonDecodedSchoolStruct).id
//            (coreDataItem as! School).is_deleted = (jsonItem as! JsonDecodedSchoolStruct).is_deleted
//            (coreDataItem as! School).created_at = (jsonItem as! JsonDecodedSchoolStruct).created_at
//            (coreDataItem as! School).updated_at = (jsonItem as! JsonDecodedSchoolStruct).updated_at
            
            assignValuesByKeys( coreDataItem: coreDataItem, jsonItem: jsonItem )

//            let mirror = Mirror(reflecting: coreDataItem)
//            for child in mirror.children {
//                print( child.label, child.value)
//            (coreDataItem as! School).child.label
//
//            }
            
            
//            coreDataItem.title = jsonItem.title
//            coreDataItem.id = jsonItem.id
//            coreDataItem.is_deleted = jsonItem.is_deleted
//            coreDataItem.created_at = jsonItem.created_at
//            coreDataItem.updated_at = jsonItem.updated_at
            
        }
        saveContext()
    }
    
    func assignValuesByKeys<T, JDT>( coreDataItem: T, jsonItem: JDT ) {
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
    
    override func assignValuesByKeys<T, JDT>(coreDataItem: T, jsonItem: JDT) {
        (coreDataItem as! School).title = (jsonItem as! JsonDecodedSchoolStruct).title
        (coreDataItem as! School).id = (jsonItem as! JsonDecodedSchoolStruct).id
        (coreDataItem as! School).is_deleted = (jsonItem as! JsonDecodedSchoolStruct).is_deleted
        (coreDataItem as! School).created_at = (jsonItem as! JsonDecodedSchoolStruct).created_at
        (coreDataItem as! School).updated_at = (jsonItem as! JsonDecodedSchoolStruct).updated_at
    }
}
