//
//  messages.swift
//  chatapp
//
//  Created by vaibhav singh on 8/2/17.
//  Copyright © 2017 vaibhav singh. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    
    var text: String?
    var toid: String?
    var fromid: String?
    var time: NSNumber?
    var imageurl: String?
    var imageheight: NSNumber?
    var imagewidth: NSNumber?
    var videoUrl: String?
    func chatpartnerid() -> String?{
        if fromid == Auth.auth().currentUser?.uid{
            return toid
        }else{
            return fromid
        }
    }
    init(dictionary: [String: Any]){
        fromid = dictionary["fromid"] as? String
        text = dictionary["text"] as? String
        toid = dictionary["toid"] as? String
        time = dictionary["time"] as? NSNumber
        imageurl = dictionary["imageurl"] as? String
        imagewidth = dictionary["imagewidth"] as? NSNumber
        imageheight = dictionary["imageheight"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
    }
}
