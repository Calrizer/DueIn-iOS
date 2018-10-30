//
//  Detail.swift
//  Due In
//
//  Created by Callum Drain on 10/01/2017.
//  Copyright © 2017 Due In. All rights reserved.
//

import UIKit
import CoreData

class Detail: UIViewController {

    @IBOutlet var backButton: UIImageView!
    @IBOutlet var topBar: UIView!
    @IBOutlet var taskView: UIView!
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var taskTitle: UILabel!
    @IBOutlet var taskDescription: UILabel!
    @IBOutlet var taskSet: UILabel!
    @IBOutlet var taskOwner: UIButton!
    @IBOutlet var taskDue: UILabel!
    @IBOutlet var taskQR: UIImageView!
    @IBOutlet var qrOutline: UIView!
    @IBOutlet var qrView: UIView!
    @IBOutlet var taskStatus: UIView!
    @IBOutlet var codeView: UIView!
    
    @IBOutlet var showButton: UIButton!
    @IBOutlet var hideButton: UIButton!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    var taskID : String = ""
    var username : String = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    enum type {
        case due, set, complete, new
    }
    
    var taskType = type.due
    
    let user = UserDefaults.standard.dictionary(forKey: "authUser")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let objectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(goBack))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(goHome))
        logo.isUserInteractionEnabled = true
        logo.addGestureRecognizer(tapGestureRecognizer)
        
        applyPlainShadow(view: topBar)
        applyPlainShadow(view: taskView)
        
        showButton.layer.cornerRadius = 8
        showButton.clipsToBounds = true
        
        hideButton.layer.cornerRadius = 8
        hideButton.clipsToBounds = true
        
        completeButton.layer.cornerRadius = 8
        completeButton.clipsToBounds = true
        
        completeButton.layer.cornerRadius = 8
        completeButton.clipsToBounds = true
        
        deleteButton.layer.cornerRadius = 8
        deleteButton.clipsToBounds = true
        
        qrView.layer.cornerRadius = 4
        qrView.clipsToBounds = true
        
        qrOutline.layer.cornerRadius = 2
        qrOutline.clipsToBounds = true
        
        taskQR.layer.cornerRadius = 2
        taskQR.clipsToBounds = true
        
        var results = [Task]()
        
        let predicate = NSPredicate(format: "id == %@", taskID)
        
        let taskRequest:NSFetchRequest<Task> = Task.fetchRequest()
        taskRequest.predicate = predicate
        
        do {
            results = try objectContext.fetch(taskRequest)
        }catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
        
        print(results.count)
        
        taskTitle.text = results[0].title
        taskDescription.text = results[0].desc
        taskSet.text = "Task Set: \(Tools.convertDate(date: results[0].set!))"
        taskDue.text = "Due In: \(Tools.convertDate(date: results[0].due!))"
        taskOwner.setTitle("Created By: @\(results[0].owner!)", for: .normal)
        
        if TaskManagement.compareTime(time: results[0].due!) == TaskManagement.dueDate.current {
            taskStatus.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        }
        
        taskQR.image = generateQRCode(from: "http://www.duein.net/task/\(taskID)/")
        
        username = results[0].owner!
        
        var newTask = true
        
        var list = user?["due"] as! String
        var tasks = list.characters.split{$0 == "."}.map(String.init)
        if tasks.contains(taskID){
            completeButton.setTitle("Complete Task", for: .normal)
            completeButton.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
            deleteButton.setTitle("Remove Task", for: .normal)
            newTask = false
            taskType = type.due
        }
        
        list = user?["set"] as! String
        tasks = list.characters.split{$0 == "."}.map(String.init)
        if tasks.contains(taskID){
            completeButton.setTitle("Edit Task", for: .normal)
            completeButton.backgroundColor = UIColor(red:0.98, green:0.12, blue:0.25, alpha:1.0)
            deleteButton.setTitle("Delete Task", for: .normal)
            newTask = false
            taskType = type.set
        }
        
        list = user?["complete"] as! String
        tasks = list.characters.split{$0 == "."}.map(String.init)
        if tasks.contains(taskID){
            completeButton.setTitle("Uncomplete Task", for: .normal)
            completeButton.backgroundColor = UIColor(red:0.98, green:0.12, blue:0.25, alpha:1.0)
            deleteButton.setTitle("Remove Task", for: .normal)
            newTask = false
            taskType = type.complete
        }
        
        if newTask {
            completeButton.isHidden = true
            deleteButton.setTitle("Add Task", for: .normal)
            deleteButton.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
            newTask = false
            taskType = type.new
        }
        
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func goBack() {
        
        navigationController!.popViewController(animated: true)
        
    }
    
    func goHome(){
        
        navigationController!.popToRootViewController(animated: true)
        
    }
    
    @IBAction func selectPrimary(_ sender: Any) {
        
        switch taskType {
        case .due:
            TaskManagement.completeTask(id: taskID)
            goBack()
        case .set:
            print("Nae Working")
        case .complete:
            TaskManagement.uncompleteTask(id: taskID)
            goBack()
        case.new:
            TaskManagement.addTask(id: taskID)
            goHome()
        }
        
    }
    
    @IBAction func selectSecondary(_ sender: Any) {
        
        switch taskType {
        case .due:
            TaskManagement.removeTask(id: taskID)
            goBack()
        case .set:
            TaskManagement.deleteTask(id: taskID)
            goBack()
        case .complete:
            TaskManagement.removeTask(id: taskID)
            goBack()
        case.new:
            TaskManagement.addTask(id: taskID)
            goHome()
        }
        
    }
    
    @IBAction func showCode(_ sender: Any) {
        
        self.view.insertSubview(self.codeView, at: 6)
        codeView.alpha = 0
        codeView.frame.size.width = self.view.bounds.width
        codeView.frame.size.height = self.view.bounds.height
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.codeView.alpha = 1})
        
    }
    
    @IBAction func hideCode(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.codeView.alpha = 0
        }, completion: {_ in
            self.codeView.removeFromSuperview()
        })

        
    }
    
    
    @IBAction func showUser(_ sender: Any) {
        performSegue(withIdentifier: "showUser", sender: username)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showUser" {
            
            if let destination = segue.destination as? UserVC {
                
                destination.user = UserManagement.getUserInfo(username: sender as! String) 
                
            }
        }
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
}
