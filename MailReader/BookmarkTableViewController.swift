//
//  BookmarkTableViewController.swift
//  MailApp
//
//  Created by ShimmenNobuyoshi on 2015/09/04.
//  Copyright (c) 2015年 Shimmen Nobuyoshi. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class BookmarkTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MGSwipeTableCellDelegate {

    var hud: MBProgressHUD!
    var selectedBookmark: Bookmark?
    var bookmarks = [Bookmark]()
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }()

    func fetchAllBookmarks() -> [Bookmark]{
        var error: NSError?
        let fetchRequest = NSFetchRequest(entityName: "Bookmark")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let results = self.sharedContext.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println("Error")
        }
        return results as! [Bookmark]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.hex("#06d0e5", alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.bookmarks = fetchAllBookmarks()
        if self.bookmarks.isEmpty {
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.tableFooterView = UIView()
        } else {
            self.tableView.estimatedRowHeight = tableView.rowHeight
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.reloadData()
        }
    }

    func setupHUD() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.labelText = "Loading"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("bookmarkCell", forIndexPath: indexPath) as! MGSwipeTableCell
        let bookmark = self.bookmarks[indexPath.row] as Bookmark
        cell.textLabel!.text = bookmark.title
        cell.delegate = self
        return cell
    }

    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }

    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        swipeSettings.transition = MGSwipeTransition.Border
        let indexPath = self.tableView.indexPathForCell(cell)
        if direction == MGSwipeDirection.LeftToRight {
            let button = MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor()){ sender in
                let bookmark = self.bookmarks[indexPath!.row]
                self.bookmarks.removeAtIndex(indexPath!.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Left)
                self.sharedContext.deleteObject(bookmark)
                CoreDataStackManager.sharedInstance.saveContext()
                return false
            }
            return [button]
        }
        return nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let bookmark = self.bookmarks[indexPath.row] as Bookmark
        self.selectedBookmark = bookmark
        self.performSegueWithIdentifier("showFromBookmark", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFromBookmark" {
            let mvc = segue.destinationViewController as! MailViewController
            mvc.selectedBookmark = self.selectedBookmark
        }
    }

    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "bookmark")
    }

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var title = "No bookmarks yet"
        var attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        return NSAttributedString(string: title, attributes: attributes)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var description = "Emails and websites you bookmark are goning to show up here"
        var paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        var attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14), NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: description, attributes: attributes)
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
