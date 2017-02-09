//
//  ImageDownloader.swift
//  iTunesSearch
//
//  Created by Alagu Karthik Prabhu on 05/02/17.
//  Copyright © 2017 kp Alagu. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader
{
    var completionHandler: (() -> Void)?
    var imageData:UIImage?

    private var sessionTask:URLSessionDataTask?
    
    /**
     * start download for the given urlstring, developer should implement completionHandler to receive the response data or error
     * @urlString Http request urlString
     */
    
    func startDownloadWithURLString(urlString:String)  {
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url:URL = URL(string: escapedString!)!
        let session = URLSession.shared
        let request = URLRequest(url: url)
        sessionTask = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                return
            }
            OperationQueue.main.addOperation {
                self.imageData = UIImage(data: data);
                if self.completionHandler != nil
                {
                  self.completionHandler!();
                }
            }
        }
        sessionTask?.resume()
    }
    
    /**
     * cancel download
     */
    func cancelDownload()  {
        if(sessionTask != nil)
        {
            sessionTask?.cancel()
        }
    }
}
