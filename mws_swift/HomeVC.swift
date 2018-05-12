//
//  HomeVC.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/19/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableData = SchoolModel.shared.getAllSchools( whereIsDeletedIs: false )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        APISyncController.syncSchools { () in
            DispatchQueue.main.async {
                self.tableData = SchoolModel.shared.getAllSchools( whereIsDeletedIs: false )
                self.tableView.reloadData()
            }
        }
        for data in CoreDataInterface.shared.getAll(from: "School", entity: School.self ) {
            print( "CoreDataInterface returned:", data.title )
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
