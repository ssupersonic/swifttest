//
//  CustomTableViewCell.swift
//  SwiftTest
//
//  Created by Olexii Strilets on 12/19/18.
//  Copyright © 2018 supersonic. All rights reserved.
//

import UIKit

class Post {
    var title: String
    var date: String
    var status: Bool
    
    init(title: String, date: String, status: Bool) {
        self.title = title
        self.date = date
        self.status = status
    }
}

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var simpleSwitch: UISwitch!
    
    let selectionStatus = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.simpleSwitch.isUserInteractionEnabled = false
    }
    
}
