//
//  ImageCollectionViewCell.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 27/03/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var noteImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noteImageView.enableZoom()
    }
}
