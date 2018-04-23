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
    
    func create( title: String, id: String ) -> School {
        let item = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext ) as! School
        item.title = title
        item.id = id
        saveContext()
        return item
    }
    
    func update( item: School, title: String?, id: String? ) {
        if let title = title {
            item.title = title
        }
        if let id = id {
            item.id = id
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
