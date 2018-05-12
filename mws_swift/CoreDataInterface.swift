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
    
    func getAll<T> ( whereIsDeletedIs is_deleted: Bool? = nil, from entityName: String, entity: T.Type ) -> [T] {
        
//        guard let entity = entity as? T else {
//            print( "error assigning the class" )
//            return []
//        }
        
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
    
    
    
}
