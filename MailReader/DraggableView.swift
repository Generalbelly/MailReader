//
//  DraggableView.swift
//  MailApp
//
//  Created by ShimmenNobuyoshi on 2015/07/04.
//  Copyright (c) 2015年 Shimmen Nobuyoshi. All rights reserved.
//

import UIKit
import WebKit
import CoreData

protocol DraggableViewDelegate {
    func cardLoadingCheck(view: DraggableView, completed: Bool)
    func progressCheck(view: DraggableView, progress: Double)
    func cardCounter(view: DraggableView, swiped: Bool)
}

class DraggableView: WKWebView, UIGestureRecognizerDelegate {
    var selected = false {
        didSet {
            if selected {
                self.hud.removeFromSuperview()
                self.removeGestureRecognizer(self.panGesture)
                self.overlayView.removeFromSuperview()
            }
        }
    }
    var topMail = false {
        didSet {
            if topMail {
                self.hud.removeFromSuperview()
            }
        }
    }
    var messageId: String!
    var labelId: String!
    var delegate: DraggableViewDelegate?
    var panGesture: UIPanGestureRecognizer!
    var originalPoint: CGPoint!
    var xDistance: CGFloat?
    var yDistance: CGFloat?
    var overlayView: OverlayView!
    var plainTextView: UITextView?
    var infoLabel: UILabel?
    var hud: MBProgressHUD!
    var userLeaving = false {
        didSet {
            if userLeaving {
                self.removeObserver(self, forKeyPath: "loading")
                self.removeObserver(self, forKeyPath: "estimatedProgress")
            }
        }
    }
    var htmlString: String? {
        didSet {
            self.loadHTMLString(self.htmlString!, baseURL: nil)
        }
    }
    var textString: String? {
        didSet {
            self.convertToPlainText(textString!)
        }
    }
    var altMessageString: String?
    var enlarged = false {
        didSet {
            if enlarged {
                self.convertToPlainText(self.altMessageString!)
            } else {
                self.plainTextView?.removeFromSuperview()
            }
        }
    }
    var historyId: Int?
    var dict = [String: String]()
    var showInfo = false {
        didSet {
            if showInfo {
                self.InfoCard(self.dict["from"]!, subject: self.dict["subject"]!, to: self.dict["to"]!)
            } else {
                self.infoLabel?.removeFromSuperview()
            }
        }
    }
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }()

    init(frame: CGRect, configuration: WKWebViewConfiguration, dict: [String: String]?) {
        super.init(frame: frame, configuration: configuration)
        self.setup()
        if dict != nil {
            self.dict = dict!
        }
    }

    func convertToPlainText(text: String) {
        plainTextView = UITextView(frame: self.bounds)
        plainTextView!.scrollEnabled = true
        plainTextView!.text = text
        plainTextView!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        plainTextView!.editable = false
        plainTextView!.dataDetectorTypes = UIDataDetectorTypes.Link
        self.addSubview(plainTextView!)
    }

    func InfoCard(from: String, subject: String, to: String) {
        let originalFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 60)
        infoLabel = UILabel(frame: originalFrame)
        infoLabel!.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
        infoLabel!.numberOfLines = 0
        let fromArray = from.componentsSeparatedByString(" <")
        let newFrom = fromArray[0]
        infoLabel!.text = "From: \(newFrom)\nSubject: \(subject)"
        infoLabel!.textAlignment = NSTextAlignment.Left
        infoLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        infoLabel!.textColor = UIColor.whiteColor()
        self.addSubview(infoLabel!)
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func setup() {
        self.hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
        self.hud.mode = MBProgressHUDMode.AnnularDeterminate
        self.hud.labelText = "Loading"
        self.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
        self.addObserver(self, forKeyPath: "loading", options: NSKeyValueObservingOptions.New, context: nil)
        self.originalPoint = self.center
        self.panGesture = UIPanGestureRecognizer(target: self, action: "dragged:")
        self.panGesture.delegate = self
        self.addGestureRecognizer(self.panGesture)
        self.overlayView = OverlayView(frame: self.bounds)
        self.overlayView.alpha = 0
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "estimatedProgress":
            self.hud.progress = Float(self.estimatedProgress)
            self.delegate?.progressCheck(self, progress: self.estimatedProgress)
        case "loading":
            self.hud.hide(!self.loading)
            self.delegate?.cardLoadingCheck(self, completed: !self.loading)
        default:
        break
        }
    }

    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        self.addSubview(self.overlayView)
        xDistance = gestureRecognizer.translationInView(self).x
        yDistance = gestureRecognizer.translationInView(self).y
        var eventOccuringPoint: CGFloat = 100
        switch gestureRecognizer.state {
            case UIGestureRecognizerState.Began:
                originalPoint = self.center
            case UIGestureRecognizerState.Changed:
                if fabsf(Float(xDistance!)) > 50 {
                    var rotationStrength = min(xDistance! / 320, 1)
                    var rotationAngel = CGFloat(2*M_PI)*rotationStrength / 16
                    var scaleStrength = (1 - fabsf(Float(rotationStrength))) / 4
                    var scale = max(CGFloat(scaleStrength), 0.93)
                    self.center = CGPointMake(originalPoint.x + xDistance!, originalPoint.y + yDistance!)
                    var newTransform = CGAffineTransformMakeRotation(rotationAngel)
                    var scaleTransform = CGAffineTransformScale(newTransform, scale, scale)
                    self.transform = scaleTransform
                    self.updateOverlay(xDistance!)
                }
            case UIGestureRecognizerState.Ended:
                if xDistance > eventOccuringPoint {
                    self.cardAway(500)
                } else if xDistance < -eventOccuringPoint {
                    self.cardAway(self.frame.size.width - 500)
                } else {
                    UIView.animateWithDuration(0.1, animations: {
                        self.center = self.originalPoint
                        self.transform = CGAffineTransformMakeRotation(0)
                        self.overlayView.alpha = 0
                    })
                }
            default:
                break
        }
    }

    func cardAway(x: CGFloat) {
        if x < 500 {
            self.changeLabels(self.overlayView.mode!)
        } else {
            self.changeLabels(self.overlayView.mode!)
        }
        self.userLeaving = true
        self.delegate?.cardCounter(self, swiped: true)
        if self.yDistance == nil {
            self.yDistance = 0
        }
        let point = CGPointMake(x, 2 * self.yDistance! + self.originalPoint.y)
        UIView.animateWithDuration(0.3, animations: {
            self.center = point
        }, completion: { complete in
            if complete {
                self.removeFromSuperview()
            }
        })
    }

    func updateOverlay(distance: CGFloat) {
        if distance > 0 {
            self.overlayView.mode = OverlayMode.Right
        } else if distance <= 0 {
            self.overlayView.mode = OverlayMode.Left
        }
        let floatDis = Float(distance)
        var overlayStrength = min(fabsf(floatDis) / 100, 0.7)
        self.overlayView.alpha = CGFloat(overlayStrength)
    }

    func changeLabels(mode: OverlayMode) {
        let query = GTLQueryGmail.queryForUsersMessagesModify() as! GTLQueryGmail
        query.identifier = self.messageId
        if mode == .Left {
            query.addLabelIds = ["TRASH"]
            query.removeLabelIds = ["UNREAD", "INBOX"]
        } else {
            query.removeLabelIds = ["UNREAD"]
        }
        GmailClientHelper.sharedInstance.service.executeQuery(query) { ticket, response, error in
            if error == nil {
                self.deleteMailFromCoreData()
                if mode == .Right {
                    self.addMailToBookmarks()
                }
                CoreDataStackManager.sharedInstance.saveContext()
            }
        }
    }

    func deleteMailFromCoreData() {
        var error: NSError?
        var fetchRequest = NSFetchRequest(entityName: "Mail")
        fetchRequest.predicate = NSPredicate(format: "id == %@", self.messageId)
        let results = self.sharedContext.executeFetchRequest(fetchRequest, error: &error) as! [Mail]
        if error != nil {
            println("Error")
        }
        self.sharedContext.deleteObject(results.first!)
    }

    func addMailToBookmarks() {
        var subject = ""
        if let title = self.dict["subject"] as String! {
            subject = title
        }
        let time = NSDate()
        let uid = NSUUID().UUIDString
        let dict: [String: AnyObject] = ["title": subject, "date": time, "html": self.htmlString!, "id": uid]
        let bookmark = Bookmark(dict: dict, context: self.sharedContext)
    }

}
