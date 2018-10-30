//
//  TaskManagement.swift
//  Due In
//
//  Created by Callum Drain on 23/12/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

public class TaskManagement {
    
    enum taskType {
        case set, due, complete
    }
    
    enum dueDate {
        case past, soon, current
    }
    
    class func getTasks(ids: [String], type: taskType) -> [Task]{
        
        let objectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 
        var typeString : String
        
        switch type {
        case .set:
            typeString = "set"
        case .due:
            typeString = "due"
        case .complete:
            typeString = "complete"
        }
        
        var results = [Task]()
        
        for id in ids {
            
            let url = URL(string:"http://www.duein.net/api/task?id=\(id)")
                
            do {
                
                let taskData = try Data(contentsOf: url!)
                let taskJSON = try JSONSerialization.jsonObject(with: taskData) as! [String : AnyObject]
                    
                let task = Task(context: objectContext)
                    
                task.id = taskJSON["TaskID"] as? String
                task.title = taskJSON["title"] as? String
                task.desc = taskJSON["description"] as? String
                task.set = taskJSON["set"] as? String
                task.due = taskJSON["due"] as? String
                task.owner = taskJSON["owner"] as? String
                task.type = typeString as String?
                
                results.append(task)
                
                /*do {
                    try objectContext.save()
                    print("saved")
                }catch {
                    print("Could not save data \(error.localizedDescription)")
                }
 
                */
                
            } catch {
                    
                print("Error")
    
            }
        }
        
        /*
        
        let predicate = NSPredicate(format: "type == '\(typeString)'")
        let taskRequest:NSFetchRequest<Task> = Task.fetchRequest()
        taskRequest.predicate = predicate
        
        do {
            tasks = try objectContext.fetch(taskRequest)
        }catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
        
        */
 
        results.sort { $0.due! < $1.due! }
        
        return results
        
    }
    
    class func deleteExisting(id : String){
        
        let objectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var tasks = [Task]()
        
        let predicate = NSPredicate(format: "id == %@", id)
        let taskRequest:NSFetchRequest<Task> = Task.fetchRequest()
        taskRequest.predicate = predicate
        
        do {
            tasks = try objectContext.fetch(taskRequest)
        }catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
        
        if !(tasks.count == 0) {
            
            for x in 0...(tasks.count - 1) {
                
                objectContext.delete(tasks[x])
                
            }
            
        }
        
    }
    
    class func storeTask(task: Task){
        
        let objectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let data = Task(context: objectContext)
        
        data.id = task.id
        data.title = task.title
        data.desc = task.desc
        data.set = task.set
        data.due = task.due
        data.owner = task.owner
        data.type = task.type
        
