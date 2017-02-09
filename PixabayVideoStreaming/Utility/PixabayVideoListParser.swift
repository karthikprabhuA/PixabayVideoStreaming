//
//  PixabayVideoListParser.swift
//  PixabayVideoStreaming
//
//  Created by Alagu Karthik Prabhu on 11/01/17.
//  Copyright © 2017 kp Alagu. All rights reserved.
//

import Foundation

class PixabayVideoListParser {
    var pixabayVideoModelDatas = [PixabayVideoModel]()
    
    init(data:Data) {
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
            if let videoList:[NSDictionary] = parsedData["hits"] as! [NSDictionary]?
            {
                for videoData in videoList {
                    print("Value = \(videoData)")
                    if let videosDict = videoData.value(forKey: "videos" ) as? Dictionary<String, AnyObject> {
                        if let videoMediumDict = videosDict["medium"] as? Dictionary<String, AnyObject> {
                            if let videoUrl = videoMediumDict["url"] as?String {
                                let imageIcon:String = "https://i.vimeocdn.com/video/\(videoData.value(forKey: "picture_id") as! String)_200x150.jpg"
                                print("icon = \(imageIcon)")
                                pixabayVideoModelDatas.append(PixabayVideoModel(thumbnail_URLString: imageIcon, videoUrl: videoUrl , tags: videoData.value(forKey: "tags") as? String, thumbnail_ImageData:nil))
                            }
                        }
                        
                    }
                    
                }
            }
            
        }
        catch {
            
            print("JSON Processing Failed")
        }
    }
}
