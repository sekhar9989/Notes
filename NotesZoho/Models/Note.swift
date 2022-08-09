//
//  Note.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 23/03/21.
//

import Foundation

import Foundation


class NoteModel {

    var body = ""
    var id = ""
    var image: Data?
    var time = ""
    var title = ""

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        body = dictionary["body"] as? String ?? ""
        id = dictionary["id"] as? String ?? ""
        if let imageData = dictionary["image"] as? Data {
            image = imageData
        } else if let urlString = dictionary["image"] as? String, !urlString.isEmpty {
            image = getImageData(urlString: urlString)
        }
        time = dictionary["time"] as? String ?? ""
        title = dictionary["title"] as? String ?? ""
    }

    
    func getImageData(urlString:String) -> Data? {
        if let url = URL(string: urlString) {
            let data = try? Data(contentsOf: url)
            if let imageData = data {
                return imageData
            }
            return nil
        }
        return nil
    }
}
