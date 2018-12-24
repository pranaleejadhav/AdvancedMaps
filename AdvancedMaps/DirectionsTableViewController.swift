//
//  DirectionsTableViewController.swift
//  AdvancedMaps
//
//  Created by Pranalee Jadhav on 12/24/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import UIKit

class DirectionsTableViewController: UITableViewController {
    var directions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionsCell", for: indexPath)
        cell.textLabel?.text = self.directions[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.directions.count
    }
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
    

}
