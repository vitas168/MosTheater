//
//  FirebaseManager.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 27/06/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


// Specify a protocol and callback functions to return theaters data
@objc protocol FirebaseManagerDelegate {
    
    @objc optional func firebaseManager(listOf theaters:[Theater])
    @objc optional func firebaseManager(metadataFor theater:Theater)
    @objc optional func firebaseManager(imageName: String, imageData: Data)
    @objc optional func firebaseManagerSaveReviewError()
    @objc optional func firebaseManagerSaveReviewSuccess(reviews:[Review])
}


// Class for working with Firebase data
class FirebaseManager: NSObject {

    var ref: DatabaseReference!
    var delegate: FirebaseManagerDelegate?
    
    // MARK: - Init method(s)
    override init () {
    
        super.init()
        // Create an instance of Firebase reference
        ref = Database.database().reference()
        Auth.auth().signIn(withEmail: "test@mail.ru", password: "mostheater") { (user, error) in
            // TODO: Add error handler here
        }
    }
    
    
    // Fetch list of theaters from Firebase database
    func getTheatersFromDatabase() {

        // Exit function if no delegate (for receiving data) is assigned
        if self.delegate == nil { return }
        
        // Before calling database, check cache manager
        if let cachedTheatersDict = CacheManager.getTheatersFromCache() {
        
            // Parse theaters data from dictionary into an array
            let theatersArray = parseTheatersFrom(dict: cachedTheatersDict)

            // Now return the theaters array
            // Do it on the main thread
            DispatchQueue.main.async {
                // Nofity the delegate
                self.delegate?.firebaseManager!(listOf: theatersArray)
            }
            return
        }
        
        
        // Retrieve list of theaters from under Firebase 'theaters' node
        ref.child("theaters").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Create a dictionary from database data snapshot
            let theatersDict = snapshot.value as? NSDictionary
   
            if let actualTheatersDict = theatersDict {

                // Before working with data save it into cache
                CacheManager.putTheatersIntoCache(data: actualTheatersDict)
                
                // Parse theaters data from dictionary into an array
                let theatersArray = self.parseTheatersFrom(dict: actualTheatersDict)
                
                // Now return the theaters array
                // Do it on the main thread
                DispatchQueue.main.async {
                    // Nofity the delegate
                    self.delegate?.firebaseManager!(listOf: theatersArray)
                }
            }
            // Handle errors
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Get metadata for a theater
    func getMetadataFromDatabase (getMetaFor theater:Theater) {
    
        // Exit function if no delegate (for receiving data) is assigned
        if self.delegate == nil { return }
        
        // Check cache for metadata
        if let cachedMetaDict = CacheManager.getMetaFromCache(theaterId: theater.id) {
        
            // Parse metadata
            parseMetadata(metaDict: cachedMetaDict, theater: theater)

            // Nofify the delegate and return the metadata
            // Do it on the main thread
            DispatchQueue.main.async {
                // Nofity the delegate
                self.delegate?.firebaseManager!(metadataFor: theater)
            }
            return
        }
        // Retrieve metadata for a theater from under Firebase 'meta' node
        ref.child("meta").child(theater.id).observe( .value, with: { (snapshot) in
            
            // Create a dictionary from database metadata snapshot
            let metaDict = snapshot.value as? NSDictionary
            
            if let actualMetaDict = metaDict {
        
                // Save data into cache
                CacheManager.putMetaIntoCache(data: actualMetaDict, theaterId: theater.id)
                
                // Parse metadata
                self.parseMetadata(metaDict: actualMetaDict, theater: theater)
                
                /// Nofify the delegate and return the metadata
                // Do it on the main thread
                DispatchQueue.main.async {
                // Nofity the delegate
                    self.delegate?.firebaseManager!(metadataFor: theater)
                }
            }
            
            // Handle errors
        }) { (error) in
            print(error.localizedDescription)
            }
    }

    
    // Get the image by its name
    func getImageFromDatabase(imageName: String) {

        // Exit function if no delegate (for receiving data) is assigned
        if self.delegate == nil { return }
        
        // Check cache for image
        if let cachedImageData = CacheManager.getImageFromCache(imageName: imageName) {
        
            // Notify delegate and return the image data
            // Do it on the main thread
            DispatchQueue.main.async {
                // Nofity the delegate
                self.delegate?.firebaseManager!(imageName: imageName, imageData: cachedImageData)
            }
            return
        }
        
        // Create reference to Firebase Storage
        let storage = Storage.storage()
        
        // Create a reference to the file to download
        let imageRef = storage.reference(withPath: imageName)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let err = error {
                // Uh-oh, an error occurred!
                print(err.localizedDescription)
                
            } else if data != nil {
                
                // Save image data to cache
                CacheManager.putImageIntoCache(imageData: data!, imageName: imageName)
                
                // Notify delegate and return the image data
                // Do it on the main thread
                DispatchQueue.main.async {
                    // Nofity the delegate
                    self.delegate?.firebaseManager!(imageName: imageName, imageData: data!)
                }
            }
        }
    }

    
    // This function saves a new review to database. 
    // In case of error, it calls back the delegate with error.
    // If review is saved successfully, it calls a function to retrieve the fresh list of reviews and call back the delegate with success.
    func saveReviewToDatabase(_ name: String, _ review: String, _ theaterId: String) {
    
        // Exit function if no delegate (for receiving data) is assigned
        if self.delegate == nil { return }
        
        // Clear cache for theater metadata
        CacheManager.removeMetaFromCache(theaterId: theaterId)
        
        // Create timestamp
        let dateString = String(describing: Date())
        
        // Save the review to database
        ref.child("meta").child(theaterId).child("reviews").childByAutoId().setValue(["reviewer": name, "review": review, "date": dateString]) { (error, ref) in
            
            // Error happened, notify the delegate
            if error != nil {
 
                DispatchQueue.main.async {
                    self.delegate?.firebaseManagerSaveReviewError!()
                }
            }
            
            // Review saved successfully, now retrieve list of reviews
            else {
 
                self.getReviewsFromDatabaseAndReportSuccess(theaterId: theaterId)
            }
        }
    }
    
    
    // This function retrieves the list of reviews and call back the delegate with success.
    func getReviewsFromDatabaseAndReportSuccess (theaterId: String) {
        
        // Exit function if no delegate (for receiving data) is assigned
        if self.delegate == nil { return }
        
        // Retrieve reviews for a theater
        ref.child("meta").child(theaterId).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Create a dictionary from review data snapshot
            let reviewDict = snapshot.value as? NSDictionary
            
            if let actualReviewDict = reviewDict {
                
                // Parse reviews dictionary into an array
                let reviews = self.parseReviews(reviewDict: actualReviewDict)
                
                // Notify the delegate and pass list of reviews
                DispatchQueue.main.async {
                    
                    self.delegate?.firebaseManagerSaveReviewSuccess!(reviews: reviews)
                }
            }
        })
    }

    
    // Remove observers from a particular theater node
    func closeObserversForTheater(theaterId: String) {
        ref.child("meta").child(theaterId).removeAllObservers()
    }
 
    
    // MARK: - Helper functions
    // Convert a dictionary to array of theaters
    func parseTheatersFrom(dict: NSDictionary) -> [Theater] {
    
        // Create an array of Theater objects
        var theatersArray = [Theater]()
        
        // Fill in the array with actual theater data from dictionary
        for (theaterId, theaterData) in dict {
            
            let theater = Theater()
            theater.id = theaterId as! String
            let theaterDataDict = theaterData as! NSDictionary
            
            // Retrieve particular theater attributes
            theater.name_ru = theaterDataDict["name_ru"] as! String
            theater.lat = theaterDataDict["lat"] as! Float
            theater.long = theaterDataDict["long"] as! Float
            theater.smallImageName = theaterDataDict["imagesmall"] as! String
            
            // Add newly defined theater to the array
            theatersArray.append(theater)
        }
        return theatersArray
    }

    
    // Save theater's attributes from a dictionary
    func parseMetadata(metaDict: NSDictionary, theater: Theater) {
        
        // Pull out theater attributes
        theater.desc = metaDict["desc"] as! String
        theater.address = metaDict["address"] as! String
        theater.phone = metaDict["phone"] as! String
        theater.detailImageName = metaDict["imagebig"] as! String
        
        // Parse reviews
        
        // Clean previous reviews, if any
        theater.reviews.removeAll()
        
        let reviewDict = metaDict["reviews"] as? NSDictionary
        
        if let actualReviewDict = reviewDict {
            
            for ( _ , reviewData) in actualReviewDict {
                let review = Review()
                let reviewItem = reviewData as! NSDictionary
                review.name = reviewItem["reviewer"] as! String
                review.text = reviewItem["review"] as! String
                review.dateString = reviewItem["date"] as! String
                theater.reviews.append(review)
            }
            
            // Sort reviews by timestamp in reverse order
            theater.reviews.sort(by: { (review1, review2) -> Bool in
                return review1.dateString > review2.dateString
            })
        }
    }
    
    
    // This function takes a dictionary containing reviews and returns an array
    func parseReviews(reviewDict: NSDictionary) -> [Review] {
    
        var reviews = [Review]()
    
        for ( _ , reviewData) in reviewDict {
            let review = Review()
            let reviewItem = reviewData as! NSDictionary
            review.name = reviewItem["reviewer"] as! String
            review.text = reviewItem["review"] as! String
            review.dateString = reviewItem["date"] as! String
            reviews.append(review)
        }
            
        // Sort reviews by timestamp in reverse order
        reviews.sort(by: { (review1, review2) -> Bool in
            return review1.dateString > review2.dateString
        })
        
        return reviews
    }
    
    
    // This function checks database version against cache version
    func checkDatabaseVersion() {
    
        // Call Firebase 'Version' node
        
        
        ref.child("Version").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Retrieve database version string
            let versionString = snapshot.value as? String
            
            if let databaseVersion = versionString {
            
                // Check cache data version
                let cacheVersion = CacheManager.getVersionFromCache()
                
                if cacheVersion != nil {
                    
                    // Compare versions
                    if databaseVersion > cacheVersion! {
                        
                        // If Firebase has fresh data, purge the cache and save new version in cache
                        CacheManager.removeAllDataFromCache()
                        CacheManager.putVersionIntoCache(version: databaseVersion)
                    }
                    
                } else {
                
                    // Save version to cache
                    CacheManager.putVersionIntoCache(version: databaseVersion)
                }
            }
        })
    }
}
