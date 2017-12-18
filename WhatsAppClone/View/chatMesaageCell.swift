//
//  chatMesaageCell.swift
//  chatapp
//
//  Created by vaibhav singh on 8/4/17.
//  Copyright © 2017 vaibhav singh. All rights reserved.
//

import UIKit

class chatMesaageCell: UICollectionViewCell {
    var chatlogcontroller: chatlogcontroller?
    let textview: UITextView = {
        let textview = UITextView()
        textview.text = "textetxtetx"
        textview.backgroundColor = .clear
        textview.textColor = .white
        textview.font = UIFont.boldSystemFont(ofSize: 16)
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.isEditable = false
        return textview
    }()
    let bubble: UIView = {
        let bubble = UIView()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.backgroundColor = UIColor.init(red: 0, green: 137, blue: 249, alpha: 1)
        bubble.layer.cornerRadius = 16
        bubble.layer.masksToBounds = true
        return bubble
    }()
    let profileimage: UIImageView = {
        let profile = UIImageView()
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.image = UIImage(named: "icon")
        profile.layer.cornerRadius = 16
        profile.layer.masksToBounds = true
        profile.contentMode = .scaleAspectFill
        return profile
    }()
    lazy var messageimage: UIImageView = {
        let profile = UIImageView()
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.image = UIImage(named: "icon")
        profile.layer.cornerRadius = 16
        profile.layer.masksToBounds = true
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomtap)))
        profile.contentMode = .scaleAspectFill
        return profile
    }()
    @objc func zoomtap(tapgesture: UITapGestureRecognizer){
        if let imageview = tapgesture.view as? UIImageView{
         self.chatlogcontroller?.performzoom(imageview: imageview)   
        }
    }
    var bubblewidthanchor: NSLayoutConstraint?
    var bubbleviewrightanchor: NSLayoutConstraint?
    var bubbleleftanchor: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubble)
        addSubview(textview)
        addSubview(profileimage)
        bubble.addSubview(messageimage)
//        textview.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textview.leftAnchor.constraint(equalTo: bubble.leftAnchor, constant: 8).isActive = true
        textview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textview.rightAnchor.constraint(equalTo: bubble.rightAnchor).isActive = true
        
        textview.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleviewrightanchor = bubble.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleviewrightanchor?.isActive = true
        bubbleleftanchor = bubble.leftAnchor.constraint(equalTo: profileimage.rightAnchor, constant: 8)
        
        bubble.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubblewidthanchor = bubble.widthAnchor.constraint(equalToConstant: 200)
        bubblewidthanchor?.isActive = true
        bubble.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        profileimage.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileimage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileimage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileimage.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        messageimage.leftAnchor.constraint(equalTo: bubble.leftAnchor).isActive = true
        messageimage.topAnchor.constraint(equalTo: bubble.topAnchor).isActive = true
        messageimage.widthAnchor.constraint(equalTo: bubble.widthAnchor).isActive = true
        messageimage.heightAnchor.constraint(equalTo: bubble.heightAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
