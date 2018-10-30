//
//  AddVC.swift
//  Due In
//
//  Created by Callum Drain on 16/12/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

import UIKit
import AudioToolbox

class AddVC: UIViewController {

    struct Task {
        var id : String
        var title : String
        var description : String
        var set : String
        var due : String
        var owner : String
    }
    
    var taskID : String = ""
    
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    
    @IBOutlet var taskView: UIView!
    @IBOutlet var taskTitle: UILabel!
    @IBOutlet var taskDescription: UILabel!
    @IBOutlet var taskDue: UILabel!
    @IBOutlet var taskSet: UILabel!
    @IBOutlet var taskCreated: UILabel!
    @IBOutlet var taskStatus: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        let task = getTask(id: taskID)
        
        taskTitle.text = task.title
        taskDescription.text = task.description
        taskDue.text = "Due In: \(Tools.convertDate(date: task.due))"
        taskSet.text = "Task Set: \(Tools.convertDate(date: task.set))"
        taskCreated.text = "Created By: @\(task.owner)"
        if TaskManagement.compareTime(time: task.due) == TaskManagement.dueDate.current {
            
            taskStatus.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
            
        }
        
        addBtn.layer.cornerRadius = 8
        addBtn.clipsToBounds = true
        
        cancelBtn.layer.cornerRadius = 8
        cancelBtn.clipsToBounds = true
        
        applyPlainShadow(view: taskView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTask(id:String) -> Task{
        
        let url = URL(string:"http://www.duein.net/api/task?id=\(id)")
        
        do {
            
            let taskData = try Data(contentsOf: url!)
            let taskJSON = try JSONSerialization.jsonObject(with: taskData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
            
            let task = Task(id: taskJSON["TaskID"] as! String, title: taskJSON["title"] as! String, description: taskJSON["description"] as! String, set: taskJSON["set"] as! String, due: taskJSON["due"] as! String, owner: taskJSON["owner"] as! String)
            
            return task
            
        }
        catch {
            print("Error")
        }
        
        let task = Task(id: "", title: "", description: "", set: "", due: "", owner: "")
        return task
        
    }
    
    
    @IBAction func addTask(_ sender: Any) {
        
        TaskManagement.addTask(id: taskID)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"Scan")
        viewController.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelAdd(_ sender: Any) {
    
        self.dismiss(animated: true, completion: nil)
    
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
}
