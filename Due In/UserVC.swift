//
//  UserVC.swift
//  Due In
//
//  Created by Callum Drain on 11/01/2017.
//  Copyright © 2017 Due In. All rights reserved.
//

import UIKit
import CoreData

class UserVC: UIViewController {

    @IBOutlet var userImg: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var tasksLbl: UILabel!
    @IBOutlet var profileView: UIView!
    @IBOutlet var topBar: UIView!
    @IBOutlet var backButton: UIImageView!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var mainScroll: UIScrollView!
    
    var user = Dictionary<String, Any>()
    var taskList : [String] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(goBack))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(goHome))
        logo.isUserInteractionEnabled = true
        logo.addGestureRecognizer(tapGestureRecognizer)
        
        applyPlainShadow(view: topBar)
        applyPlainShadow(view: profileView)
        
        usernameLbl.text = "@\((user["username"] as! String))"
        nameLbl.text = (user["name"] as! String)
        
        let set = user["set"] as! String
        
        let tasks = set.characters.split{$0 == "."}.map(String.init)
        
        countLbl.text = String(tasks.count)
        
        var current = 12
        
        mainScroll.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat((168 * tasks.count)))
        
        for task in TaskManagement.getUserTasks(ids: tasks){
            
            if let taskView = Bundle.main.loadNibNamed("Task", owner: self, options: nil)?.first as? TaskConf {
                
                taskView.tag = taskList.count
                
                taskList.append(task.id!)
                
                taskView.taskTitle.text = task.title
                taskView.taskDescription.text = task.desc
                
                taskView.taskDue.text = "Due In: \(Tools.convertDate(date: task.due!))"
                
                if TaskManagement.compareTime(time: task.due!) == TaskManagement.dueDate.current {
                    
                    taskView.taskStatus.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
                    
                }
                
                taskView.frame.size.width = self.view.bounds.width - 24
                taskView.frame.origin.y = CGFloat(current)
                taskView.frame.origin.x = 12
                
                let showDetail = UITapGestureRecognizer(target: self, action: #selector(openDetail))
                 
                taskView.isUserInteractionEnabled = true
                taskView.addGestureRecognizer(showDetail)
                
                applyPlainShadow(view: taskView)
                
                mainScroll.addSubview(taskView)
                
                current = current + 168
                
            }
            
        }

        
        let pictureURL = URL(string: "http://images.duein.net/profiles/Calrizer.jpg")!
        let session = URLSession(configuration: .default)

        let downloadPicTask = session.dataTask(with: pictureURL) { (data, response, error) in
        
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    if let imageData = data {
                        print(res)
                        let image = UIImage(data: imageData)
                        self.userImg.image = image
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason.")
                }
            }
        }
        
        downloadPicTask.resume()
        
        userImg.layer.cornerRadius = self.userImg.frame.size.width / 2
        userImg.clipsToBounds = true
        userImg.layer.borderWidth = 2
        userImg.layer.borderColor = UIColor(red:0.98, green:0.12, blue:0.25, alpha:1.0).cgColor
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        
        navigationController!.popViewController(animated: true)
        
    }
    
    func goHome() {
        
        navigationController!.popToRootViewController(animated: true)
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
    func openDetail(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "showDetail", sender: taskList[sender.view!.tag])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            if let destination = segue.destination as? Detail {
                
                destination.taskID = sender as! String
                
            }
            
        }
        
    }

}
