//
//  ProfileViewController.swift
//  Twitter_MindBrowser
//
//  Created by Rushikesh on 11/07/21.
//

import UIKit
import TwitterKit


class ProfileViewController: BaseViewController {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailIdLabel: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followerBtnOutlet: UIButton!
    @IBOutlet weak var followingBtnOutlet: UIButton!
    
    var profileDataStorage = ProfileData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getEmailIdOfProfile()
        settingProfileDataToUI()
        //getAccessToken()
        self.getStatusesUserTimeline(accessToken: profileDataStorage.authToken)
        getfollowing()
    }
    
    
    
    func settingProfileDataToUI() {
        nameLabel.text = profileDataStorage.name
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        emailIdLabel.adjustsFontSizeToFitWidth = true
        emailIdLabel.minimumScaleFactor = 0.2
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.width/2
        customiseLoginButton(button: followerBtnOutlet)
        customiseLoginButton(button: followingBtnOutlet)
        profileImageView.imageFromURL(urlString: profileDataStorage.profilePictureUrlInString)
        
    }
    
    func getEmailIdOfProfile() {
        //Get user email id
        let client = TWTRAPIClient.withCurrentUser()
        client.requestEmail { email, error in
            if (email != nil) {
                self.profileDataStorage.emailId = email ?? ""
                self.emailIdLabel.text = self.profileDataStorage.emailId
            } else {
                print("error--: \(String(describing: error?.localizedDescription))");
            }
        }
    }
    
    
    
    func getfollowing() {

        var request = URLRequest(url: URL(string: "https://api.twitter.com/1.1/followers/list.json")!)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "cursor": -1,
            "screen_name": "twitterdev",
            "skip_status": true,
            "include_user_entities": false,
            "user_id": profileDataStorage.userId
        ]
        var authString = "OAuth oauth_consumer_key=\(Services.consumerAppKey),oauth_token=\(profileDataStorage.authToken),oauth_signature_method=HMAC-SHA1,oauth_timestamp=1626204865"
        
        guard let loginData = authString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpBody = parameters.percentEncoded()
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in guard let data = data, error == nil else { // check for fundamental networking error
            print("error=\(String(describing: error))")
            return
            }
            do {
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }

                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    print(response)

                } catch let error as NSError {
                    print(error)
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()

    }
    
    @IBAction func followingBtnClicked(_ sender: Any) {
        
    }
    
    @IBAction func followerBtnClicked(_ sender: Any) {
        
    }
    var accessToken = ""
    func getAccessToken() {

        //RFC encoding of ConsumerKey and ConsumerSecretKey
        let encodedConsumerKeyString:String = Services.consumerAppKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let encodedConsumerSecretKeyString:String = Services.consumerSecreateKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        print(encodedConsumerKeyString)
        print(encodedConsumerSecretKeyString)
        //Combine both encodedConsumerKeyString & encodedConsumerSecretKeyString with " : "
        let combinedString = encodedConsumerKeyString+":"+encodedConsumerSecretKeyString
        print(combinedString)
        //Base64 encoding
        let data = combinedString.data(using: .utf8)
        let encodingString = "Basic "+(data?.base64EncodedString())!
        print(encodingString)
        //Create URL request
        var request = URLRequest(url: URL(string: "https://api.twitter.com/oauth2/token")!)
        request.httpMethod = "POST"
        request.setValue(encodingString, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let bodyData = "grant_type=client_credentials".data(using: .utf8)!
        request.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = bodyData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let data = data, error == nil else { // check for fundamental networking error
            print("error=\(String(describing: error))")
            return
            }

            let responseString = String(data: data, encoding: .utf8)
            let dictionary = data
            print("dictionary = \(dictionary)")
            print("responseString = \(String(describing: responseString!))")

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }

            do {
                let response = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                print("Access Token response : \(response)")
                print(response["access_token"]!)
                self.accessToken = response["access_token"] as! String

                self.getStatusesUserTimeline(accessToken:self.accessToken)

            } catch let error as NSError {
                print(error)
            }
        }

        task.resume()
    }
}
