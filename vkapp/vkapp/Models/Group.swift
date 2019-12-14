//
//  Groups.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class Group: Object {
    @objc dynamic var name: String
    var imageString: String?
    var image: UIImage?
    @objc dynamic var groupId: Int
    
    init (groupId: Int, name: String, image: UIImage?){
        self.groupId = groupId
        self.name = name
        self.image = image
        self.imageString = nil
    }
    
    init (groupId: Int, name: String, image: String?){
        self.groupId = groupId
        self.name = name
        self.imageString = image
        self.image = nil
    }

    init (groupId: Int, name: String){
        self.groupId = groupId
        self.name = name
        self.image = nil
        self.imageString = nil
    }
    
    required init() {
        self.groupId = 0
        self.name = ""
        self.image = nil
        self.imageString = nil
    }
}
