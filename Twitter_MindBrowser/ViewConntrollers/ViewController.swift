//
//  ViewController.swift
//  Twitter_MindBrowser
//
//  Created by Rushikesh on 11/07/21.
//

import UIKit
import TwitterKit

class ViewController: BaseViewController {
    
    var profileDataStorage = ProfileData()
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customiseLoginButton(button: loginButtonOutlet)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func twiterLoginButtonClicked(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            
            if (session != nil) {
                
                print(session?.authToken  ?? "")
                print(session?.authTokenSecret  ?? "")
                self.profileDataStorage.name = session?.userName ?? ""
                self.profileDataStorage.userId = session?.userID  ?? ""
                
                self.profileDataStorage.authToken = session?.authToken ?? ""
                self.profileDataStorage.authTokenSecreat = session?.authTokenSecret  ?? ""
                
                let twitterClient = TWTRAPIClient(userID: session?.userID)
                twitterClient.loadUser(withID: session?.userID ?? "") { (user, error) in
                    self.profileDataStorage.profilePictureUrlInString = user?.profileImageLargeURL ?? ""
                    self.navigateToProfileScreen()
                }
                
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        }
       
    }
    
    func navigateToProfileScreen() {
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.profileDataStorage = self.profileDataStorage
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
}

