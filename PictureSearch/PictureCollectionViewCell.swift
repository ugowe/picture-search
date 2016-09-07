//
//  PictureCollectionViewCell.swift
//  PictureSearch
//
//  Created by Ugowe on 8/31/16.
//  Copyright © 2016 Ugowe. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
    }
    
    override var selected : Bool {
        didSet {
            self.backgroundColor = selected ? UIColor.blueColor() : UIColor.blackColor()
        }
    }
    
}

