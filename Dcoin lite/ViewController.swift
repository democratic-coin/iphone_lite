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
    var webView: WKWebView!
    var request: NSURLRequest?
    var poolURL: NSURL?
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRectMake(0, 20, view.frame.width, view.frame.height - 20)
        webView = WKWebView(frame: frame)
        view.addSubview(webView);
        webView.navigationDelegate = self
        let url = NSURL(string: "http://getpool.dcoin.club")
        NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            guard error == nil else {
                print("Error \(error?.userInfo)")
                return
            }
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            as! [String: String]
            guard let url = json["pool"] else {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.poolURL = NSURL(string: url)
                self.request = NSURLRequest(URL: self.poolURL!)
                self.webView.loadRequest(self.request!)
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
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        let resp = navigationResponse.response as! NSHTTPURLResponse
        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(resp.allHeaderFields as! [String:String], forURL: resp.URL!)
        
        for cookie in cookies {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
        }
        
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        
        let path = request.URL?.absoluteString
        
        if let isThere = path?.containsString("dcoinKey") where isThere {
            decisionHandler(.Cancel)
            let str = request.URL!.absoluteString + "&ios=1&first=1"
            let url = NSURL(string: str)!
            print("downloading key \(url)")
            if let data = NSData(contentsOfURL: url) {
                if let img = UIImage(data: data) {
                     UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                }
            }
            return
        }
        
        if let poolName = poolURL?.absoluteString, let path = path where !(path.containsString(poolName)) {
            let url = NSURL(string: path)!
            UIApplication.sharedApplication().openURL(url)
            decisionHandler(.Cancel)
            return
        }
        
        decisionHandler(.Allow)
    }
    
    
    @IBAction func menu(sender: AnyObject) {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        let session = NSURLSession(configuration: config)
        let url = "\(request!.URL!.absoluteString)/ajax?controllerName=menu"
        session.dataTaskWithURL(NSURL(string: url)!).resume()
    }
    
}

