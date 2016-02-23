//
//  TodoViewController.swift
//  KKTouchID
//
//  Created by Kadasiddha on 19/02/16.
//  Copyright © 2016 Kadasiddha. All rights reserved.
//

import Foundation
import UIKit


protocol TodoViewControllerDelegate{
    func noteWasSaved()
}


class TodoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtNoteTitle: UITextField!
    
    @IBOutlet weak var tvNoteBody: UITextView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var delegate : TodoViewControllerDelegate?
    
    var indexOfEditedNote : Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Make this class the delegate of the textfield.
        txtNoteTitle.delegate = self
        
        // Make the textfield the first responder.
        self.txtNoteTitle.becomeFirstResponder()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if (indexOfEditedNote != nil) {
            editNote()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: Method implementation
    
    func editNote() {
        // Load all notes.
        let notesArray: NSArray = NSArray(contentsOfFile: appDelegate.KKgetPathOfDataFile())!
        
        // Get the dictionary at the specified index.
        let noteDict : Dictionary = notesArray.objectAtIndex(indexOfEditedNote) as! Dictionary<String, String>
        
        // Set the textfield text.
        txtNoteTitle.text = noteDict["title"]
        
        // Set the textview text.
        tvNoteBody.text = noteDict["body"]
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func saveNote(sender: AnyObject) {
        if self.txtNoteTitle.text!.isEmpty {
            print("No title for the note was typed.")
            return
        }
        
        // Create a dictionary with the note data.
        let noteDict = ["title": self.txtNoteTitle.text, "body": self.tvNoteBody.text]
        
        // Declare a NSMutableArray object.
        var dataArray: NSMutableArray
        
        // If the notes data file exists then load its contents and add the new note data too, otherwise
        // just initialize the dataArray array and add the new note data.
        if appDelegate.KKcheckIfDataFileExists() {
            // Load any existing notes.
            dataArray = NSMutableArray(contentsOfFile: appDelegate.KKgetPathOfDataFile())!
            
            // Check if is editing aedit note or not.
            if indexOfEditedNote == nil {
                // Add the dictionary to the array.
                dataArray.addObject(noteDict)
            }
            else{
                // Replace the existing dictionary to the array.
                dataArray.replaceObjectAtIndex(indexOfEditedNote, withObject: noteDict)
            }
        }
        else{
            // Create a new mutable array and add the noteDict object to it.
            dataArray = NSMutableArray(object: noteDict)
        }
        
        // Save the array contents to file.
        dataArray.writeToFile(appDelegate.KKgetPathOfDataFile(), atomically: true)
        
        // Notify the delegate class that the note has been saved.
        delegate?.noteWasSaved()
        
        // Pop the view controller
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    // MARK: UITextFieldDelegate method implementation
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Resign the textfield from first responder.
        textField.resignFirstResponder()
        
        // Make the textview the first responder.
        tvNoteBody.becomeFirstResponder()
        
        return true
    }
}
