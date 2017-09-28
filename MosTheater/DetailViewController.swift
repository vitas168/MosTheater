//
//  DetailViewController.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 23/07/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, DetailModelDelegate, WriteReviewChildViewControllerDelegate {

    // MARK: - Properties
    var model: DetailModel?
    var theater: Theater?
    var currentViewController: UIViewController?
    var writeReviewChildVC: WriteReviewChildViewController?

   
    @IBOutlet weak var theaterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var descSectionButton: UIButton!
    @IBOutlet weak var reviewSectionButton: UIButton!
    @IBOutlet weak var writeReviewSectionButton: UIButton!
    
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
 
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register to listen for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardIsShowing(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardIsHiding(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // Assign self as delegate to DetailModel and fetch metadata
        if let actualModel = model {
            actualModel.delegate = self
            actualModel.getMetadata()
        }
        
        if let actualWriteReviewChildVC = writeReviewChildVC {
            actualWriteReviewChildVC.delegate = self
        }
    }
    
    
    // Close Firebase data observers when leaving particular theater screen
    override func viewWillDisappear(_ animated: Bool) {
        if let actualModel = model {
            actualModel.closeObservers()
        }
    }

    
    // Display theater metadata
    func displayMetadata() {
        if theater == nil {
            return
        }
        
        // Show theater name
        nameLabel.text = theater!.name_ru
        
        // Get theater image
        model?.getImage(imageName: theater!.detailImageName)
        
        // Set description
        if type(of: currentViewController!) == DescriptionChildViewController.self {
            (currentViewController as? DescriptionChildViewController)?.setValues(address: theater!.address, phone: theater!.phone, desc: theater!.desc)
        }
            // In case ReviewsChildViewController is already displayed we call this function to refresh reviews data
        else if type(of: currentViewController!) == ReviewsChildViewController.self {
            if theater!.reviews.count > 0 {
                let reviewsVC = currentViewController as! ReviewsChildViewController
                reviewsVC.reloadReviewsData(newReviewsData: theater!.reviews)
            }
        }
    }

    
    // MARK: - DetailModel delegate methods
    func detailModel(metadataFor theater: Theater) {
        self.theater = theater
        displayMetadata()
    }
    
    
    func detailModel(imageName: String, imageData: Data) {
        // Detail model has returned the image data
        // Set the image view
        let image = UIImage(data: imageData)
        
        if let actualImage = image {
            theaterImageView.image = actualImage
        }
    }
    

    // Callback function to report error
    func detailModelSaveReviewError() {
        // There was an error saving review. Show an alert.
        let alertController = UIAlertController(title: "Ошибка", message: "Ошибка сохранения данных!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: false, completion: nil)
    }
    
    
    // Callback function if save is successful
    func detailModelSaveReviewSuccess(reviews: [Review]) {

        // Update reviews
        theater?.reviews = reviews
        
        // Saving review was a success. Move the user to Reviews Child VC
        sectionButtonTapped(reviewSectionButton)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set the currentViewController property to the Description child view controller
        // because that's the first one that is shown in the container view
        currentViewController = segue.destination
        
    }
    
    
    // Switch between sections and set up child view controllers
    @IBAction func sectionButtonTapped(_ sender: UIButton) {
        
        var toVC: UIViewController?
        
        // See which tag triggered this
        switch sender.tag {
        case 1:
            // Description button tapped
        
            // Create an instance of the Description Child VC
            toVC = storyboard?.instantiateViewController(withIdentifier: "DescriptionChildVC")
            if let descVC = toVC, let actualTheater = theater  {
                (descVC as! DescriptionChildViewController).setValues(address: actualTheater.address, phone: actualTheater.phone, desc: actualTheater.desc)
            }
        
        case 2:
        // Reviews button tapped

            // Create an instance of the Reviews Child VC
            toVC = storyboard?.instantiateViewController(withIdentifier: "ReviewsChildVC")
            if let reviewsVC = toVC, let actualTheater = theater  {
                (reviewsVC as! ReviewsChildViewController).reviews = actualTheater.reviews
            }

        case 3:
        // Write reviews button tapped

            // Create an instance of the WriteReview Child VC
            toVC = storyboard?.instantiateViewController(withIdentifier: "WriteReviewChildVC")
            if let writeReviewVC = toVC {
                (writeReviewVC as! WriteReviewChildViewController).delegate = self
            }

        default:

            // Create an instance of the Description Child VC
            toVC = storyboard?.instantiateViewController(withIdentifier: "DescriptionChildVC")
            if let descVC = toVC, let actualTheater = theater  {
                (descVC as! DescriptionChildViewController).setValues(address: actualTheater.address, phone: actualTheater.phone, desc: actualTheater.desc)
            }
        }
    
        // Switch between view controllers if both are not nil
        if let destinationVC = toVC, let currentVC = currentViewController {
            switchChildViewControllers(fromVC: currentVC, toVC: destinationVC)
        }
        
    }
    
    
    // Switch between child view controllers
    func switchChildViewControllers(fromVC: UIViewController, toVC: UIViewController) {
        
        // Tell the current VC that it's transitioning
        fromVC.willMove(toParentViewController: nil)
        
        // Add the new VC
        self.addChildViewController(toVC)
        containerView.addSubview(toVC.view)
        
        // Size the frame of the toVC
        toVC.view.frame = containerView.bounds
        
        // Set the new VC alpha to 0
        toVC.view.alpha = 0
        
        // Animate the new VC alpha to 1 and the old VC alpha to 0
        UIView.animate ( withDuration: 0.5, animations: {
            
            toVC.view.alpha = 1
            fromVC.view.alpha = 0
        })  { (Bool) in
            
            // Remove the old VC
            fromVC.view.removeFromSuperview()
            fromVC.removeFromParentViewController()
            
            // Tell the new VC that it has transitioned
            toVC.didMove(toParentViewController: self)
            
            // Set the currentViewController property to toVC
            self.currentViewController = toVC

        }
    }


    // MARK: - Button actions
    @IBAction func backButtonTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // This function provides user with choices of mapping applications (if any) 
    // It then opens up the chosen mapping app to display route to theater
    @IBAction func routeButtonTapped(_ sender: Any) {
    
        if theater == nil { return }

        // Create a portion of URL holding theater address
        let modifiedAddress = theater!.address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        // Check if any mapping app in addition to Apple maps is installed
        let canOpenGoogleMaps = UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
        let canOpenYandexNavi = UIApplication.shared.canOpenURL(URL(string: "yandexnavi://")!)
        let canOpenYandexMaps = UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!)
        
        // If Apple maps is not the only mapping appication, display choices in action sheet
        if canOpenGoogleMaps || canOpenYandexNavi || canOpenYandexMaps {
        
            // Create action sheet
            let actSheet = UIAlertController(title: "Выбор приложения", message: "Пожалуйста, выберите приложение для построения маршрута.", preferredStyle: .actionSheet)
            
            // Add Cancel button
            actSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (action) in
                actSheet.dismiss(animated: true, completion: nil)
                }))
            
            // Add button for Apple maps (assuming the app is always installed)
            actSheet.addAction(UIAlertAction(title: "Карты Apple", style: .default, handler: { (action) in
                
                let url = URL(string: "http://maps.apple.com/?address=" + modifiedAddress)
                if let actualURL = url {
                    
                    // Open Apple maps
                    UIApplication.shared.open(actualURL, options: [:], completionHandler: nil)
                }
            }))
            
            // Add button for Google maps if the app is installed
            if canOpenGoogleMaps {
                actSheet.addAction(UIAlertAction(title: "Карты Google", style: .default, handler: { (action) in
 
                    let url = URL(string: "comgooglemaps://?q=" + modifiedAddress)
                    if let actualURL = url {
                        
                        // Open Google maps
                        UIApplication.shared.open(actualURL, options: [:], completionHandler: nil)
                    }
                }))
            }
            
            // Add button for Yandex Navigator if the app is installed
            if canOpenYandexNavi {
                actSheet.addAction(UIAlertAction(title: "Яндекс Навигатор", style: .default, handler: { (action) in
                    
                    let url = URL(string: "yandexnavi://map_search?text=" + modifiedAddress)
                    if let actualURL = url {
                        
                        // Open Yandex maps
                        UIApplication.shared.open(actualURL, options: [:], completionHandler: nil)
                    }
                }))
            }
 
            // Add button for Yandex Maps if the app is installed
            if canOpenYandexMaps {
                actSheet.addAction(UIAlertAction(title: "Карты Яндекс", style: .default, handler: { (action) in
                    
                    let url = URL(string: "yandexmaps://maps.yandex.ru/?pt=\(self.theater!.long),\(self.theater!.lat)&z=12&l=map,trf")
                    if let actualURL = url {
                        
                        // Open Yandex maps
                        UIApplication.shared.open(actualURL, options: [:], completionHandler: nil)
                    }
                }))
            }
            
            // Display action sheet
            present(actSheet, animated: true)
        
        // Open Apple maps if no other mapping app is installed
        } else {
            let url = URL(string: "http://maps.apple.com/?address=" + modifiedAddress)
            if let actualURL = url {
                
                // Open URL
                UIApplication.shared.open(actualURL, options: [:], completionHandler: nil)
            }
        }
    }
    

    // WriteReviewChildViewControllerDelegate methods
    func saveReview(name: String, review: String) {

        // Child view controller is calling save review
        // Pass the data to the DetailModel
        if let actualModel = model {
            actualModel.saveReview(name, review)
        }
    }

    // MARK: - Keyboard functions
    func keyboardIsShowing(notification: NSNotification) {
        
        let userInfo = notification.userInfo
        
        if let userInfoDictionary = userInfo {
            let keyboardRect = userInfoDictionary["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        
            // Animate the constraints
            view.layoutIfNeeded()
        
            UIView.animate(withDuration: 0.25) {
            
                self.viewTopConstraint.constant = keyboardRect.height * -1
                self.viewBottomConstraint.constant = keyboardRect.height
                self.view.layoutIfNeeded()
            }
        }
    }

    func keyboardIsHiding(notification: NSNotification) {
        // Animate the constraints
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25) {
            
            self.viewTopConstraint.constant = 0
            self.viewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Call the hideKeyboard function of the WriteReviewChildViewController
        if type(of: currentViewController!) == WriteReviewChildViewController.self {
            (currentViewController as! WriteReviewChildViewController).hideKeyboard()
        }
    }

}
