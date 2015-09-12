//
//  DetailViewController.swift
//  MailApp
//
//  Created by ShimmenNobuyoshi on 2015/08/10.
//  Copyright (c) 2015年 Shimmen Nobuyoshi. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {

    var showingAlert = false
    var webView: WKWebView!
    var pageUrl: String?
    var showUp = false
    var progressView: UIProgressView!
    var refresh: UIBarButtonItem!
    var bookmarkButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var currentHtml: String?
    var bookmarkTitle = ""
    var alreadyBookmarked = false
    var currentBookmarkId: String?
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.showingAlert {
            self.navigationController?.navigationBarHidden = true
            showAlert("Error", message: "Sorry, there is no plain text for this email")
        } else {
            progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
            progressView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 2)
            progressView.center.x = self.view.center.x
            progressView.trackTintColor = UIColor.hex("#06d0e5", alpha: 1.0)
            progressView.progressTintColor = UIColor.whiteColor()
            setUpButtons()
            let config = WKWebViewConfiguration()
            let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let wkUScript = WKUserScript(source: jScript, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
            let wkUcontentController = WKUserContentController()
            wkUcontentController.addUserScript(wkUScript)
            config.userContentController = wkUcontentController
            self.webView = WKWebView(frame: self.view.frame, configuration: config)
            let url = NSURL(string: pageUrl!)
            self.webView.loadRequest(NSURLRequest(URL: url!))
            webView.center = self.view.center
            webView.navigationDelegate = self
            webView.UIDelegate = self
            webView.scrollView.delegate = self
            webView.allowsBackForwardNavigationGestures = true
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
            webView.addObserver(self, forKeyPath: "canGoBack", options: .New, context: nil)
            webView.addObserver(self, forKeyPath: "canGoForward", options: .New, context: nil)
            webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
            self.view.addSubview(webView)
            self.view.addSubview(progressView)
        }
    }

    func getRidOfStuff() {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "canGoBack")
        webView.removeObserver(self, forKeyPath: "canGoForward")
        webView.removeObserver(self, forKeyPath: "loading")
        webView.navigationDelegate = nil
        webView.scrollView.delegate = nil
    }

    func setUpButtons() {
        let backIcon = UIImage(named: "back")
        backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: "backTapped:")
        backButton.enabled = false

        let forwardIcon = UIImage(named: "forward")
        forwardButton = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: "forwardTapped:")
        forwardButton.enabled = false
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: "reload")
        refresh.enabled = false
        let bookmarkIcon = UIImage(named: "bookmarkButton")
        let coloredbookmark = UIImage(named: "coloredbookmark")
        let bookmarkFrame = CGRectMake(0, 0, bookmarkIcon!.size.width, bookmarkIcon!.size.height)
        let button: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.frame = bookmarkFrame
        button.setBackgroundImage(bookmarkIcon, forState: .Normal)
        button.setBackgroundImage(coloredbookmark, forState: UIControlState.Highlighted)
        button.addTarget(self, action: "bookmarked:", forControlEvents: UIControlEvents.TouchUpInside)
        bookmarkButton = UIBarButtonItem(customView: button)
        bookmarkButton.enabled = false
        toolbarItems = [backButton, spacer, forwardButton, spacer, bookmarkButton, spacer, refresh]
        self.navigationController?.toolbar.tintColor = UIColor.hex("64b6ac", alpha: 1.0)
        self.navigationController?.toolbar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.toolbar.translucent = false
        navigationController?.toolbarHidden = false

        let closeIcon = UIImage(named: "xbutton")
        let closeButton = UIBarButtonItem(image: closeIcon, style: .Plain, target: self, action: "closeTapped:")
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationController?.navigationBar.barTintColor = UIColor.hex("06d0e5", alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
    }

    func closeTapped(sender: AnyObject) {
        self.getRidOfStuff()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func backTapped(sender: AnyObject) {
        self.webView.goBack()
    }

    func forwardTapped(sender: AnyObject) {
        self.webView.goForward()
    }

    func bookmarked(sender: AnyObject) {
        if self.alreadyBookmarked {
            self.alreadyBookmarked = false
            let bookmark = self.queryForBookmark(self.currentBookmarkId!).first
            self.sharedContext.deleteObject(bookmark!)
            self.currentBookmarkId = nil
        } else {
            self.alreadyBookmarked = true
            let time = NSDate()
            let uid = NSUUID().UUIDString
            self.currentBookmarkId = uid
            if self.currentHtml != nil {
                let dict: [String: AnyObject] = ["title": self.title!, "date": time, "html": self.currentHtml!, "id": uid]
                let bookmark = Bookmark(dict: dict, context: self.sharedContext)
            }
        }
        CoreDataStackManager.sharedInstance.saveContext()
    }

    func queryForBookmark(id: String) -> [Bookmark]{
        var error: NSError?
        let fetchRequest = NSFetchRequest(entityName: "Bookmark")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = self.sharedContext.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("Error")
        }
        return results as! [Bookmark]
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
        webView.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML", completionHandler: { (html, error) -> Void in
            if error == nil {
                if let htmlString = html as? String {
                    self.currentHtml = htmlString
                }
            }
        })
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "estimatedProgress":
            if self.progressView.hidden {
                self.progressView.hidden = false
            }
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
        case "loading":
            self.showUp = !self.webView.loading
            self.refresh.enabled = !self.webView.loading
            self.progressView.hidden = !self.webView.loading
            self.bookmarkButton.enabled = !self.webView.loading
        case "canGoBack":
            self.backButton.enabled = self.webView.canGoBack
        case "canGoForward":
            self.forwardButton.enabled = self.webView.canGoForward
        default:
        break
        }
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: {
                self.showingAlert = false
            })
        }
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if showUp {
            let translation = scrollView.panGestureRecognizer.translationInView(scrollView)
            if(translation.y > 0) {
                if self.navigationController?.toolbarHidden == true {
                    self.navigationController?.toolbarHidden = false
                }
            } else {
                if self.navigationController?.toolbarHidden == false {
                    self.navigationController?.toolbarHidden = true
                }
            }
        }
    }

    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.loadRequest(navigationAction.request)
        return nil
    }
}
