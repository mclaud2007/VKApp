//
//  Photos.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.12.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class Photo: Object {
    @objc dynamic var date: Int = 0
    @objc dynamic var id: Int
    @objc dynamic var friendID: Int
    @objc dynamic var likes: Int
    @objc dynamic var photoURL: String? = nil
    @objc dynamic var isLiked: Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(friendID: Int, photoId id: Int, photo: String?, likes: Int?, liked: Bool? = false, date: Int?) {
        self.id = id
        self.photoURL = photo
        self.likes = likes ?? -1
        self.date = date ?? 0
        self.isLiked = liked!
        self.friendID = friendID
    }
    
    required init() {
        self.id = 0
        self.friendID = 0
        self.photoURL = nil
        self.likes = -1
        self.date = 0
        self.isLiked = false
    }
}