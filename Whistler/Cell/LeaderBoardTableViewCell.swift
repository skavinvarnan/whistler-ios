//
//  LeaderBoardTableViewCell.swift
//  Whistler
//
//  Created by Kavin Varnan on 01/04/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class LeaderBoardTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var points: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
