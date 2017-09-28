//
//  WriteReviewChildViewController.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 31/07/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

protocol WriteReviewChildViewControllerDelegate {
    func saveReview(name: String, review: String)
}


class WriteReviewChildViewController: UIViewController {


    // MARK: - Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var delegate: WriteReviewChildViewControllerDelegate?


    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the corner radius of the text view
        reviewTextView.layer.cornerRadius = 5.0
        submitButton.layer.cornerRadius = 5.0
    }
    

    // MARK: - Button handlers
    @IBAction func submitTapped(_ sender: Any) {
    
        // Check if delegate is assigned
        if delegate == nil { return }
        
        // Disable the button to avoid multiple submits
        submitButton.isUserInteractionEnabled = false
        
        // Check that fields are not empty
        if nameTextField.text == nil || nameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || reviewTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
        
            let alert = UIAlertController(title: "Почти получилось!", message: "Пожалуйста, убедитесь, что оба поля ввода заполнены.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Save review to database
        delegate?.saveReview(name: nameTextField.text!, review: reviewTextView.text)
    }

    
    // MARK: - Keyboard functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            hideKeyboard()
    }

    
    func hideKeyboard() {
        nameTextField.resignFirstResponder()
        reviewTextView.resignFirstResponder()
    }
}
