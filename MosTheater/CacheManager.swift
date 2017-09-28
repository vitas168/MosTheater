//
//  CacheManager.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 28/08/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

class CacheManager: NSObject {

    
    // MARK: - Functions
    static func removeAllDataFromCache() {
        
        // Get UserDefaults dictinary
        let defaults = UserDefaults.standard
        let defaultsDictionary = defaults.dictionaryRepresentation()
        for (cacheKey, _ ) in defaultsDictionary {
            defaults.removeObject(forKey: cacheKey)
        }
        defaults.synchronize()
    }
    
    
    // MARKS: - Version functions
    // Check UserDefaults for version string
    static func getVersionFromCache () -> String? {
    
        let defaults = UserDefaults.standard
        let versionNumber = defaults.string(forKey: "Version")
        return versionNumber
    }
    
    
    // Save version string to cache
    static func putVersionIntoCache(version: String) {
    
        let defaults = UserDefaults.standard
        defaults.set(version, forKey: "Version")
        defaults.synchronize()
    }
    
    
    // MARK: - Theaters functions
    // Retrieve theaters data if any
    static func getTheatersFromCache() -> NSDictionary? {

        let defaults = UserDefaults.standard
        let data = defaults.value(forKey: "Theaters") as? NSDictionary
        return data
    }
    
    
    // Save theaters data into UserDefaults
    static func putTheatersIntoCache(data:NSDictionary) {
        
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: "Theaters")
        defaults.synchronize()
    }
    
    
    // MARK: - Metadata functions
    // Retrieve metadata for theater if any
    static func getMetaFromCache(theaterId: String) -> NSDictionary? {
    
        let defaults = UserDefaults.standard
        let data = defaults.value(forKey: "Meta\(theaterId)") as? NSDictionary
        return data
    }
    
    
    // Save metadata into UserDefaults
    static func putMetaIntoCache(data: NSDictionary, theaterId: String) {
    
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: "Meta\(theaterId)")
        defaults.synchronize()
    }
    
    
    // Delete metadata from cache
    static func removeMetaFromCache(theaterId: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Meta\(theaterId)")
        defaults.synchronize()
    }

 
    // MARK: - Images functions
    // Retrieve image by its name from cache
    static func getImageFromCache(imageName: String) -> Data? {
        
        let defaults = UserDefaults.standard
        let imageData = defaults.data(forKey: imageName)
        return imageData
    
    }
    
    
    // Save image into cache
    static func putImageIntoCache(imageData: Data, imageName: String) {
    
        let defaults = UserDefaults.standard
        defaults.set(imageData, forKey: imageName)
        defaults.synchronize()
    }
    
}
