//
//  CustomTableViewCell.swift
//  SwiftTest
//
//  Created by Olexii Strilets on 12/19/18.
//  Copyright © 2018 supersonic. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var simpleSwitch: UISwitch!
    
    let selectionStatus = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //disable user interaction for switch (switch status update on didSelectRowAtIndexPath method)
        self.simpleSwitch.isUserInteractionEnabled = false
    }
    
}
