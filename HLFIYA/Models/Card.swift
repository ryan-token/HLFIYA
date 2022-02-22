//
//  Card.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import UIKit

struct Card: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let age: Int
    let bio: String
    var x: CGFloat = 0.0 // Card x position
    var y: CGFloat = 0.0 // Card y position
    var degree: Double = 0.0 // Card rotation angle
    
    static var data: [Card] {
        [
            Card(name: "Rosie", imageName: "p0", age: 21, bio: "Insta - roooox 💋"),
            Card(name: "Betty", imageName: "p1", age: 23, bio: "Like exercising, going out, pub, working 🍻"),
            Card(name: "Abigail", imageName: "p2", age: 26, bio: "hi, let's be friends"),
            Card(name: "Zoé", imageName: "p3", age: 20, bio: "Law grad"),
            Card(name: "Tilly", imageName: "p4", age: 21, bio: "Follow me on IG"),
            Card(name: "Penny", imageName: "p5", age: 24, bio: "J'aime la vie et le vin 🍷"),
        ]
    }
    
}
