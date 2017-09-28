//
//  TheaterModel.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 27/06/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit


// Specify a protocol and a callback function to return list of theaters
protocol TheaterModelDelegate {
    func theaterModel(listOf theaters: [Theater])
}


// The class is a data source for ListViewController. It returns data provided by FirebaseManager class.
class TheaterModel: NSObject, FirebaseManagerDelegate {
    
    // MARK: - Properties
    var delegate: TheaterModelDelegate?
    var theaters = [Theater]()
    var firManager:FirebaseManager?

    
    // MARK: - Functions
    // Fetch list of theaters
    func getTheaters() {

        // Create an instance of FirebaseManager and make a call for the list of theaters
        if firManager == nil {
            firManager = FirebaseManager()
        }
        firManager!.delegate = self
        firManager!.getTheatersFromDatabase()
    }
    
    
    // Check FirebaseManager for data version
    func checkDataVersion() {
        
        // Create an instance of FirebaseManager and make a call for the list of theaters
        if firManager == nil {
            firManager = FirebaseManager()
        }
        firManager!.delegate = self
    
        firManager!.checkDatabaseVersion()
    }
    
    
    // FirebaseManager delegate functions
    func firebaseManager(listOf theaters:[Theater]) {
    
        // Receive list of theaters from FirebaseManager and pass it on to ListViewController
        if delegate != nil {
            delegate!.theaterModel(listOf: theaters)
        }
    }

}

