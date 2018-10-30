//
//  Auth.swift
//  Due In
//
//  Created by Callum Drain on 16/10/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

import UIKit

class Auth: UIViewController {

    struct User {
        var username : String
        var name : String
        var email : String
        var set : String
        var due : String
        var online : Bool
        var country : String
        var created : String
        var updated : String
        var verify : String
        var confirmed : Bool
    }
    
    @IBOutlet var logo: UIImageView!
    @IBOutlet var card: UIView!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        card.layer.cornerRadius = 6
        card.clipsToBounds = true
        btnLogin.layer.cornerRadius = 4
        btnLogin.clipsToBounds = true
        btnSignUp.layer.cornerRadius = 4
        btnSignUp.clipsToBounds = true
        
        applyPlainShadow(view: card)
        
        self.view.bringSubview(toFront: logo)
        self.view.bringSubview(toFront: card)
        
        spinner.isHidden = true
        lblStatus.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 15)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 5
    }
    
    @IBAction func tapSignin(_ sender: Any) {
    
        spinner.isHidden = false
        spinner.startAnimating()
        
        let user = getUser(email: txtEmail.text!, password: txtPassword.text!)
        
        spinner.stopAnimating()
        spinner.isHidden = true
        
        if user["email"] as! String == "" {
            
            lblStatus.isHidden = false
            lblStatus.text = "Incorrect Login"
            
        }else{
            
            UserDefaults.standard.set(user, forKey: "authUser")
            UserDefaults.standard.set(txtPassword.text, forKey: "userPassword")
            presentMain(animation: true)
            
        }
    
    }
    
    func getUser(email:String, password:String) -> Dictionary<String, Any>{
        
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
    
    func presentMain(animation: Bool){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"MainNav")
        if animation == true {
            self.present(viewController, animated: true)
        }else{
            self.dismiss(animated: false, completion: nil)
            self.present(viewController, animated: false)
        }
        
        
    }
    
}
