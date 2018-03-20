//
//  TronService.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import TRON
import Firebase

class TronService {
    static let sharedInstance = TronService();
    
    let tron: TRON
    private init() {
         tron = TRON(baseURL: Constants.Tron.BASE_URL)
    }
    
    public func createRequest<Model: JSONDecodable, ErrorModel: JSONDecodable>(path: String) -> APIRequest<Model, ErrorModel> {
        let request: APIRequest<Model, ErrorModel> = tron.swiftyJSON.request(path);
        if let user = Auth.auth().currentUser {
            request.headers["uid"] = user.uid
        }
        request.headers["accessToken"] = UserDefaults.standard.string(forKey: Constants.UserDefaults.ACCESS_TOKEN)
        return request;
    }
}
