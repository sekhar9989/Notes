//
//  DetailCollectionViewCell.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 27/03/21.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageButton: UIButton!
}
