//
//  MailViewController.swift
//  MailApp
//
//  Created by ShimmenNobuyoshi on 2015/07/04.
//  Copyright (c) 2015年 Shimmen Nobuyoshi. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import WebKit

class MailViewController: UIViewController, DraggableViewDelegate, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {

    // for mail in trash
    var selectedMail: Mail?

    // for bookmark
    var selectedBookmark: Bookmark?

    var label: Label! { didSet { self.labelId = label.labelId } }
    var labelId: String?
    var hud: MBProgressHUD!
    var pageUrl: String?
    var pageTitle: String?
    var showingAlert = false
    var cardsToLoad = 10
    var counter = 0
    var readerButton = UIBarButtonItem()
    var infoButton = UIBarButtonItem()
    var numberOfCards = 0 { didSet { counter = numberOfCards - 1 } }
    var cardsStack = [DraggableView]() {
        didSet {
            if selectedMail != nil || selectedBookmark != nil {
                if cardsStack.count > 0 {
                    let item = cardsStack.first!
                    item.tag = 0
                    item.selected = true
                    item.delegate = self
                    item.navigationDelegate = self
                    item.UIDelegate = self
                    item.scrollView.delegate = self
                    self.view.insertSubview(item, belowSubview: self.hud)
                    self.disableButton()
                    cardsStack.removeAll()
                }
            } else {
                if numberOfCards > 0 && cardsStack.count == numberOfCards {
                    let orderedStack = cardsStack.sorted() { $1.historyId > $0.historyId }
                    for (index, item) in enumerate(orderedStack) {
                        item.tag = index
                        if index == numberOfCards - 1 {
                            item.topMail = true
                        }
                        item.delegate = self
                        item.navigationDelegate = self
                        item.UIDelegate = self
                        item.scrollView.delegate = self
                        self.view.insertSubview(item, belowSubview: self.hud)
                    }
                    self.disableButton()
                    cardsStack.removeAll()
                }
            }
        }
    }
    @IBOutlet weak var smile: UIImageView!
    @IBOutlet weak var nomoreMessage: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBAction func reloadTapped(sender: AnyObject) {
        self.loadMails()
    }

    // view life cycle

