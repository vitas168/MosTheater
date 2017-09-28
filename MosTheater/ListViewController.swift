//
//  ListViewController.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 27/06/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

// The ListViewController class provides a list view of all theaters in Moscow
class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TheaterModelDelegate {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var theaterModel = TheaterModel()
    var theaters = [Theater]()
 
    
    // MARK: - Inherited class methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        theaterModel.delegate = self
    }

    
    override func viewDidAppear(_ animated: Bool) {
        // Make a call for a list of theaters
        theaterModel.checkDataVersion()
        theaterModel.getTheaters()
    }
    
    
    // MARK: - TableView delegate methods

    // Implement table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Create custom table cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell") as? TheaterTableViewCell
        
        if let actualCell = cell {
            
            // Set theater name label
            let actualTheater = theaters[indexPath.row]
            actualCell.setPlace(actualTheater)
        
            return actualCell
        }
        
        return UITableViewCell()
    }
    
    // Return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theaters.count
    }
    
    // MARK: - Navigation
    // Do necessary setup before loading detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get selected item
        if let selectedIndex = tableView.indexPathForSelectedRow?.row {
            
            // Check segue id
            if segue.identifier == "showDetail" {
                
                // Create the detail model and set theater
                let detailModel = DetailModel()
                detailModel.theater = theaters[selectedIndex]
            
                // Set the detail model for the detail view controller
                let detailVC = segue.destination as! DetailViewController
                detailVC.model = detailModel
            }
        }
    }

    // MARK: - TheaterModel delegate methods
    func theaterModel(listOf theaters: [Theater]) {
        
        // Assign returned list of theaters to class property
        self.theaters = theaters
        
        // Sort theaters in alphabetical order
        self.theaters = self.theaters.sorted(by: { (t1: Theater, t2: Theater) -> Bool in
            
            return t1.name_ru < t2.name_ru
            
        })

        // Refresh theaters list
        tableView.reloadData()
    }
}
