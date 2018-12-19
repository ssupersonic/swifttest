//
//  Post.swift
//  SwiftTest
//
//  Created by Olexii Strilets on 12/19/18.
//  Copyright © 2018 supersonic. All rights reserved.
//

import Foundation

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
