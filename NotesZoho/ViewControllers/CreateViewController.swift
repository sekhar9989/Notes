//
//  CreateViewController.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 27/03/21.
//

import UIKit
import Photos
import CoreData

class CreateViewController: UIViewController {
    // MARK: - IBOutelts
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var attchmentButton: UIButton!
    
    // MARK: - Constants and variables
    var imageData: Data?

    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IBActions
    @IBAction func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionAttachment(_ sender: UIButton) {
        openGallery()
    }
    
    @IBAction func actionSave(_ sender: UIButton) {
        if titleTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(title: "Alert", msg: "Invalid title")
        } else if bodyTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(title: "Alert", msg: "Invalid description")
        } else {
            saveNote()
        }
    }
    
    // MARK: - Custom methods
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            DispatchQueue.main.async {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            presentCameraSettings()
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied. Give photos access from settings to select photos.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        self.present(alertController, animated: true)
    }
    
    func saveNote() {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Notes",in: managedContext)!

        let newNote = NSManagedObject(entity: entity,insertInto: managedContext)
        let title = titleTextView.text
        newNote.setValue(title, forKeyPath: "title")
        let body = bodyTextView.text
        let date = "\(Date().timeIntervalSince1970)"
        let id = arrayNotes.isEmpty ? 4 : (Int(arrayNotes[0].id) ?? arrayNotes.count) + 1
        newNote.setValue(body, forKeyPath: "body")
        newNote.setValue(imageData, forKeyPath: "image")
        newNote.setValue(date, forKeyPath: "time")
        newNote.setValue("\(id)", forKeyPath: "id")
        do {
            try managedContext.save()
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.editedImage.rawValue)] as? UIImage {
            imageData = pickedImage.jpegData(compressionQuality: 0.5)
        }
        attchmentButton.tintColor = .green
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
}

extension CreateViewController: UITextViewDelegate {
    
}
