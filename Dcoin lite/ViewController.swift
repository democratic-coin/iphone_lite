//
//  ViewController.swift
//  Dcoin lite
//
//  Created by Andrey on 12.04.16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var placeholderView: UIView!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.frame)
        webView.center = view.center
        placeholderView.addSubview(webView)
        
        webView.navigationDelegate = self
        let url = NSURL(string: "http://getpool.dcoin.club")
        NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            guard error == nil else {
                print("Error \(error?.userInfo)")
                return
            }
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            as! [String: String]
            
            dispatch_async(dispatch_get_main_queue(), { 
                let request = NSURLRequest(URL: NSURL(string: json["pool"]!)!)
                self.webView.loadRequest(request)
            })
            
        }.resume()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("provisional navigation")
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        let path = request.URL?.absoluteString
        
        if let isThere = path?.containsString("dcoinKey") where isThere {
            decisionHandler(.Cancel)
            let str = request.URL!.absoluteString + "&ios=1&first=1"
            let url = NSURL(string: str)!
            print("downloading key \(url)")
            dispatch_async(dispatch_get_main_queue(), {
                if let data = NSData(contentsOfURL: url) {
                    if let img = UIImage(data: data) {
                         UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                    }
                }
            })
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
        print("decidePolicyForNavigationAction")
    }
}

