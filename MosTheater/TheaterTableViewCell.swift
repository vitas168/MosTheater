//
//  TheaterTableViewCell.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 21/08/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

class TheaterTableViewCell: UITableViewCell, FirebaseManagerDelegate {
    // MARK: - Properties
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var firManager:FirebaseManager?
    
    var theaterForDisplay:Theater?
    
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    // MARK: - Functions
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func setPlace(_ theater:Theater) {
        
        // Set a reference to place
        self.theaterForDisplay = theater
        
        // Set the name label
        nameLabel.text = theater.name_ru
        
        // Fetch the image
        if firManager == nil {
            firManager = FirebaseManager()
            firManager?.delegate = self
        }
        firManager?.getImageFromDatabase(imageName: self.theaterForDisplay!.smallImageName)
    }
   
    
    // MARK: - FirebaseManagerDelegate Methods
    func firebaseManager(imageName: String, imageData: Data) {
        
        // Set the imageview with the image data
        if imageName == theaterForDisplay?.smallImageName {
            cellImageView.image = UIImage(data: imageData)
        }
        
    }
}
