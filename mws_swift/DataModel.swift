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
    
    func create( title: String ) -> School {
        let item = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext ) as! School
        item.title = title
        saveContext()
        return item
    }
    
    func saveContext() {
        appDelegate.saveContext()
    }
}
