//
//  Helper.swift
//  Imdb
//
//  Created by jenkins on 08/05/16.
//  Copyright © 2016 Imdb Teste Inc. All rights reserved.
//

import UIKit

class Helper: NSObject {
    var globalBackgroundQueue : dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
    var globalMainQueue : dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    func convertDataToDictionary( data: NSData, houveErro: Bool ) -> NSDictionary{
        var dictionary = NSDictionary()
        
        if( houveErro ){
            dictionary = createDictionaryWithErrorMessage()
            return dictionary
        }
        
        if( data.length > 0 && !houveErro ){
            do {
                dictionary = try NSJSONSerialization.JSONObjectWithData( data, options: NSJSONReadingOptions.MutableContainers ) as! NSDictionary
            } catch {
                print(error)
            }
        }
        return dictionary
    }
    
    func createDictionaryWithErrorMessage() -> NSDictionary {
        var dictionary = NSDictionary()
        do {
            let msg = "Ocorreu um erro com a conexão com o servidor, tente novamente!"
            let objeto: NSString = "{ \"message\" : \"\(msg)\" }"
            let data = objeto.dataUsingEncoding( NSUTF8StringEncoding )
            dictionary = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.MutableContainers ) as! NSDictionary
        } catch {
            print(error)
        }
        return dictionary
    }
}


