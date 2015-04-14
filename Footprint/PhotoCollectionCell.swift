//
//  PhotoCollectionCell.swift
//  Footprint
//
//  Created by Melvin Tu on 4/7/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

class PhotoCollectionCell : UICollectionViewCell {
    @IBOutlet weak var imageView : UIImageView!
    var photo: PhotoMetadata?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}