    override func viewDidLoad() {
        self.navigationController?.navigationBar.barTintColor = UIColor.hex("#06d0e5", alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.setUpButtons()
        super.viewDidLoad()
        self.setupHUD()
        if self.selectedMail != nil {
            self.navigationItem.title = "Trash"
            self.createCard(self.selectedMail!, bookmark: nil)
        } else if self.selectedBookmark != nil {
            self.navigationItem.title = "Bookmark"
            self.createCard(nil, bookmark: self.selectedBookmark)
        } else {
            if self.label.mails.isEmpty {
                self.loadMails()
            } else {
                self.numberOfCards = self.label.mails.count
                for item in self.label.mails {
                    self.createCard(item, bookmark: nil)
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.reloadButton.hidden == false && self.counter == 0 {
            if self.selectedMail == nil && self.selectedBookmark == nil {
                self.loadMails()
            }
        }
    }

    func loadMails() {
        self.setupHUD()
        GmailClientHelper.sharedInstance.fetchMailList(self.label, label2: "INBOX",maxNumber: self.cardsToLoad) { success, results, error in
            if success && results != nil {
                if results?.count > 0 {
                    self.numberOfCards = results!.count
                    GmailClientHelper.sharedInstance.fetchMail(results!, labelToBelongTo: self.label) { success, error, cardsToMake in
                        if success {
                            for item in cardsToMake! {
                                self.createCard(item, bookmark: nil)
                            }
                        } else {
                            self.showAlert("Error", message: error!.localizedDescription)
                        }
                    }
                } else {
                    self.showAlert("No message", message: "There is no message related to this label")
                }
            } else if error != nil {
                self.showAlert("Error", message: error!.localizedDescription)
            } else {
                self.hud.hide(true)
                self.smile.hidden = false
                self.nomoreMessage.hidden = false
                self.readerButton.enabled = false
                self.infoButton.enabled = false
            }
        }
    }

    func setupHUD() {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.AnnularDeterminate
        self.hud.labelText = "Loading"
    }

    func disableButton() {
        self.reloadButton.hidden = false
        self.readerButton.enabled = false
        self.infoButton.enabled = false
    }

    func setUpButtons() {

        let pointY = self.view.frame.size.height - 200
        let borderWith: CGFloat = 1.5
        let borderColor = UIColor.hex("#06d0e5", alpha: 1.0).CGColor

        reloadButton.layer.masksToBounds = true
        reloadButton.layer.cornerRadius = 0.5 * reloadButton.bounds.size.width

        // info button
        let infoIcon = UIImage(named: "info")
        infoButton = UIBarButtonItem(image: infoIcon, style: .Plain, target: self, action: "tapped:")
        infoButton.tag = 0
        infoButton.enabled = false

        // reader button
        let readerIcon = UIImage(named: "reader")
        readerButton = UIBarButtonItem(image: readerIcon, style: .Plain, target: self, action: "tapped:")
        readerButton.tag = 1
        readerButton.enabled = false
        
        self.navigationItem.rightBarButtonItems = [readerButton, infoButton]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

    }

    func tapped(button: UIButton) {
        let index = self.view.subviews.count - 1
        if let draggableView = self.view.subviews[index] as? DraggableView {
            switch button.tag {
            case 0:
            if draggableView.showInfo {
                draggableView.showInfo = false
            } else {
                draggableView.showInfo = true
            }
            case 1:
                if draggableView.enlarged {
                    draggableView.enlarged = false
                } else if draggableView.enlarged == false && draggableView.altMessageString != nil {
                    draggableView.enlarged = true
                } else {
                    self.showingAlert = true
                    self.performSegueWithIdentifier("detail", sender: self)
                }
            default:
            break
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let dvc = destination as? DetailViewController {
            if segue.identifier == "detail" {
                if self.showingAlert {
                    dvc.showingAlert = true
                    self.showingAlert = false
                } else {
                    dvc.pageUrl = self.pageUrl!
                }
            }
        }
    }

    // delegate methods

    func cardLoadingCheck(view: DraggableView, completed: Bool) {
        if view.tag == self.counter && completed == true {
//            self.hud.hide(true)
            self.hud.hidden = true
            if self.selectedBookmark == nil {
                self.readerButton.enabled = true
                self.infoButton.enabled = true
            }
        }
    }

    func progressCheck(view: DraggableView, progress: Double) {
        if view.tag == self.counter {
            self.hud.progress = Float(progress)
        }
    }

    func cardCounter(view: DraggableView, swiped: Bool) {
        counter -= 1
    }

    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        if webView.tag == self.counter && self.hud.hidden {
            self.pageUrl = webView.URL?.absoluteString
            print(self.pageUrl)
            self.performSegueWithIdentifier("detail", sender: self)
            decisionHandler(WKNavigationResponsePolicy.Cancel)
        } else {
            decisionHandler(WKNavigationResponsePolicy.Allow)
        }
    }

    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if webView.tag == self.counter {
            print("SHOw4")
            self.pageUrl = navigationAction.request.URL?.absoluteString
            print(self.pageUrl)
            self.performSegueWithIdentifier("detail", sender: self)
        }
        return nil
    }

    func createCard(mail: Mail?, bookmark: Bookmark?) {
        let cardFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkUScript = WKUserScript(source: jScript, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
        let wkUcontentController = WKUserContentController()
        wkUcontentController.addUserScript(wkUScript)
        let config = WKWebViewConfiguration()
        let cardView: DraggableView
        config.userContentController = wkUcontentController
        if bookmark == nil {
            let dict = [
                "from": mail!.from,
                "subject": mail!.subject,
                "to": mail!.to
            ]
            cardView = DraggableView(frame: cardFrame, configuration: config, dict: dict)
            cardView.messageId = mail!.id
            cardView.labelId = self.labelId
            cardView.center.x = view.center.x
            cardView.htmlString = mail!.message
            switch mail!.mimeType {
            case "text/plain":
                cardView.textString = mail!.message
            case "multipart/alternative":
                cardView.htmlString = mail!.message
                if mail!.altMessage != nil {
                    cardView.altMessageString = mail!.altMessage
                    if cardView.htmlString == "" {
                        cardView.enlarged = true
                    }
                }
            case "multipart/mixed":
                cardView.htmlString = mail!.message
                if mail!.altMessage != nil {
                    cardView.altMessageString = mail!.altMessage
                    if cardView.htmlString == "" {
                        cardView.enlarged = true
                    }
                }
            case "text/html":
                cardView.htmlString = mail!.message
            default:
                print("Not expected")
            }
            cardView.historyId = mail!.historyId as Int
        } else {
            cardView = DraggableView(frame: cardFrame, configuration: config, dict: nil)
            cardView.htmlString = self.selectedBookmark?.html
        }
        self.cardsStack.append(cardView)
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}