//
//  ImageViewController.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 27/03/21.
//

import UIKit

class ImageViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var imagesCollection: UICollectionView!
    
    // MARK: - Constants and variables
    var arrNotes = [NoteModel]()
    var selectedIndex = 0

    // MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesCollection.isHidden = selectedIndex != 0
        crossButton.layer.shadowOpacity = 0.3
        crossButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        crossButton.layer.shadowRadius = 8
        crossButton.layer.shadowColor = UIColor.white.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if selectedIndex != 0 {
            DispatchQueue.main.async {
                self.imagesCollection.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .right, animated: false)
                self.imagesCollection.isHidden = false
            }
        }
    }

    // MARK: - IBACtions
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let note = arrNotes[indexPath.item]
        cell.noteImageView.image = UIImage(data: note.image!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
