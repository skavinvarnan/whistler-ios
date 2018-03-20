//
//  PredictionTableViewCell.swift
//  Whistler
//
//  Created by Kavin Varnan on 19/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class PredictionTableViewCell: UITableViewCell {

    @IBOutlet weak var over: UILabel!
    @IBOutlet weak var prediction: UILabel!
    @IBOutlet weak var points: UILabel!
    
    @IBAction func predictScore(_ sender: UIButton) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
