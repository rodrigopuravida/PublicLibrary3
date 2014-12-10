//
//  ViewController.swift
//  MyBook
//
//  Created by Rodrigo Carballo on 12/4/14.
//  Copyright (c) 2014 Rodrigo Carballo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    // Create an empty array of books
    var bookItems = [BookItem]()
    
    
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    var bookTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        BookItem.createInManagedObjectContext(self.managedObjectContext!, title: "Moby Dick", shelfLocation: "1")
        BookItem.createInManagedObjectContext(self.managedObjectContext!, title: "Tom Sawyer", shelfLocation: "2")
        BookItem.createInManagedObjectContext(self.managedObjectContext!, title: "Dracula", shelfLocation: "2")
        BookItem.createInManagedObjectContext(self.managedObjectContext!, title: "Hamlet", shelfLocation: "1")

        //presentItemInfo()
        
        // Now that the view loaded, we have a frame for the view, which will be (0,0,screen width, screen height)
        // This is a good size for the table view as well, so let's use that
        // The only adjust we'll make is to move it down by 20 pixels, and reduce the size by 20 pixels
        // in order to account for the status bar
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        // Adjust it down by 20 points
        viewFrame.origin.y += 20
        
        // Reduce the total height by 20 points
        viewFrame.size.height -= 20
        
        // Set the logTableview's frame to equal our temporary variable with the full size of the view
        // adjusted to account for the status bar height
        bookTableView.frame = viewFrame
        
        // Add the table view to this view controller's view
        self.view.addSubview(bookTableView)
        
        // Here, we tell the table view that we intend to use a cell we're going to call "LogCell"
        // This will be associated with the standard UITableViewCell class for now
        bookTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "BookCell")
        
        // This tells the table view that it should get it's data from this class, ViewController
        bookTableView.dataSource = self
        bookTableView.delegate = self

        //println(managedObjectContext!)
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchBook()
        
        //Add in the "" button at the button
        let addButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        addButton.setTitle("+", forState: .Normal)
        addButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        addButton.addTarget(self, action: "addNewBook", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(addButton)
        
        //reduce the total height by 20 points for the status bar,and 44 points for the bottom button
        viewFrame.size.height -= (20 + addButton.frame.size.height)
  
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let addBookAlertViewTag = 0
    let addBookTextAlertViewTag = 1
    func addNewBook() {
        var titlePrompt = UIAlertView(title: "Enter Title", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        titlePrompt.alertViewStyle = .PlainTextInput
        titlePrompt.tag = addBookAlertViewTag
        titlePrompt.show()
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let cancelButtonIndex = 0
        let saveButtonIndex = 1
        
        switch (buttonIndex, alertView.tag)
        {
        case (saveButtonIndex, addBookAlertViewTag):
            if let alertTextField = alertView.textFieldAtIndex(0) {
                println("save new item \(alertTextField.text)")
                saveNewBook(alertTextField.text)
            }
            
        default:
            println("Default case, do nothing")
            
        }
    }
    
    
    func saveNewBook(title : String) {
        //create the new book item
        
        //adding the book to undisclose shelf
        //TODO - add to shelf
        var newBookItem = BookItem.createInManagedObjectContext(self.managedObjectContext!, title: title, shelfLocation: "Not in Shelf")
        
        //udpate the array containing the table view row data
        self.fetchBook()
        
        //Animate in the new row
        //Use Swift's find() function to figure out the index of the newBookItem
        //after it's been added and sorted in our bookItem array
        if let newBookIndex = find(bookItems, newBookItem) {
            //create an NSIndexPath from the newBookIndex
            let newBookItemIndexPath = NSIndexPath(forRow: newBookIndex, inSection: 0)
            //Animate the insertion in this row
            bookTableView.insertRowsAtIndexPaths([newBookItemIndexPath], withRowAnimation: .Automatic)
            save()
        }
        
    }

    
    func saveNewBook(title : String, shelfLocation : String) {
        //create the new book item
        
        var newBookItem = BookItem.createInManagedObjectContext(self.managedObjectContext!, title: title, shelfLocation: shelfLocation)
        
        //udpate the array containing the table view row data
        self.fetchBook()
        
        //Animate in the new row
        //Use Swift's find() function to figure out the index of the newBookItem
        //after it's been added and sorted in our bookItem array
        if let newBookIndex = find(bookItems, newBookItem) {
            //create an NSIndexPath from the newBookIndex
            let newBookItemIndexPath = NSIndexPath(forRow: newBookIndex, inSection: 0)
            //Animate the insertion in this row
            bookTableView.insertRowsAtIndexPaths([newBookItemIndexPath], withRowAnimation: .Automatic)
            save()
        }
        
    }

    
    
    
    func presentItemInfo() {
        let fetchRequest = NSFetchRequest(entityName: "BookItem")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [BookItem] {
            
            let alert = UIAlertView()
            alert.title = "Book Title: " + fetchResults[0].title
            alert.message = "Shelf Location: " + fetchResults[0].shelfLocation
            alert.show()
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // How many rows are there in this section?
        // There's only 1 section, and it has a number of rows
        // equal to the number of logItems, so return the count
        return bookItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell") as UITableViewCell
        
        // Get the LogItem for this index
        let bookItem = bookItems[indexPath.row]
        
        // Set the title of the cell to be the title of the logItem
        cell.textLabel?.text = bookItem.title
        return cell
            }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let bookItem = bookItems[indexPath.row]
        let alert = UIAlertView(title: bookItem.title, message: "Shelf # " + bookItem.shelfLocation, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alert.show()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            //find the bookItem object the user is trying to delete
            let bookItemToDelete = bookItems[indexPath.row]
            
            //delete it from the managedObjectContext
            managedObjectContext?.deleteObject(bookItemToDelete)
            
            //Refresh the table view to indicated that it's deleted
            self.fetchBook()
            
            //Tell the table view to animate out that row
            [bookTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)]
            save()
            
        }
    }
    
    
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error)){
            println(error?.localizedDescription)
        }
    }
    
    
    
    
    func fetchBook() {
        let fetchRequest = NSFetchRequest(entityName: "BookItem")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [BookItem] {
            bookItems = fetchResults
        }
    }


}

