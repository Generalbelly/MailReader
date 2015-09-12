//
//  GmailConstants.swift
//  MailApp
//
//  Created by ShimmenNobuyoshi on 2015/07/02.
//  Copyright (c) 2015年 Shimmen Nobuyoshi. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class LoginViewController: UIViewController {

    var label: Label? {
        didSet {
            if label != nil {
                self.performSegueWithIdentifier("toHomeView", sender: self)
            }
        }
    }
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        GmailClientHelper.sharedInstance.service.authorizer = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(GmailClientHelper.Keys.kKeychainItemName, clientID: GmailClientHelper.Keys.kClientID, clientSecret: GmailClientHelper.Keys.kClientSecret)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if GmailClientHelper.sharedInstance.service.authorizer.canAuthorize == false {
            self.presentViewController(self.createAuthController, animated: true, completion: nil)
        } else {
            let queryArray = GmailClientHelper.sharedInstance.queryForLabel("UNREAD")
            if queryArray.count == 0 {
                self.fetchUnreadAndTrash()
            } else {
                self.label = queryArray.first
            }
        }
    }

    var createAuthController: GTMOAuth2ViewControllerTouch {
        var scopes = [kGTLAuthScopeGmail]
        let quote = ""
        let authController = GTMOAuth2ViewControllerTouch(scope: quote.join(scopes), clientID: GmailClientHelper.Keys.kClientID, clientSecret: GmailClientHelper.Keys.kClientSecret, keychainItemName: GmailClientHelper.Keys.kKeychainItemName) { viewController, authResult, error in
            if error != nil {
                self.showAlert("Authentication Error", message: error!.localizedDescription)
                GmailClientHelper.sharedInstance.service.authorizer = nil
            } else {
                GmailClientHelper.sharedInstance.service.authorizer = authResult
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.fetchUnreadAndTrash()
        return authController
    }

    func fetchUnreadAndTrash() {
        var query = GTLQueryGmail.queryForUsersLabelsList() as! GTLQueryGmail
        GmailClientHelper.sharedInstance.service.executeQuery(query) { ticket, response, error in
            if error == nil {
                if let labelsResponse = response as? GTLGmailListLabelsResponse {
                    if labelsResponse.labels.count > 0 {
                        for label in labelsResponse.labels {
                            let item = label as! GTLGmailLabel
                            let id = item.identifier as String
                            let labelId = item.name as String
                            var queryArray = GmailClientHelper.sharedInstance.queryForLabel(labelId)
                            if labelId == "UNREAD" {
                                if queryArray.count == 0 {
                                    let dict: [String: AnyObject] = ["id": id, "labelId": labelId]
                                    let label = Label(dict: dict, context: self.sharedContext)
                                    self.label = label
                                }
                            } else if labelId == "TRASH" {
                                if queryArray.count == 0 {
                                    let dict: [String: AnyObject] = ["id": id, "labelId": labelId]
                                    let label = Label(dict: dict, context: self.sharedContext)
                                }
                            }
                        }
                        CoreDataStackManager.sharedInstance.saveContext()
                    }
                }
            } else {
                self.showAlert("Error", message: error!.localizedDescription)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UITabBarController
        var navCon = destination?.viewControllers?.first as? UINavigationController
        if let mvc = navCon!.viewControllers?.first as? MailViewController {
            if segue.identifier == "toHomeView" {
                mvc.label = self.label
            }
        }
    }

    func showAlert(title: String, message: String) {
        var alert: UIAlertView
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