        do {
            try objectContext.save()
        }catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
        if data.type == "due" {
            
            removeNotification(id: data.due!)
            
            if UserDefaults.standard.bool(forKey: "showNotifications") {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: data.due!)!
                
                if !(date < Date()) {
                    
                    scheduleNotification(task: data)
                    print("scheduled")
                    
                }
                
            }
            
        }
        
    }
    
    class func removeNotification(id: String) {
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                if request.identifier == id {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    print("deleted")
                }
            }
        })
        
    }
    
    class func getUserTasks(ids: [String]) -> [Task]{
        
        let objectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var results = [Task]()
        
        for id in ids {
                
            let url = URL(string:"http://www.duein.net/api/task?id=\(id)")
                
            do {
                    
                let taskData = try Data(contentsOf: url!)
                let taskJSON = try JSONSerialization.jsonObject(with: taskData) as! [String : AnyObject]
                    
                let task = Task(context: objectContext)
                    
                task.id = taskJSON["TaskID"] as? String
                task.title = taskJSON["title"] as? String
                task.desc = taskJSON["description"] as? String
                task.set = taskJSON["set"] as? String
                task.due = taskJSON["due"] as? String
                task.owner = taskJSON["owner"] as? String
                
                results.append(task)
                
            }catch{
                    
                print("Error")
                
            }
        }
        
        return results
    }
    
    class func scheduleNotification(task: Task){

        let notification = UNMutableNotificationContent()
        
        notification.title = "A task is now Due In!"
        notification.subtitle = task.title!
        notification.body = task.desc!
        notification.sound = UNNotificationSound.default()
        notification.badge = 1
        
        let date = task.due!
        
        var start = date.index(date.startIndex, offsetBy: 0)
        var end = date.index(date.endIndex, offsetBy: -15)
        var range = start..<end
        
        let year = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 5)
        end = date.index(date.endIndex, offsetBy: -12)
        range = start..<end
        
        let month = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 8)
        end = date.index(date.endIndex, offsetBy: -9)
        range = start..<end
        
        let day = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 11)
        end = date.index(date.endIndex, offsetBy: -6)
        range = start..<end
        
        let hour = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 14)
        end = date.index(date.endIndex, offsetBy: -3)
        range = start..<end
        
        let minute = date.substring(with: range)
        
        var due = DateComponents()
        due.year = Int(year)
        due.month = Int(month)
        due.day = Int(day)
        due.hour = Int(hour)
        due.minute = Int(minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: due, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id!, content: notification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    class func compareTime(time: String) -> dueDate {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: time)!
        
        if !(date < Date()) {
        
            return dueDate.current
        
        }else{
            
            return dueDate.past
            
        }
        
    }
    
    class func addTask(id: String){
        
        let user = UserDefaults.standard.dictionary(forKey: "authUser")
        
        let url = URL(string: "http://www.duein.net/api/add?id=\(id)&username=\(user?["username"] as! String)&verify=\(user?["verify"] as! String)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print(data ?? "Error")
        }
        task.resume()
        
        UserDefaults.standard.set(true, forKey: "taskAdded")
        UserManagement.updateUser(email: user?["email"] as! String)
        
    }
    
    class func completeTask(id: String){
        
        let user = UserDefaults.standard.dictionary(forKey: "authUser")
        
        let url = URL(string: "http://www.duein.net/api/complete?id=\(id)&username=\(user?["username"] as! String)&verify=\(user?["verify"] as! String)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print(data ?? "Error")
        }
        task.resume()
        
        UserDefaults.standard.set(true, forKey: "taskAdded")
        UserManagement.updateUser(email: user?["email"] as! String)
        
    }
    
    class func uncompleteTask(id: String){
        
        let user = UserDefaults.standard.dictionary(forKey: "authUser")
        
        let url = URL(string: "http://www.duein.net/api/uncomplete?id=\(id)&username=\(user?["username"] as! String)&verify=\(user?["verify"] as! String)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print(data ?? "Error")
        }
        task.resume()
        
        UserDefaults.standard.set(true, forKey: "taskAdded")
        UserManagement.updateUser(email: user?["email"] as! String)
        
    }
    
    class func removeTask(id: String){
        
        let user = UserDefaults.standard.dictionary(forKey: "authUser")
        
        let url = URL(string: "http://www.duein.net/api/remove?id=\(id)&username=\(user?["username"] as! String)&verify=\(user?["verify"] as! String)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print(data ?? "Error")
        }
        task.resume()
        
        UserDefaults.standard.set(true, forKey: "taskAdded")
        UserManagement.updateUser(email: user?["email"] as! String)
        
    }
    
    class func deleteTask(id: String){
        
        let user = UserDefaults.standard.dictionary(forKey: "authUser")
        
        let url = URL(string: "http://www.duein.net/api/delete?id=\(id)&username=\(user?["username"] as! String)&verify=\(user?["verify"] as! String)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print(data ?? "Error")
        }
        task.resume()
        
        UserDefaults.standard.set(true, forKey: "taskAdded")
        UserManagement.updateUser(email: user?["email"] as! String)
        
    }
    
}
