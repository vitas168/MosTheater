//
//  ReviewsChildViewController.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 31/07/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

class ReviewsChildViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    @IBOutlet weak var reviewTableView: UITableView!

    var reviews = [Review]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set self as the datasource and delegate of the TableView
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        // Enable autoresize for table cell
        reviewTableView.rowHeight = UITableViewAutomaticDimension
        reviewTableView.estimatedRowHeight = 100
    }
    
    
    // Update review data if new reviews are posted
    func reloadReviewsData(newReviewsData:[Review]) {
        
        // Set the new reviews array
        reviews = newReviewsData
        
        // Reload the table
        reviewTableView.reloadData()
    }

    
    // MARK: - TableView delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        
        // Get current review item
        let review = reviews[indexPath.row]
        
        // Set review name label
        let nameLabel = cell.viewWithTag(2) as! UILabel
        nameLabel.text = review.name
        
        // Set review text label
        let textLabel = cell.viewWithTag(3) as! UILabel
        textLabel.text = review.text
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        return reviews.count
    }
    
}
