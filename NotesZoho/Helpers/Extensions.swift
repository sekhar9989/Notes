//
//  Extensions.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 27/03/21.
//

import UIKit
import Foundation

extension String {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: Double(self) ?? 0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getLinkContent() -> String {
        
        do{
            let regex = try NSRegularExpression(pattern: "\\[.*?\\]")
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            for match in matches {
                if let range = Range(match.range, in: self) {
                    let name = self[range]
                    let rangeString = NSMutableAttributedString(string: String(name))
                    rangeString.mutableString.replaceOccurrences(of: "[", with: "", options: NSString.CompareOptions(rawValue: 0), range: NSMakeRange(0, rangeString.length));
                    rangeString.mutableString.replaceOccurrences(of: "]", with: "", options: NSString.CompareOptions(rawValue: 0), range: NSMakeRange(0, rangeString.length));
                    return rangeString.string
                }
            }
        }catch{
            print("error \(error)")
        }
        return ""
    }
    
    func getLink() -> String {
        do{
            let regex = try NSRegularExpression(pattern: "(https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9]{1,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*))")
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            for match in matches {
                if let range = Range(match.range, in: self) {
                    let name = self[range]
                    return String(name)
                }
            }
        }catch{
            print("error \(error)")
        }
        return ""
    }
    
    func getBoldAndLinks() -> NSMutableAttributedString {
        let textColor:UIColor = #colorLiteral(red: 0.8665903211, green: 0.8667154908, blue: 0.8665630817, alpha: 1)
        var title = self
        let normalAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor:textColor
        ]
        let boldAttribute = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor:textColor
        ]
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(normalAttribute, range: NSRange(location: 0, length: attributedString.length))
        do{
            let regex = try NSRegularExpression(pattern: "(\\*\\*.*?\\*\\*)")
            let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: title.utf16.count))
            var stringWithStar:[String] = []
            var stringWithOutStar:[String] = []
            
            for match in matches {
                if let range = Range(match.range, in: title) {
                    let name = title[range]
                    let rangeString = NSMutableAttributedString(string: String(name))
                    stringWithStar.append(String(name))
                    attributedString.addAttributes(boldAttribute, range: NSRange(location: range.lowerBound.utf16Offset(in: title), length: rangeString.length))
                    
                    rangeString.mutableString.replaceOccurrences(of: "**", with: "", options: NSString.CompareOptions(rawValue: 0), range: NSMakeRange(0, rangeString.length));
                    stringWithOutStar.append(rangeString.string)
                }
            }
            for (index,string) in stringWithStar.enumerated(){
                attributedString.mutableString.replaceOccurrences(of: string, with: stringWithOutStar[index], options: NSString.CompareOptions(rawValue: 0), range: NSMakeRange(0, attributedString.length));
                title = title.replacingOccurrences(of: string, with: stringWithOutStar[index])
            }
        }catch{
            print("error \(error)")
        }
        do{
            let regex = try NSRegularExpression(pattern: "(\\[.*?\\](\\(https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)\\)))")
            let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: title.utf16.count))
            for match in matches {
                if let range = Range(match.range, in: title) {
                    let name = title[range]
                    let link = String(name).getLink()
                    let content = String(name).getLinkContent()
                    let attributeContent =  NSMutableAttributedString(string: content)
                    attributeContent.addAttribute(.link, value: link, range:NSRange(location: 0, length: content.utf16.count))
                    attributeContent.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: content.utf16.count))
                    attributeContent.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20) , range: NSRange(location: 0, length: content.utf16.count))

                    let rangeString = NSMutableAttributedString(string: String(name))
                    attributedString.replaceCharacters(in: NSRange(location: range.lowerBound.utf16Offset(in: self), length: rangeString.length), with: attributeContent)
                }
            }
        }catch{
            print("error \(error)")
        }
        
        return attributedString
    }
}

extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}

extension UIViewController {
    func showAlert(title:String, msg:String) {
        let alert  = UIAlertController(title: title, message:msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}
