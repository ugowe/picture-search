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
    
    // pictureForIndexPath is a convenience method that gets a specific photo related to an index path in this collection view
    func pictureForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
        let picture = searches[indexPath.section].searchResults[indexPath.row]
        return picture
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return searches.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PictureCollectionViewCell
        
        let flickrPhoto = pictureForIndexPath(indexPath)
        
        cell.backgroundColor = UIColor.orangeColor()
        cell.imageView.image = flickrPhoto.thumbnail
        
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "PictureHeaderView", forIndexPath: indexPath) as! PictureHeaderView
            headerView.label.text = searches[indexPath.section].searchTerm
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
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

extension PictureViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flickrPhoto = pictureForIndexPath(indexPath)
        
        if var size = flickrPhoto.thumbnail?.size {
            size.width += 10
            size.height += 10
            return size
        }
        return CGSize(width: 35, height: 35)
        
        }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
}


