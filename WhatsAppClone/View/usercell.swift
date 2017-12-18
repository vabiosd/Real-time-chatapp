//
//  usercell.swift
//  chatapp
//
//  Created by vaibhav singh on 8/3/17.
//  Copyright © 2017 vaibhav singh. All rights reserved.
//

import UIKit
import Firebase
class usercell: UITableViewCell{
    var message: Message?{
        didSet{
            setupnameandprofileimage()
                if let seconds = message?.time?.doubleValue{
                let timestamp = Date(timeIntervalSince1970: seconds)
                let dateformat = DateFormatter()
                dateformat.dateFormat = "hh:mm:ss a"
                
                timelabel.text = dateformat.string(from: timestamp)
            }
            detailTextLabel?.text = message?.text
        }
    }
    func setupnameandprofileimage(){
        
        if let id = message?.chatpartnerid(){
        let ref = Database.database().reference().child("users").child(id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dict = snapshot.value as? [String: Any]{
        self.textLabel?.text = dict["name"] as? String
        if let imageurl = dict["profileImageUrl"] as? String{
        self.profileimage.loadimagewithcacahe(url: imageurl)
    }
    }
    })
    }

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    let timelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    let profileimage: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "icon")
        imageview.layer.cornerRadius = 24
        imageview.layer.masksToBounds = true
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileimage)
        addSubview(timelabel)
        
        profileimage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileimage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileimage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileimage.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timelabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        timelabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        timelabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timelabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
