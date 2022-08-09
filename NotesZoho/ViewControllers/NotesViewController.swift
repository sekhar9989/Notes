//
//  NotesViewController.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 23/03/21.
//

import UIKit
import CoreData

var arrayNotes = [NoteModel]()

class NotesViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var notesCollection: UICollectionView!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDatafromDataBase()
    }
    
    // MARK:- IBActions
    @IBAction func actionAdd(_ sender: UIButton) {
        if let createVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController {
            navigationController?.pushViewController(createVC, animated: true)
        }
    }
    
    // MARK:- Custom methods
    func getSizeForCell(_ index:Int) -> CGSize {
        let objNote = arrayNotes[index]
        var cellWidth = (notesCollection.frame.width-10)/2
        var font = UIFont.systemFont(ofSize: 16)
        if objNote.image != nil {
            cellWidth = notesCollection.frame.width-10
            font = UIFont.boldSystemFont(ofSize: 22)
        }
        let widthOfLable = cellWidth - 32
        let expectedHeight = heightForLable(text: objNote.title, font: font, width:widthOfLable) + 46.5
        return CGSize(width: cellWidth, height: expectedHeight)
    }
    
    
    func heightForLable(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func randomColor(forName name: String) -> UIColor {
        let hash = name.hash
        let colorCode = abs(hash) % 0x1000000
        let red = colorCode >> 16
        let green = (colorCode >> 8) & 0xff
        let blue = colorCode & 0xff
        return UIColor(red: CGFloat(red) / 256, green: CGFloat(green) / 256, blue: CGFloat(blue) / 256, alpha: 0.65)
    }
    
    func showActivity(isShow:Bool = false) {
        if isShow {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func getNotes() {
        plusButton.layer.shadowOpacity = 0.3
        plusButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        plusButton.layer.shadowRadius = 8
        plusButton.layer.shadowColor = UIColor.white.cgColor
        Reachability.checkInternet { (isConnected) in
            if isConnected {
                if arrayNotes.isEmpty {
                    self.showActivity(isShow: true)
                }
                var request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/RishabhRaghunath/JustATest/master/posts")!)
                request.httpMethod = "GET"
                let session = URLSession.shared
                session.dataTask(with: request) {data, response, error in
                    let dict = try? JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
                    if let arrNotes = dict as? [[String: Any]] {
                        for note in arrNotes {
                            let objModel = NoteModel(fromDictionary: note)
                            arrayNotes.append(objModel)
                        }
                        self.saveDataBase(notesData: arrayNotes)
                        DispatchQueue.main.async {
                            self.notesCollection.reloadData()
                        }
                    }
                }.resume()
            } else {
                self.showActivity()
                self.showAlert(title:"No internet", msg:"Locally stored notes only visible if internet not available.")
                self.fetchDatafromDataBase()
            }
        }
    }
    
    func fetchDatafromDataBase() {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
        do {
            var notes: [NSManagedObject] = []
            notes = try managedContext.fetch(fetchRequest)
            arrayNotes.removeAll()
            for note in notes {
                let dictNote = [
                    "title":note.value(forKey:"title") as? String ?? "",
                    "body":note.value(forKey:"body") as? String ?? "",
                    "id":note.value(forKey:"id") as? String ?? "",
                    "time":note.value(forKey:"time") as? String ?? "".getDateStringFromUTC(),
                    "image":note.value(forKey:"image") as? Data as Any
                ] as [String : Any]
                arrayNotes.append(NoteModel(fromDictionary: dictNote))
            }
            arrayNotes = arrayNotes.sorted { $0.id > $1.id }
            DispatchQueue.main.async {
                self.notesCollection.reloadData()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveDataBase(notesData:[NoteModel])  {
        let names : [String]
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            names = fetchResults.map{ ($0.value(forKey: "id") as? String ?? "") }
        } catch {
            names = []
        }
        let entity = NSEntityDescription.entity(forEntityName: "Notes",in: managedContext)!
        for  notes in notesData where !names.contains(notes.id) {
            let newNote = NSManagedObject(entity: entity,insertInto: managedContext)
            newNote.setValue(notes.title, forKeyPath: "title")
            newNote.setValue(notes.body, forKeyPath: "body")
            newNote.setValue(notes.image, forKeyPath: "image")
            newNote.setValue(notes.time, forKeyPath: "time")
            newNote.setValue(notes.id, forKeyPath: "id")
            do {
                self.showActivity()
                try managedContext.save()
                NotificationCenter.default.post(name: Notification.Name("ReloadCollection"), object: nil)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        self.fetchDatafromDataBase()
    }
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath) as? NotesCollectionViewCell else {
            return UICollectionViewCell()
        }
        let objNote = arrayNotes[indexPath.item]
        cell.titleLabel.text = objNote.title
        cell.titleLabel.superview?.backgroundColor = randomColor(forName: objNote.title)
        cell.createdOnLabel.text = objNote.time.getDateStringFromUTC()
        if objNote.image == nil {
            cell.createdOnLabel.textAlignment = .left
            cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
        } else {
            cell.createdOnLabel.textAlignment = .right
            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getSizeForCell(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailVC.selectedIndex = indexPath.item
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
