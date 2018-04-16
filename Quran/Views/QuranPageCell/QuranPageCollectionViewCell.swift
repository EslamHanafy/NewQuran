//
//  QuranPageCollectionViewCell.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/24/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class QuranPageCollectionViewCell: UICollectionViewCell {

    @IBOutlet var quranTextView: QuranTextView!
    
    var page: Page!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        quranTextView.preapareForReuse()
    }
    
 
    /// init cell for the first time
    ///
    /// - Parameter page: Page object that contain the page data
    func initWith(page: Page) {
        self.page = page
        
        quranTextView.initWith(page: page)
    }
    
}
