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
    
    private var selectedPhotos = [FlickrPhoto]()
    private let shareTextLabel = UILabel()
    
    func updateSharedPhotoCount() {
        shareTextLabel.textColor = UIColor.blueColor()
        shareTextLabel.text = "\(selectedPhotos.count) photos selected"
        shareTextLabel.sizeToFit()
    }
    
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
        
        //        cell.activityIndicator.stopAnimating()
        
        if indexPath != largePictureIndexPath {
            cell.imageView.image = flickrPhoto.thumbnail
            return cell
        }
        
        if flickrPhoto.largeImage != nil {
            cell.imageView.image = flickrPhoto.largeImage
            return cell
        }
        
        cell.imageView.image = flickrPhoto.thumbnail
        //        cell.activityIndicator.startAnimating()
        
        flickrPhoto.loadLargeImageWithCompletion { loadedFlickrPicture in
            
            //            cell.activityIndicator.stopAnimating()
            
            if loadedFlickrPicture.largeImage == nil {
                return
            }
            
            if indexPath == self.largePictureIndexPath {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PictureCollectionViewCell {
                    cell.imageView.image = loadedFlickrPicture.largeImage
                }
            }
        }
        
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
    
    var largePictureIndexPath: NSIndexPath? {
        didSet {
            var indexPaths = [NSIndexPath]()
            if largePictureIndexPath != nil {
                indexPaths.append(largePictureIndexPath!)
            }
            
            if oldValue != nil {
                indexPaths.append(oldValue!)
            }
            
            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
                return
            }){ completed in
                if self.largePictureIndexPath != nil {
                    self.collectionView?.scrollToItemAtIndexPath(self.largePictureIndexPath!, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
                }
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if sharing {
            return true
        }
        
        if largePictureIndexPath == indexPath {
            largePictureIndexPath = nil
        } else {
            largePictureIndexPath = indexPath
        }
        return false
        
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if sharing {
            let selectedPhoto = self.pictureForIndexPath(indexPath)
            if let foundIndex = self.selectedPhotos.indexOf(selectedPhoto){
                selectedPhotos.removeAtIndex(foundIndex)
                updateSharedPhotoCount()
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if sharing {
            let photo = pictureForIndexPath(indexPath)
            selectedPhotos.append(photo)
            updateSharedPhotoCount()
        }
    }
    
    
    var sharing : Bool = false {
        didSet {
            collectionView?.allowsMultipleSelection = sharing
            collectionView?.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
            selectedPhotos.removeAll(keepCapacity: false)
            if sharing && largePictureIndexPath != nil {
                largePictureIndexPath = nil
            }
            
            let shareButton =
                self.navigationItem.rightBarButtonItems!.first! as UIBarButtonItem
            if sharing {
                updateSharedPhotoCount()
                let sharingDetailItem = UIBarButtonItem(customView: shareTextLabel)
                navigationItem.setRightBarButtonItems([shareButton,sharingDetailItem], animated: true)
            }
            else {
                navigationItem.setRightBarButtonItems([shareButton], animated: true)
            }
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
        
        if indexPath == largePictureIndexPath {
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.right)
            size.width -= (sectionInsets.left + sectionInsets.right)
            return flickrPhoto.sizeToFillWidthOfSize(size)
        }
        
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
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if searches.isEmpty {
            return
        }
        
        if !selectedPhotos.isEmpty {
            var imageArray = [UIImage]()
            for photo in self.selectedPhotos {
                imageArray.append(photo.thumbnail!);
            }
            
            // Present UIActivityViewController for iPad
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                
                let shareScreen = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
                let sourceButton = self.navigationItem.rightBarButtonItems!.first! as UIBarButtonItem
                
                shareScreen.modalPresentationStyle = .Popover
                shareScreen.popoverPresentationController?.permittedArrowDirections = .Any
                shareScreen.popoverPresentationController?.barButtonItem = sourceButton
                
                self.presentViewController(shareScreen, animated: true, completion: nil)
            }
                
                // Present UIActivityViewController for iPhone!
            else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                
                // Separate Activity View Controller to present for iPhones
                let activityVC = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
                let sourceView = self.view
                
                activityVC.popoverPresentationController?.sourceView = sourceView
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
        
        sharing = !sharing
    }
    
}


