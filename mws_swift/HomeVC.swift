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
    
    var tableData = SchoolModel.shared.getAll()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        if tableData.count == 0 {
            seedData()
        }

    }
    
    func seedData() {
        let schoolTitles = ["Hogwarts", "Beauxbatons", "Castelobruxo", "Durmstrang Institute", "Ilvermorny"]
        for title in schoolTitles {
            SchoolModel.shared.create(title: title)
        }
        tableData = SchoolModel.shared.getAll()
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
