//
//  ViewController.swift
//  PixabayVideoStreaming
//
//  Created by Alagu Karthik Prabhu on 10/01/17.
//  Copyright © 2017 kp Alagu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, HttpConnectionDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoTextField: UITextField!
    var httpConnection:HttpConnection?
    var pixabayVideoLists = [PixabayVideoModel]()
    var imageDownloaderInProgress:[ImageDownloader]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        httpConnection = HttpConnection();
        httpConnection?.delegate = self;
        httpConnection?.getDataForURLString(urlString: pixabayURLWithAPIKey + "animation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICOllectionView Datasource and Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pixabayVideoLists.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoListCollectionViewCell", for: indexPath) as! VideoListCollectionViewCell
        
        if (pixabayVideoLists[indexPath.row].thumbnail_ImageData) == nil
        {
               cell.imageView?.image = UIImage(named: "sampleImage", in: nil, compatibleWith: nil);
            if (self.collectionView.isDragging == false && self.collectionView.isDecelerating == false)
            {
            startImageDownloaderForIndexPath(indexPath: indexPath)
            }
        }
        else
        {
        cell.imageView?.image = self.pixabayVideoLists[indexPath.row].thumbnail_ImageData
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "VideoListCollectionViewSectionHeader", for: indexPath)
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(10,10,0,10)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let urlString:String =  self.pixabayVideoLists[indexPath.row].videoUrl
        {
            playVideoForURL(urlString:urlString);
        }
    }
    
    // MARK: ImageDownloader
    /*
     * Create new ImageDownloader instance and start image downloader, get the image data from the ImageDownloader completion handler
     * Store the imageDownloader instance in imageDownloaderInProgress to avoid repeated dwonloads
     * cache the downloaded Image
     *
     * @param indexPath indexpath to download
     */
    func startImageDownloaderForIndexPath(indexPath:IndexPath)  {
        var imageDownloader = imageDownloaderInProgress?[indexPath.row]
        if(imageDownloader == nil)
        {
            imageDownloader = ImageDownloader()
            imageDownloader?.imageData = ((self.pixabayVideoLists[indexPath.row]) as PixabayVideoModel).thumbnail_ImageData
            print("IndexPath \(indexPath)")
            imageDownloader?.completionHandler = {
                () -> Void in
                if let cell:VideoListCollectionViewCell = self.collectionView.cellForItem(at:indexPath) as? VideoListCollectionViewCell
                {
                    if((self.pixabayVideoLists.count) > 0)
                    {
                        self.pixabayVideoLists[indexPath.row].thumbnail_ImageData = imageDownloader?.imageData;
                        cell.imageView?.image = self.pixabayVideoLists[indexPath.row].thumbnail_ImageData;
                        self.imageDownloaderInProgress?.remove(at: indexPath.row);
                    }
                }
            }
        }
        self.imageDownloaderInProgress?[indexPath.row] = imageDownloader!
        if((self.pixabayVideoLists.count) > 0)
        {
            if let imageURLString = self.pixabayVideoLists[indexPath.row].thumbnail_URLString
            {
                imageDownloader?.startDownloadWithURLString(urlString:imageURLString )
            }
        }
        
    }
    
    //MARK: IBActions
    @IBAction func searchButtonClicked(_ sender: Any) {
        let userEnteredTrimmedText:String! = videoTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        if (userEnteredTrimmedText.isEmpty == false){
            if  httpConnection == nil
            {
                httpConnection = HttpConnection();
                httpConnection?.delegate = self;
            }
            httpConnection?.getDataForURLString(urlString: pixabayURLWithAPIKey + "\(userEnteredTrimmedText!)")
        }
    }

    func playVideoForURL(urlString: String) {
        let videoURL = NSURL(string: urlString);//"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    //MARK: HTTPConnection Delegate
    func didReceiveData(data:Data,forURLString:String)
    {
        let pixabayParser = PixabayVideoListParser.init(data: data);
        self.pixabayVideoLists = pixabayParser.pixabayVideoModelDatas;
        print(pixabayParser);
        self.collectionView.reloadData()
        
    }
    
    func didReceiveDataFailure(error:Error)
    {
        showAlert(title: "Pixabay",message: error.localizedDescription)
    }
    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField .resignFirstResponder();
        return true;
    }
    
    // MARK: Alerts
    
    func showAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message , preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /**
     * Start ImageDownloader only for the visible tableview cells
     */
    func loadImagesOnlyForVisibleCellRows()
    {
        if (self.pixabayVideoLists.count > 0)
        {
            let visiblePaths = self.collectionView.indexPathsForVisibleItems
            for indexPath in visiblePaths {
                if(self.pixabayVideoLists[indexPath.row].thumbnail_ImageData == nil)
                {
                    startImageDownloaderForIndexPath(indexPath: indexPath)
                }
            }
        }
        
    }
    
    // MARK: Scrollview Delegate
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if (!decelerate)
        {
            loadImagesOnlyForVisibleCellRows()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) // called when scroll view grinds to a halt
    {
        loadImagesOnlyForVisibleCellRows()
    }
}

