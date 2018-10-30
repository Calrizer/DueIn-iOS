//
//  Onboarding.swift
//  Due In
//
//  Created by Callum Drain on 22/11/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

/*import UIKit
import PaperOnboarding

class Onboarding: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    @IBOutlet var onboardingView: OnboardingView!
    @IBOutlet var onboardingButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingButton.setTitle("Allow camera access.", for: UIControlState.normal)
        onboardingView.dataSource = self
        onboardingView.delegate = self
    }
    
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        
        let bgColour = UIColor(red: 249/255, green: 31/255, blue: 65/255, alpha: 1)
        
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        
        return [("photo-camera", "Enable access to camera.", "Enable access to your device's camera to scan tasks.", "", bgColour, UIColor.white, UIColor.white, titleFont, descriptionFont),("notification", "Allow notifications.", "Allow notifications to get keep up to date and get reminders for your tasks.", "", bgColour, UIColor.white, UIColor.white, titleFont, descriptionFont),("round-done-button", "All done!", "You're now set up and ready to go!", "", bgColour, UIColor.white, UIColor.white, titleFont, descriptionFont)][index]
    
    }
    
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        
    }
    

    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 0 {
            onboardingButton.setTitle("Allow camera access.", for: UIControlState.normal)
        }else if index == 1 {
            onboardingButton.setTitle("Allow notifications.", for: UIControlState.normal)
        }else if index == 2 {
            onboardingButton.setTitle("Get started.", for: UIControlState.normal)
        }
    }
    
    @IBAction func onboardingButtonPress(_ sender: Any) {
        
        if onboardingButton.currentTitle == "Get started."{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"Main")
            self.present(viewController, animated: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
 */
