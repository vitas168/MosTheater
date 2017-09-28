//
//  DetailModel.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 01/08/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit


// Specify a protocol and a callback function to return metadata for a theater
protocol DetailModelDelegate {
    func detailModel(metadataFor theater:Theater)
    func detailModel(imageName: String, imageData: Data)
    func detailModelSaveReviewError()
    func detailModelSaveReviewSuccess(reviews:[Review])
}


class DetailModel: NSObject, FirebaseManagerDelegate {
    
    // MARK: - Properties
    var delegate: DetailModelDelegate?
    var theater: Theater?
    var firManager: FirebaseManager?
    
    
    // MARK: - Functions
    // Fetch metadata
    func getMetadata() {
    
        if firManager == nil {
            firManager = FirebaseManager()
        }
        firManager!.delegate = self
        
        if let actualTheater = theater {
            firManager!.getMetadataFromDatabase(getMetaFor: actualTheater)
        }
    }
    
    
    // Tell Firebase Manager to get the image
    func getImage (imageName: String) {
        
        if firManager == nil {
            firManager = FirebaseManager()
        }
        firManager!.delegate = self
        firManager!.getImageFromDatabase(imageName: imageName)
        
    }

    
    // Call save review of the firebase manager
    func saveReview (_ name: String, _ review: String) {
        
        // Check if theater is set
        if let actualTheater = theater {
            if firManager == nil {
                firManager = FirebaseManager()
            }
            firManager!.delegate = self
            firManager!.saveReviewToDatabase(name, review, actualTheater.id)
        }
    }
    
    
    // Close Firebase observers when leaving theater's screen
    func closeObservers() {
 
        guard firManager != nil else { return }
        
        if let actualTheater = theater {
            firManager!.closeObserversForTheater(theaterId: actualTheater.id)
        }
    }
    
    
    // MARK: - FirebaseManager delegate functions
    // Callback function for FirebaseManager returning metadata for a theater
    func firebaseManager(metadataFor theater: Theater) {
    
        // Receive metadata from FirebaseManager and pass it on to DetailViewController
        if delegate != nil {
            delegate!.detailModel(metadataFor: theater)
        }
    }
    
    
    func firebaseManager(imageName: String, imageData: Data) {
        // Firebase has returned the image data, let the delegate know
        if let actualDelegate = delegate {
            actualDelegate.detailModel(imageName: imageName, imageData: imageData)
        }
    }
    
    
    func firebaseManagerSaveReviewError() {
        // Save review had an error, communicate that to DetailViewController
        if let actualDelegate = delegate {
            actualDelegate.detailModelSaveReviewError()
        }
    }
    
    
    func firebaseManagerSaveReviewSuccess(reviews: [Review]) {
        // Save reviews was a success, communicate that to DetailViewController
        if let actualDelegate = delegate {
            actualDelegate.detailModelSaveReviewSuccess(reviews: reviews)
        }
    }
}
