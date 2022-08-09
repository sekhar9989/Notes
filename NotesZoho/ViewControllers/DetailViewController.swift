//
//  DetailViewController.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 27/03/21.
//

import UIKit

class DetailViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var notesCollection: UICollectionView!
    
    // MARK: - Constants and variables
    var selectedIndex = 0
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.notesCollection.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .right, animated: false)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: Notification.Name("ReloadCollection"), object: nil)
    }
    
    // MARK: - IBActions
    @IBAction func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionTappedOnImage(_ sender: UIButton) {
        if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController {
            detailVC.arrNotes = arrayNotes.filter {$0.image != nil}
            detailVC.selectedIndex = detailVC.arrNotes.firstIndex {$0.id == arrayNotes[sender.tag].id} ?? 0
            self.present(detailVC, animated: true, completion: nil)
        }
    }
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.notesCollection.reloadData()
        }
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as? DetailCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.imageButton.tag = indexPath.item
        let note = arrayNotes[indexPath.item]
        cell.titleLabel.text = note.title
        cell.timeLabel.text = note.time.getDateStringFromUTC()
        cell.descriptionTextView.attributedText = note.body.getBoldAndLinks()
        if note.image == nil {
            cell.imageViewHeightConstraint.constant = 0
        } else {
            cell.imageViewHeightConstraint.constant = 142
            cell.noteImageView.image = UIImage(data: note.image!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
