//
//  Request.swift
//  Imdb
//
//  Created by jenkins on 08/05/16.
//  Copyright © 2016 Imdb Teste Inc. All rights reserved.
//

import UIKit

class Request: NSObject {
    
    private let HOST = "http://www.omdbapi.com/?"
    
    func GET(recurso: String, callback: Dictionary<String, AnyObject> -> ()){
        let request = NSURL(string: "\(HOST)\(recurso)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(request!){(data, response, error) in
            
            var dataToReturn = Dictionary<String, AnyObject>()
            var statusCode = 500
            if( response != nil ){
                let httpResponse = response as! NSHTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            
            var houveErro = false
            if( error != nil || statusCode == 404 || statusCode == 500 ){
                houveErro = true
            }
            dataToReturn["data"] = data
            dataToReturn["houveErro"] = houveErro
            callback( dataToReturn )
        }
        task.resume()
    }
    
}
