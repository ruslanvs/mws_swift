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
    
    func getAll ( whereIsDeletedIs is_deleted: Bool? = nil, from entityName: String, entity: School.Type ) -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: entity.entity().name! )
        
        if is_deleted == false {
            let predicate = NSPredicate( format: "is_deleted == 0" ) //>> a workaround with a hardcoded parameter
            request.predicate = predicate
        }
        
        do {
            return try managedObjectContext.fetch( request ) as! [NSManagedObject]
        } catch {
            print( error )
            return []
        }
    }
    
    
    
}
