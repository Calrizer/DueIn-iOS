//
//  UserManagement.swift
//  Due In
//
//  Created by Callum Drain on 23/12/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

import Foundation

public class UserManagement {
    
    class func getUser(email:String, password:String) -> Dictionary<String, Any>{
        
        let url = URL(string:"http://www.duein.net/api/user?email=\(email)&password=\(password)")
        
        do {
            
            let userData = try Data(contentsOf: url!)
            let userJSON = try JSONSerialization.jsonObject(with: userData) as! [String : AnyObject]
            
            var user = Dictionary<String, Any>()
            
            user["username"] = userJSON["username"] as! String
            user["name"] = userJSON["name"] as! String
            user["email"] = userJSON["email"] as! String
            user["set"] = userJSON["set"] as! String
            user["due"] = userJSON["due"] as! String
            user["complete"] = userJSON["complete"] as! String
            user["online"] = userJSON["online"] as! String
            user["country"] = userJSON["country"] as! String
            user["created"] = userJSON["created_at"] as! String
            user["updated"] = userJSON["updated_at"] as! String
            user["verify"] = userJSON["verify"] as! String
            user["confirmed"] = userJSON["confirmed"] as! String
            
            return user
            
        }
        catch {
            print("Error")
            
        }
        
        var user = Dictionary<String, Any>()
        
        user["username"] = ""
        user["name"] = ""
        user["email"] = ""
        user["set"] = ""
        user["due"] = ""
        user["online"] = ""
        user["country"] = ""
        user["created"] = ""
        user["updated"] = ""
        user["verify"] = ""
        user["confirmed"] = ""
        
        return user
    }
    
    class func getUserInfo(username: String) -> Dictionary<String, Any>{
        
        let url = URL(string:"http://www.duein.net/api/userinfo?username=\(username)")
        
        do {
            
            let userData = try Data(contentsOf: url!)
            let userJSON = try JSONSerialization.jsonObject(with: userData) as! [String : AnyObject]
            
            var user = Dictionary<String, Any>()
            
            user["username"] = userJSON["username"] as! String
            user["name"] = userJSON["name"] as! String
            user["set"] = userJSON["set"] as! String
            
            return user
            
        }
        catch {
            
            print("Error")
            
        }
        
        var user = Dictionary<String, Any>()
        
        user["username"] = ""
        user["name"] = ""
        user["set"] = ""
        
        return user
        
    }
    
    class func updateUser(email : String) {
        
        let authUser = getUser(email: email, password: UserDefaults.standard.string(forKey: "userPassword")!)
        UserDefaults.standard.set(authUser, forKey: "authUser")
        
    }
    
    class func logoutUser(){
        
        let user = UserDefaults.standard.dictionary(forKey: "authUser")
        
        var list = user?["due"] as! String
        
        var tasks = list.characters.split{$0 == "."}.map(String.init)
        
        for task in tasks {
            
            TaskManagement.deleteExisting(id: task)
            TaskManagement.removeNotification(id: task)
        }
        
        list = user?["set"] as! String
        
        tasks = list.characters.split{$0 == "."}.map(String.init)
        
        for task in tasks {
            
            TaskManagement.deleteExisting(id: task)
            TaskManagement.removeNotification(id: task)
        }
        
        list = user?["complete"] as! String
        
        tasks = list.characters.split{$0 == "."}.map(String.init)
        
        for task in tasks {
            
            TaskManagement.deleteExisting(id: task)
            TaskManagement.removeNotification(id: task)
            
        }
        
        UserDefaults.standard.set(true, forKey: "showNotifications")
        UserDefaults.standard.removeObject(forKey: "authUser")
        
    }
    
}
