# FacebookLogin-App
### Login with Facebook SDK
<a href="https://imgflip.com/gif/2jpabf"><img src="https://i.imgflip.com/2jpabf.gif" title="made at imgflip.com"/></a>

### Make a graph API request to get profile information and display user name and profile picture

```Swift
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
    
