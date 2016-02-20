//
//  ViewController.swift
//  KKTouchID
//
//  Created by Kadasiddha on 19/02/16.
//  Copyright © 2016 Kadasiddha. All rights reserved.
//


import UIKit
import LocalAuthentication


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TodoViewControllerDelegate {
    
    @IBOutlet weak var tblNotes: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var dataArray: NSMutableArray!
    
    var noteIndexToEdit: Int!
    
    @IBOutlet weak var touchIDButton: UIBarButtonItem!
    
    @IBOutlet weak var addbutton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblNotes.delegate = self
        tblNotes.dataSource = self
        addbutton.enabled = true
        authenticateUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "gotoTodoViewController"{
            let KKTodoViewController : TodoViewController = segue.destinationViewController as! TodoViewController
            
            KKTodoViewController.delegate = self
            
            if (noteIndexToEdit != nil) {
                KKTodoViewController.indexOfEditedNote = noteIndexToEdit
                
                noteIndexToEdit = nil
            }
        }
    }
    
    
    // MARK: Method implementation
    
    func authenticateUser() {
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        var authError: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to access your notes."
        
        // Check if the device can evaluate the policy.
        do {
            try context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError)
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    // If authentication was successful then load the data.
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.touchIDButton.enabled = false
                        self.addbutton.enabled = true
                        self.loadData()
                    })
                }
                else{
                    
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    print(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by the system")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                        
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by the user")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ ()  -> Void in
                            self.showPasswordAlert()
                        })
                        
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                        
                        
                    default:
                        print("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    }
                }
                
            })]
        } catch let error1 as NSError {
            error = error1
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set")
                
            default:
                // The LAError.TouchIDNotAvailable case.
                print("TouchID not available")
            }
            
            // Optionally the error description can be displayed on the console.
            print(error?.localizedDescription)
            
            // Show the custom alert view to allow users to enter the password.
            showPasswordAlert()
        }
    }
    
    
    func showPasswordAlert() {
        
        
        let alertController = UIAlertController(title: "Touch ID", message: "Please type your password", preferredStyle: .Alert)
        
        // Initialize Actions
        let Submit = UIAlertAction(title: "Submit", style: .Default) { (action) -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
            
                if firstTextField.text == "123456"
                {
                self.loadData()
                self.touchIDButton.enabled = false
                self.addbutton.enabled = true
                }
                else
                {
                    self.touchIDButton.enabled = true
                    self.showPasswordAlert()
                }
            
            
            
        }
        
        let Cancel = UIAlertAction(title: "Cancel", style: .Default) { (action) -> Void in
            self.addbutton.enabled = false

        }
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "PASSWORD"
        }
        // Add Actions
        alertController.addAction(Submit)
        alertController.addAction(Cancel)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
//        let passwordAlert : UIAlertView = UIAlertView(title: "TouchIDDemo", message: "Please type your password", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Okay")
//        passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
//        passwordAlert.show()
    }
    
    
    func loadData(){
        if appDelegate.KKcheckIfDataFileExists() {
            self.dataArray = NSMutableArray(contentsOfFile: appDelegate.KKgetPathOfDataFile())
            self.tblNotes.reloadData()
        }
        else{
            print("File does not exist")
        }
    }
    
    
    
    // MARK: TableView method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = dataArray {
            return array.count
        }
        else{
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell")! as UITableViewCell
        
        let currentNote = self.dataArray.objectAtIndex(indexPath.row) as! Dictionary<String, String>
        cell.textLabel!.text = currentNote["title"]
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    @IBAction func ActionTouchID(sender: AnyObject) {
        authenticateUser()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        noteIndexToEdit = indexPath.row
        
        performSegueWithIdentifier("gotoTodoViewController", sender: self)
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            // Delete the respective object from the dataArray array.
            dataArray.removeObjectAtIndex(indexPath.row)
            
            // Save the array to disk.
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            dataArray.writeToFile(appDelegate.KKgetPathOfDataFile(), atomically: true)
            
            // Reload the tableview.
            tblNotes.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    
    
    // MARK: EditNoteViewControllerDelegate method implementation
    
    func noteWasSaved() {
        // Load the data and reload the table view.
        loadData()
    }
}

