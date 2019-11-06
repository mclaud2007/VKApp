//
//  Friends.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class Friend {
    let name: String
    // Аватарка пользовтеля
    let photo: UIImage?
    // Массив с фотографиями пользователя
    let photos: [UIImage]?
    // Массив с лайками под фото (ключ в массиве - номер фотографии)
    // в дальнейшем это все должно приходить через АПИ по сети
    let likes: [Int]?
    // Массив ЗНАЧЕНИЯ в котором - номера (ключи) фото, к которым
    // уже поставил отметку нравится текущий пользователь
    let liked: [Int]?
    
    init (photo: UIImage, name: String, photos: Array<UIImage>, likes: [Int], liked: [Int]){
        self.name = name
        self.photo = photo
        self.photos = photos
        self.likes = likes
        self.liked = liked
    }
    
    init (photo: UIImage, name: String, photos: Array<UIImage>, likes: [Int]){
        self.name = name
        self.photo = photo
        self.photos = photos
        self.likes = likes
        self.liked = [-1]
    }
    
    init (photo: UIImage, name: String){
        self.name = name
        self.photo = photo
        self.photos = nil
        self.likes = [0]
        self.liked = [-1]
    }
    
    init (name: String){
        self.name = name
        self.photo = nil
        self.photos = nil
        self.likes = [0]
        self.liked = [-1]
    }
}