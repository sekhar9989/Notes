//
//  Reachability.swift
//  NotesZoho
//
//  Created by Sekhar Simhadri on 27/03/21.
//

import Foundation
import SystemConfiguration

public class Reachability {

    class func checkInternet(completionHandler:@escaping(_ internet:Bool) -> Void)
    {
        var request = URLRequest(url: URL(string: "https://google.com")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            completionHandler((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
}
