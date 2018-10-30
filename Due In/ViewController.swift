//
//  ViewController.swift
//  Due In
//
//  Created by Callum Drain on 28/09/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet var topView: UIView!
    @IBOutlet var addView: UIView!
    @IBOutlet var menuView: UIView!
    @IBOutlet var settingsView: UIView!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var switchNotification: UISwitch!
    @IBOutlet var btnSettings: UIButton!
    @IBOutlet var menuButton: UIImageView!
    @IBOutlet var dueButton: UIButton!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var setButton: UIButton!
    @IBOutlet var listType: UILabel!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var imgCamera: UIImageView!
    @IBOutlet var imgTick: UIImageView!
    @IBOutlet var setView: UIView!
    @IBOutlet var mainScroll: UIScrollView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var activityView: UIView!
    
    private let refreshControl = UIRefreshControl()
    
    var managedObjectContext:NSManagedObjectContext!
    
    var startup : Bool = true
    
    var current = 20 as Int
    
    var taskList : [String] = []
    
    var taskType : TaskManagement.taskType = .due
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.insertSubview(self.activityView, at: 1)
        activityView.frame.size.width = self.view.frame.width
        activityView.frame.size.height = self.view.frame.height
        activityView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 1
        }
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
        UserDefaults.standard.set(true, forKey: "showNotifications")
        })
        
        if UserDefaults.standard.bool(forKey: "showNotifications"){
            switchNotification.isOn = true
        }else{
            switchNotification.isOn = false
        }
        
        let user = UserDefaults.standard.dictionary(forKey: "authUser")
        
        lblUsername.text = "@\((user?["username"] as! String))"
        lblName.text = (user?["name"] as! String)
        
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
                        self.imgUser.image = image
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason.")
                }
            }
        }
        
        downloadPicTask.resume()
        
        imgUser.layer.cornerRadius = self.imgUser.frame.size.width / 2
        imgUser.clipsToBounds = true
        imgUser.layer.borderWidth = 2
        imgUser.layer.borderColor = UIColor(red:0.98, green:0.12, blue:0.25, alpha:1.0).cgColor
        
        cameraView.layer.cornerRadius = self.cameraView.frame.size.width / 2
        cameraView.clipsToBounds = true
        
        setView.layer.cornerRadius = self.setView.frame.size.width / 2
        setView.clipsToBounds = true
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(openScanner))
        imgCamera.isUserInteractionEnabled = true
        imgCamera.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(openDetail))
        imgTick.isUserInteractionEnabled = true
        imgTick.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(showMenu))
        menuButton.isUserInteractionEnabled = true
        menuButton.addGestureRecognizer(tapGestureRecognizer)
        
        applyPlainShadow(view: topView)
        
        logoutButton.layer.cornerRadius = 8
        logoutButton.clipsToBounds = true
        
        self.view.insertSubview(self.settingsView, at: 1)
        settingsView.center.y = -settingsView.frame.height
        
        self.view.insertSubview(self.addView, at: 1)
        addView.center.y = -addView.frame.height
        
        self.view.insertSubview(self.menuView, at: 1)
        menuView.center.y = self.view.frame.height + menuView.frame.height
        menuView.frame.size.width = self.view.frame.width
        
        menuButton.transform = menuButton.transform.rotated(by: CGFloat(M_PI))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (startup == true) || (UserDefaults.standard.bool(forKey: "taskAdded") == true){
            
            UIView.animate(withDuration: 0.3) {
                self.activityView.alpha = 1
            }
        
            startup = false
            UserDefaults.standard.set(false, forKey: "taskAdded")
            clearView()
            
            loadTasks(type: taskType)
            
            refreshControl.tintColor = UIColor.white
            refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
            mainScroll.refreshControl = refreshControl
            
        }
        
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 0
        }
        
    }
    
    func refresh(sender:AnyObject) {
        
        
        
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearView() {
        
        current = 0
        mainScroll.contentSize = CGSize(width: self.view.bounds.width, height: 0)
        
        let subViews = self.mainScroll.subviews
        for subview in subViews {
            subview.removeFromSuperview()
        }
        
    }
    
    func loadTasks(type : TaskManagement.taskType){
        
        if Tools.isInternetAvailable() {
            
            var user = UserDefaults.standard.dictionary(forKey: "authUser")
            
            UserManagement.updateUser(email: user?["email"] as! String)
            
            user = UserDefaults.standard.dictionary(forKey: "authUser")
            
            var list = user?["due"] as! String
            
            switch type {
            case .due:
                list = user?["due"] as! String
            case .set:
                list = user?["set"] as! String
            case .complete:
                list = user?["complete"] as! String
            }
            
            let tasks = list.characters.split{$0 == "."}.map(String.init)
            
            let storedTasks = TaskManagement.getTasks(ids: tasks, type: type)
            
            mainScroll.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat((168 * storedTasks.count)))
            
            getTasks(tasks: storedTasks)
            
            for task in storedTasks {
                
                TaskManagement.deleteExisting(id: task.id!)
                TaskManagement.storeTask(task: task)
            }
            
        }else{
            
            var tasks = [Task]()
            
            var typeString = "due"
            
            switch type {
            case .due:
                typeString = "due"
            case .set:
                typeString = "set"
            case .complete:
                typeString = "complete"
            }
            
            let predicate = NSPredicate(format: "type == '\(typeString)'")
            let taskRequest:NSFetchRequest<Task> = Task.fetchRequest()
            taskRequest.predicate = predicate
            
            do {
                tasks = try managedObjectContext.fetch(taskRequest)
            }catch {
                print("Could not load data from database \(error.localizedDescription)")
            }
            
            mainScroll.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat((168 * tasks.count)))
            
            getTasks(tasks: tasks)
            
        }
        
    }
    
    func getTasks(tasks: [Task]) {
        
        var expired = [Task]()
        var hasExpired : Bool = false
        
        for task in tasks {
            
            if TaskManagement.compareTime(time: task.due!) == TaskManagement.dueDate.current {
            
                if let taskView = Bundle.main.loadNibNamed("Task", owner: self, options: nil)?.first as? TaskConf {
                
                    taskView.tag = taskList.count
                
                    taskList.append(task.id!)
                
                    taskView.taskTitle.text = task.title
                    taskView.taskDescription.text = task.desc
                
                    taskView.taskDue.text = "Due In: \(Tools.convertDate(date: task.due!))"
                    
                    taskView.taskStatus.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
                
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
                
            }else{
                
                hasExpired = true
                expired.append(task)
                
            }
            
        }
        
        if hasExpired {
        
            let lbl = UILabel()
            lbl.text = "Tasks Expired"
            lbl.font = UIFont(name: "Montserrat", size: 18)
            lbl.textColor = UIColor.white
            lbl.frame.origin.y = CGFloat(current)
            lbl.frame.origin.x = 12
            lbl.frame.size.width = self.view.bounds.width
            lbl.frame.size.height = 22
        
            mainScroll.addSubview(lbl)
            
            expired.sort { $0.due! > $1.due! }
        
            current = current + 40
        
            for task in expired {
            
                if let taskView = Bundle.main.loadNibNamed("Task", owner: self, options: nil)?.first as? TaskConf {
                
                    taskView.tag = taskList.count
                
                    taskList.append(task.id!)
                
                    taskView.taskTitle.text = task.title
                    taskView.taskDescription.text = task.desc
                
                    taskView.taskDue.text = "Due In: \(Tools.convertDate(date: task.due!))"
                
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
            
            mainScroll.contentSize = CGSize(width: self.view.bounds.width, height: mainScroll.contentSize.height + 40)
            
        }
        
    }
    
    func showMenu() {
        
        UIView.animate(withDuration: 0.2) {
            self.menuButton.transform = self.menuButton.transform.rotated(by: CGFloat(M_PI))
        }
        
        if menuButton.tag == 0 {
            
            menuButton.tag = 1
            
            listType.text = "Select Task List"
            
            UIView.animate(withDuration: 0.3) {
                self.menuView.center.y = self.view.frame.height - 110
            }
            
        }else{
            
            hideMenu()
            
        }
        
    }
    
    func hideMenu() {
        
        menuButton.tag = 0
        
        switch taskType {
        case .due:
            listType.text = "Tasks Due In"
        case .set:
            listType.text = "Tasks Set"
        case .complete:
            listType.text = "Tasks Completed"
        }
        
        UIView.animate(withDuration: 0.3) {
            self.menuView.center.y = self.view.frame.height + self.menuView.frame.height
        }
        
    }
    
    @IBAction func addTask(_ sender: AnyObject) {
        
        if addButton.tag == 0{
            
            addButton.tag = 1
            
            addView.frame.size.width = self.view.frame.width
            applyPlainShadow(view: addView)
            
            UIView.animate(withDuration: 0.3) {
                self.addView.center.y = 124
            }
            
        }else{
            
            addButton.tag = 0
            
            UIView.animate(withDuration: 0.3){
                self.addView.center.y = -self.addView.frame.height
            }
            
        }
        
    }
    
    @IBAction func showSettings(_ sender: Any) {
        
        if btnSettings.tag == 0{
            
            btnSettings.tag = 1
            
            settingsView.frame.size.width = self.view.frame.width
            applyPlainShadow(view: settingsView)
            
            UIView.animate(withDuration: 0.3) {
                self.settingsView.center.y = 182
            }
            
        }else{
            
            btnSettings.tag = 0
            
            UIView.animate(withDuration: 0.3){
                self.settingsView.center.y = -self.settingsView.frame.height
            }
            
        }
        
    }
    
    @IBAction func toggleNotifications(_ sender: Any) {
        
        if switchNotification.isOn == true {
            
            UserDefaults.standard.set(true, forKey: "showNotifications")
            clearView()
            loadTasks(type: .due)
            
        }else{
            
            UserDefaults.standard.set(false, forKey: "showNotifications")
            clearView()
            loadTasks(type: .due)
            
        }
        
    }
    
    @IBAction func logout(_ sender: Any) {
    
        UserManagement.logoutUser()
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"Auth")
        self.present(viewController, animated: true, completion: nil)
    
    }
    
    
    @IBAction func showDue(_ sender: Any) {
     
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 1
        }
        hideMenu()
        taskType = .due
        clearView()
        loadTasks(type: taskType)
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        mainScroll.refreshControl = refreshControl
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 0
        }
    }
    
    @IBAction func showComplete(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 1
        }
        hideMenu()
        taskType = .complete
        clearView()
        loadTasks(type: taskType)
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        mainScroll.refreshControl = refreshControl
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 0
        }
    }
    
    @IBAction func showSet(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 1
        }
        hideMenu()
        taskType = .set
        clearView()
        loadTasks(type: taskType)
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        mainScroll.refreshControl = refreshControl
        UIView.animate(withDuration: 0.3) {
            self.activityView.alpha = 0
        }
        
    }
    
    func openScanner() {
    
        UIView.animate(withDuration: 0.3){
            self.addView.center.y = -self.addView.frame.height
        }
        addButton.tag = 0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"Scan")
        self.present(viewController, animated: true)
    }
    
    func openDetail(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "detail", sender: taskList[sender.view!.tag])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detail" {
            
            if let destination = segue.destination as? Detail {
                
                destination.taskID = sender as! String
                
            }
            
        }
        
    }
    
}

