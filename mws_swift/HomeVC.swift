//
//  HomeVC.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/19/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableData = CoreDataInterface.shared.getAll( whereIsDeletedIs: false, fromEntityName: School.entity().name!, type: School.self)
    
    let coreDataEntitiesList = [School.self, Student.self]
//    let jsonDecodedStructsList = [JsonDecodedSchoolStruct.self, JsonDecodedStudentStruct.self]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print( "Hello from ViewDidLoad" )
        tableView.dataSource = self
        tableView.delegate = self
        
        SchoolAPISyncController.sync (completionHandler: {
            
            StudentAPISyncController.sync (completionHandler: {
                for data in CoreDataInterface.shared.getAll(fromEntityName: Student.entity().name!, type: Student.self ) {
                    print( "CoreDataInterface returned:", data.name, data.score, data.school?.title )
                }
            }, entityName: Student.self.entity().name!, coreDataEntity: Student.self, decodingType: JsonDecodedStudentStruct.self)
            
            DispatchQueue.main.async {
                self.tableData = CoreDataInterface.shared.getAll( whereIsDeletedIs: false, fromEntityName: School.entity().name!, type: School.self)
                self.tableView.reloadData()
            }
        }, entityName: School.self.entity().name!, coreDataEntity: School.self, decodingType: JsonDecodedSchoolStruct.self)

        
        for coreDataEntity in coreDataEntitiesList {
            guard let entityName = coreDataEntity.entity().name else {return}
            let count = CoreDataInterface.shared.getAll(fromEntityName: entityName, type: coreDataEntity).count
            let latestUpdatedAtDate = CoreDataInterface.shared.getLastUpdatedAtDate(entityName: entityName, type: coreDataEntity)
            print ( "Core Data entity name, count and latestUpdatedAtDate:", entityName, count, latestUpdatedAtDate )
        }
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
