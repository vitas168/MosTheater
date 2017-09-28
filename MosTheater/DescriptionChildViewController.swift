//
//  DescriptionChildViewController.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 31/07/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

class DescriptionChildViewController: UIViewController {

    
    // MARK: - Properties

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    
    var address = ""
    var phone = ""
    var desc = ""
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate form with data
        setLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Attempt to set text labels.
    func setLabels() {

        // Check that text labels are loaded into VC else do not set them
        guard addressLabel != nil && phoneLabel != nil && descTextView != nil else { return }
 
        addressLabel.text = address
        phoneLabel.text = phone
        descTextView.text = desc
        descTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // Set property values and populate form with data
    func setValues(address: String, phone: String, desc: String) {
        self.address = address
        self.phone = phone
        self.desc = desc
        setLabels()
    }
    

}
