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
    
    var tableData = SchoolModel.shared.getAllSchools( whereIsDeletedIs: false )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        print( "tableData count =", tableData.count )
        APISyncController.sync { () in
            print("Completion call")
            DispatchQueue.main.async {
                self.tableData = SchoolModel.shared.getAllSchools( whereIsDeletedIs: false )
                self.tableView.reloadData()
            }
        }
    }
    
    func printTableData () {
        print( "Printing table data content:" )
        for item in tableData {
            print( item.title, item.id, item.is_deleted, item.created_at, item.updated_at )
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
