//
//  APIDataVC.swift
//  mws_swift
//
//  Created by Ruslan Suvorov on 4/22/18.
//  Copyright © 2018 Ruslan Suvorov. All rights reserved.
//

import UIKit

class APIDataVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var tableData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        APIInterface.getAllSchools(completionHandler: {
            data, response, error in do {
                if let jsonResult = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.mutableContainers ) as? NSArray {
                    for school in jsonResult {
                        let schoolDict = school as! NSDictionary
                        print( schoolDict )                        
                        self.tableData.append( schoolDict["title"]! as! String )
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print( "something went wrong" )
            }
        })
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension APIDataVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "APITableCell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
}
