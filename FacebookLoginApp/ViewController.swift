//
//  ViewController.swift
//  FacebookLoginApp
//
//  Created by Haditrisna on 10/8/18.
//  Copyright © 2018 YudhatrisnaProduction. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController: UIViewController {
    
    @IBOutlet weak var photoImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (loginResult: LoginResult) in
            switch loginResult {
            case .failed(let error):
                print(error.localizedDescription)
            case .cancelled:
                print("Login cancelled")
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Success, user was logged in")
                self.getDetails()
            }
        }
    }
    
    // Make a graph API request to get profile information and display user name and profile picture
    
    func getDetails() {
        guard let accessToken = AccessToken.current else { return }
        let parameters = ["fields": "name, picture.width(640).height(480)"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: parameters, accessToken: accessToken)
        graphRequest.start { (urlResponse, requestResult) in
            switch requestResult {
            case .failed(let error):
                print(error.localizedDescription)
            case .success(let graphResponse):
                guard let responseDictionary = graphResponse.dictionaryValue else { return }
                let name = responseDictionary["name"] as? String
                self.nameLabel.text = name
                guard let picture = responseDictionary["picture"] as? NSDictionary else { return }
                guard let data = picture["data"] as? NSDictionary else { return }
                guard let urlString = data["url"] as? String else { return }
                guard let url = URL(string: urlString) else { return }
                DispatchQueue.global().async {
                    guard let data = try? Data(contentsOf: url) else { return }
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.photoImgView.image = image
                    }
                }
            }
        }
    }
    
}

