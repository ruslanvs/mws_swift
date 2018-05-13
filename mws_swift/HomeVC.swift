//
//  HomeVC.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/19/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import UIKit
//import CoreData

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableData = SchoolModel.shared.getAllSchools( whereIsDeletedIs: false )
    let coreDataEntitiesList = [School.self, Student.self]
//    let jsonDecodedStructsList = [JsonDecodedSchoolStruct.self, JsonDecodedStudentStruct.self]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
//        APISyncController.syncSchools { () in
//            DispatchQueue.main.async {
//                self.tableData = SchoolModel.shared.getAllSchools( whereIsDeletedIs: false )
//                self.tableView.reloadData()
//            }
//        }
        
        
//        APISyncController.sync ( completionHandler: (), entityName: School.self.entity().name, coreDataEntity: School.self, decodingType: JsonDecodedSchoolStruct.self ) { () in
//            DispatchQueue.main.async {
//                print ("we have synced")
//            }
//        }
        
        APISyncController.sync (completionHandler: {
            DispatchQueue.main.async {
                self.tableData = SchoolModel.shared.getAllSchools( whereIsDeletedIs: false )
                self.tableView.reloadData()
                print ("we have synced")
            }
        }, entityName: School.self.entity().name!, coreDataEntity: School.self, decodingType: JsonDecodedSchoolStruct.self)
        
        
        for coreDataEntity in coreDataEntitiesList {
            guard let entityName = coreDataEntity.entity().name else { return }
            let count = CoreDataInterface.shared.getAll(fromEntityName: entityName, type: coreDataEntity).count
            print ( "Core Data entity name and count:", entityName, count )
        }
        for coreDataEntity in coreDataEntitiesList {
            guard let entityName = coreDataEntity.entity().name else { return }
            let latestUpdatedAtDate = CoreDataInterface.shared.getLastUpdatedAtDate(entityName: entityName, type: coreDataEntity)
            print ( "Core Data entity name and latest updated_at date:", entityName, latestUpdatedAtDate )
        }
//        for data in CoreDataInterface.shared.getAll(fromEntityName: School.entity().name!, type: School.self ) {
//            print( "CoreDataInterface returned:", data.title )
//        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

}
