//
//  PageItemController.swift
//  StudyEnglish
//
//  Created by ShimmenNobuyoshi on 2014/12/27.
//  Copyright (c) 2014年 Shimmen Nobuyoshi. All rights reserved.
//

import UIKit
import Foundation
import CoreData

enum LoadingReasons {
    case Reloaded
    case FirstTime
    case UserOnTheBottom

}


class TrashTableViewController: UITableViewController, MGSwipeTableCellDelegate {
    
    var hud: MBProgressHUD!
    var selectedMail: Mail?
    var reloaded = false

    // when user scroll to bottom, these are needed to figure out which mails are new (user doesn't see yet)
    var timesOfScrollingToBottom = 1
    var oldestMailHistoryId = 0
    var newestMailHistoryId = 0
    var newMailCounter = 0
    var mailsCounted = 15

    var reason: LoadingReasons!
    var newMails = [Mail]()

    var mailsInTrash = [Mail]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()){
                print("\(self.mailsInTrash.count)\n")
                print("\(self.mailsCounted)\n")
                if self.mailsInTrash.count == self.mailsCounted {
                    self.reloadData()
                } else if self.reason == .FirstTime {
                    self.reloadData()
                }
            }
        }
    }
    var label: Label!
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }()
    @IBAction func refresh(sender: UIRefreshControl) {
        self.reloaded = true
        self.loadMails(LoadingReasons.Reloaded)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.label = GmailClientHelper.sharedInstance.queryForLabel("TRASH").first
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.label.mails.isEmpty {
            self.loadMails(LoadingReasons.FirstTime)
        } else {
            self.mailsCounted = self.label.mails.count
            var mailsToSort = self.label.mails as NSArray!
            let descriptor = [NSSortDescriptor(key: "historyId", ascending: false)]
            let sortedMails = mailsToSort.sortedArrayUsingDescriptors(descriptor) as! [Mail]
            self.mailsInTrash = sortedMails
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//        for item in self.mailsInTrash {
//            self.sharedContext.deleteObject(item)
//        }
//        self.mailsInTrash.removeAll()
//        CoreDataStackManager.sharedInstance.saveContext()
    }

    func reloadData() {
        self.oldestMailHistoryId = self.mailsInTrash.last?.historyId as! Int
        self.newestMailHistoryId = self.mailsInTrash.first?.historyId as! Int
        self.tableView.reloadData()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        if self.hud != nil {
            self.hud.hide(true)
        }
        if self.refreshControl!.refreshing == true {
            self.refreshControl!.endRefreshing()
        }
    }

    func setupHUD() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.labelText = "Loading"
    }

    func loadMails(reason: LoadingReasons) {
        self.setupHUD()
        var max = 0
        switch reason {
            case .Reloaded:
                max = self.mailsInTrash.count
            case .FirstTime:
                max = mailsCounted
            case .UserOnTheBottom:
                self.mailsCounted = mailsInTrash.count
                max = self.timesOfScrollingToBottom * mailsCounted
            default:
                break
        }
        GmailClientHelper.sharedInstance.fetchMailList(self.label, label2: nil, maxNumber: max) { success, results, error in
            if success && results != nil {
                if results?.count > 0 {
                    GmailClientHelper.sharedInstance.fetchMail(results!, labelToBelongTo: self.label) { success, error, mails in
                        if success {
                            var mailsToSort = mails as NSArray!
                            let descriptor = [NSSortDescriptor(key: "historyId", ascending: false)]
                            let sortedMails = mailsToSort.sortedArrayUsingDescriptors(descriptor) as! [Mail]
                            switch reason {
                                case .FirstTime:
                                    self.reason = .FirstTime
                                    self.mailsInTrash = sortedMails
                                case .Reloaded:
                                    for item in sortedMails {
                                        let hisId = item.historyId as Int
                                        if hisId > self.newestMailHistoryId {
                                            self.newMails.append(item)
                                        }
                                    }
                                    self.mailsCounted = self.mailsInTrash.count + self.newMails.count
                                    if self.newMails.count == 0 {
                                        self.hud.hide(true)
                                        self.refreshControl!.endRefreshing()
                                    } else {
                                        for item in self.newMails.reverse() {
                                            self.mailsInTrash.insert(item, atIndex: 0)
                                        }
                                    }
                                case .UserOnTheBottom:
                                    for item in sortedMails {
                                        let hisId = item.historyId as Int
                                        if hisId < self.oldestMailHistoryId {
                                            self.newMails.append(item)
                                        }
                                    }
                                    self.mailsCounted = self.mailsInTrash.count + self.newMails.count
                                    print("NEWMAIL is\(self.newMails.count)")
                                    for item in self.newMails {
                                        self.mailsInTrash.append(item)
                                    }
                            }
                        } else {
                            self.showAlert("Error", message: error!.localizedDescription)
                        }
                    }
                }
            } else if error != nil {
                self.showAlert("Error", message: error!.localizedDescription)
            }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mailsInTrash.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("trashCell", forIndexPath: indexPath) as! TrashTableViewCell
        let mail = self.mailsInTrash[indexPath.row] as Mail
        cell.subject!.text = mail.subject
        let fromArray = mail.from.componentsSeparatedByString(" <")
        let newFrom = fromArray[0]
        cell.from!.text = newFrom
        cell.snippet!.text = mail.snippet
        cell.delegate = self
        if indexPath.row == self.mailsInTrash.count - 1 {
            self.timesOfScrollingToBottom += 1
            self.loadMails(LoadingReasons.UserOnTheBottom)
        }
        return cell
    }

    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }

    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        swipeSettings.transition = MGSwipeTransition.Border
        let indexPath = self.tableView.indexPathForCell(cell)
        if direction == MGSwipeDirection.LeftToRight {
            let button = MGSwipeButton(title: "UNREAD", backgroundColor: UIColor.hex("64b6ac", alpha: 1.0)){ sender in
                let query = GTLQueryGmail.queryForUsersMessagesModify() as! GTLQueryGmail
                let mail = self.mailsInTrash[indexPath!.row]
                query.identifier = mail.id
                query.addLabelIds = ["UNREAD", "INBOX"]
                query.removeLabelIds = ["TRASH"]
                GmailClientHelper.sharedInstance.service.executeQuery(query) { ticket, response, error in
                    if error == nil {
                        mail.label = GmailClientHelper.sharedInstance.queryForLabel("UNREAD").first!
                        self.mailsInTrash.removeAtIndex(indexPath!.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Left)
                        CoreDataStackManager.sharedInstance.saveContext()
                    }
                }
                return false
            }
            return [button]
        }
        return nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mail = self.mailsInTrash[indexPath.row] as Mail
        self.selectedMail = mail
        self.performSegueWithIdentifier("show", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show" {
            let mvc = segue.destinationViewController as! MailViewController
            mvc.selectedMail = self.selectedMail
            print(self.selectedMail!.subject)
        }
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

