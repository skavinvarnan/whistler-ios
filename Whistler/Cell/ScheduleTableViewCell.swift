//
//  ScheduleTableViewCell.swift
//  Whistler
//
//  Created by Kavin Varnan on 22/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var teamAImage: UIImageView!
    @IBOutlet weak var teamBImage: UIImageView!
    @IBOutlet weak var teamALabel: UILabel!
    @IBOutlet weak var teamBLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var matchNumberLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
