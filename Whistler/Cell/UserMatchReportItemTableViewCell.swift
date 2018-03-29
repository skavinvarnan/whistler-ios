//
//  UserMatchReportItemTableViewCell.swift
//  Whistler
//
//  Created by Kavin Varnan on 29/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class UserMatchReportItemTableViewCell: UITableViewCell {

    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var match: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
