//
//  HttpConnection.swift
//  PixabayVideoStreaming
//
//  Created by Alagu Karthik Prabhu on 11/01/17.
//  Copyright © 2017 kp Alagu. All rights reserved.
//

import Foundation

protocol HttpConnectionDelegate {
    func didReceiveData(data:Data,forURLString:String);
    func didReceiveDataFailure(error:Error);
}


class HttpConnection
{
    
    var delegate:HttpConnectionDelegate!;
    
    /**
     * Get the data for given urlstring, developer should implement HttpConnectionDelegate to receive the response or error
     * @urlString http urlString
     */
    
    func getDataForURLString(urlString:String) {
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url:URL = URL(string: escapedString!)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("error")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate?.didReceiveDataFailure(error: error!)
                    
                })
                return
            }
            
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            print(dataString!)
            DispatchQueue.main.async(execute: { () -> Void in
                self.delegate?.didReceiveData(data: data, forURLString:(request.url?.absoluteString)!)
            })
            
        }
        task.resume()
    }
}
