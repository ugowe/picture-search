//
//  PictureSearcher.swift
//  PictureSearch
//
//  Created by Ugowe on 8/31/16.
//  Copyright © 2016 Ugowe. All rights reserved.
//

import Foundation
import UIKit

// PictureSearchResults: A struct which wraps up a search term and the results found for that search
struct PictureSearchResults {
    let searchTerm : String
    let searchResults : [FlickrPhoto]
}

/*
 FlickrPhoto: Data about a photo retrieved from Flickr – its thumbnail, image, and metadata information such as its ID. There are also some methods to build Flickr URLs and some size calculations.
 FlickrSearchResults contains an array of these objects.
 */
class FlickrPhoto : Equatable {
    var thumbnail: UIImage?
    var largeImage: UIImage?
    let photoID: String
    let farm: Int
    let server: String
    let secret: String
    
    init(photoID: String, farm: Int, server: String, secret: String){
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    //Find the image URL structure at https://www.flickr.com/services/api/misc.urls.html
    func flickrImageURL(size: String = "m") -> NSURL {
        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")!
    }
    
    func loadLargeImageWithCompletion(completion: (flickrPhoto: FlickrPhoto) -> Void) {
        let loadSession = NSURLSession.sharedSession()
        let loadURL = flickrImageURL("b")
        let loadRequest = NSURLRequest(URL: loadURL)
        
//        var loadedImage: UIImage?
        
        let loadTask = loadSession.dataTaskWithRequest(loadRequest) { (data, response, error) in
            do {
                guard let data = data else {print("Data is nil"); return}
                let loadedImage = try (NSJSONSerialization.JSONObjectWithData(data, options: []) as? UIImage)
                self.largeImage = loadedImage
                completion(flickrPhoto: self)
            } catch {
                print(error)
            }
        }
        
        loadTask.resume()
    }
    
}

func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
    return lhs.photoID == rhs.photoID
}

// Flickr: Provides a simple block-based API to perform a search and return a FlickrSearchResult

class Flickr {
    
    // Comment later
    let processingQueue = NSOperationQueue()
    
    func flickrSearchURL(searchTerm: String) -> NSURL {
        let escapedSearchTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Secrets.apiKey)&text=\(escapedSearchTerm!)&per_page=20&format=json&nojsoncallback=1"
        let searchTermURL = NSURL(string: URLString)!
        return searchTermURL
    }
    
    func searchFlickrForTerm(searchTerm: String, completion: (results: PictureSearchResults?) -> Void){
        
        var resultsDictionary: NSDictionary?
        
        let session = NSURLSession.sharedSession()
        let searchURL = flickrSearchURL(searchTerm)
        let searchRequest = NSURLRequest(URL: searchURL)
        let searchTask = session.dataTaskWithRequest(searchRequest) { (data, response, error) in
            do {
                guard let data = data else {print("Unable to retrieve search data"); return}
                resultsDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            } catch {
                print(error)
            }
            
            let photosContainer = resultsDictionary!["photos"] as! NSDictionary
            
            //
            let photosRecieved = photosContainer["photo"] as! [NSDictionary]
            
            let flickrPhotos : [FlickrPhoto] = photosRecieved.map {
                photoDictionary in
                
                let photoID = photoDictionary["id"] as? String ?? ""
                let farm = photoDictionary["farm"] as? Int ?? 0
                let server = photoDictionary["server"] as? String ?? ""
                let secret = photoDictionary["secret"] as? String ?? ""
                
                let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
                
                let imageData = NSData(contentsOfURL: flickrPhoto.flickrImageURL())
                flickrPhoto.thumbnail = UIImage(data: imageData!)
                
                return flickrPhoto
            }
            
            // func dispatch_async(queue: dispatch_queue_t, _ block: dispatch_block_t)-- Submits a block for asynchronous execution on a dispatch queue and returns immediately.
            // Comment later
            dispatch_async(dispatch_get_main_queue(), {
                completion(results: PictureSearchResults(searchTerm: searchTerm, searchResults: flickrPhotos))
            })
            
        }
        searchTask.resume()
    }
}




