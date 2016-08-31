//
//  PhotoViewController.swift
//  PictureSearch
//
//  Created by Ugowe on 8/30/16.
//  Copyright © 2016 Ugowe. All rights reserved.
//

import UIKit

class PictureViewController: UICollectionViewController {
    
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    private var searches = [PictureSearchResults]()
    private let flickr = Flickr()
    
    func pictureForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
        let picture = searches[indexPath.section].searchResults[indexPath.row]
        return picture
    }
    
    
}

extension PictureViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        flickr.searchFlickrForTerm(textField.text!) {
            results in
            
//            //2
//            activityIndicator.removeFromSuperview()
//            if error != nil {
//                print("Error searching : \(error)")
//            }
//            
//            if results != nil {
//                //3
//                print("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
//                self.searches.insert(results!, atIndex: 0)
//                
//                //4
//                self.collectionView?.reloadData()
//            }
            activityIndicator.removeFromSuperview()
            guard let results = results else {print("Error searching: "); return}
            print("Found \(results.searchResults.count) results matching search term '\(results.searchTerm)'")
            self.searches.insert(results, atIndex: 0)
            
            self.collectionView?.reloadData()
            
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}