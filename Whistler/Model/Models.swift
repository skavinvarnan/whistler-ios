//
//  Models.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class Models: NSObject {

}

struct Group {
    let id: String
    let groupId: String
    let name: String
    let icon: String?
    let joinCode: String
    let admin: String
    let members: [String]
}
