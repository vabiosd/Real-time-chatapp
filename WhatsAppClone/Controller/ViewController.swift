//
//  ViewController.swift
//  WhatsAppClone
//
//  Created by vaibhav singh on 27/11/17.
//  Copyright © 2017 vabappd. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UITableViewController {
    var Messages = [Message]()
    var msgdict = [String: Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handlelogout))
        let image = UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handlenewmessage))
        tableView.register(usercell.self, forCellReuseIdentifier: "cellid")
        checkifuserisloggedin()
        //observemessages()
        
    }
    func onserveusermessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let ref = Database.database().reference().child("user_messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userid = snapshot.key
            Database.database().reference().child("user_messages").child(uid).child(userid).observe(.childAdded, with: { (snapshot) in
                let messageid = snapshot.key
                let messageref = Database.database().reference().child("messages").child(messageid)
                messageref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dict = snapshot.value as? [String: Any]{
                        let message = Message(dictionary: dict)
                        if let chatpartnerid = message.chatpartnerid(){
                            self.msgdict[chatpartnerid] = message
                        }
                        self.attemptreloadtable()
                    }
                    
                }, withCancel: nil)
                
            }, withCancel: nil )
            
        }, withCancel: nil)
    }
    func attemptreloadtable(){
        self.time?.invalidate()
        self.time = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handlereload), userInfo: nil, repeats: false)
        
        
    }
    var time: Timer?
    @objc func handlereload(){
        self.Messages = Array(self.msgdict.values)
        self.Messages.sort(by: { (m1, m2) -> Bool in
            return (m1.time?.intValue)! > (m2.time?.intValue)!
        })
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    //    func observemessages(){
    //        let ref = Database.database().reference().child("messages")
    //        ref.observe(.childAdded, with: { (snapshot) in
    //            let message = Message()
    //            if let dict = snapshot.value as? [String: Any]{
    //                message.setValuesForKeys(dict)
    //                if let toid = message.toid{
    //                    self.msgdict[toid] = message
    //                    self.Messages = Array(self.msgdict.values)
    //                    self.Messages.sort(by: { (m1, m2) -> Bool in
    //                        return (m1.time?.intValue)! > (m2.time?.intValue)!
    //                    })
    //                }
    //
    ////                self.Messages.append(message)
    //                DispatchQueue.main.async {
    //                    self.tableView.reloadData()
    //                }
    //            }
    //
    //        }, withCancel: nil)
    //    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! usercell
        let message = Messages[indexPath.row]
        cell.message = message
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = Messages[indexPath.row]
        guard let chatpartnerid = message.chatpartnerid() else{
            return
        }
        let ref = Database.database().reference().child("users").child(chatpartnerid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else{ return }
            let user = User(dictionary: dict)
            user.id = chatpartnerid
            self.showchatlogforuser(user: user)
        }, withCancel: nil)
        
    }
    @objc func handlenewmessage(){
        let newmsgcontroller = newmessageViewController()
        newmsgcontroller.messages = self
        let navcontroller = UINavigationController(rootViewController: newmsgcontroller)
        present(navcontroller, animated: true, completion: nil)
    }
    func checkifuserisloggedin(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handlelogout), with: nil, afterDelay: 0)
        }else{
            fetchusersetuptitle()
        }
    }
    func fetchusersetuptitle(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                self.navigationItem.title = dict["name"] as? String
                let user = User(dictionary: dict)
                self.setupnavbarwithuser(user: user)
            }
        }, withCancel: nil)
    }
    func setupnavbarwithuser(user: User){
        Messages.removeAll()
        msgdict.removeAll()
        tableView.reloadData()
        onserveusermessages()
        let titleview = UIView()
        titleview.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let profileimage = UIImageView()
        let profileimageurl = user.profileImageUrl
        if let imageurl = profileimageurl{
            profileimage.loadimagewithcacahe(url: imageurl)
        }
        
        profileimage.translatesAutoresizingMaskIntoConstraints = false
        profileimage.contentMode = .scaleAspectFill
        profileimage.layer.cornerRadius = 20
        profileimage.layer.masksToBounds = true
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let namelabel = UILabel()
        namelabel.text = user.name
        namelabel.translatesAutoresizingMaskIntoConstraints = false
        titleview.addSubview(container)
        container.addSubview(profileimage)
        container.addSubview(namelabel)
        container.centerXAnchor.constraint(equalTo: titleview.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: titleview.centerYAnchor).isActive = true
        profileimage.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        profileimage.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        profileimage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileimage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        namelabel.leftAnchor.constraint(equalTo: profileimage.rightAnchor, constant: 8).isActive = true
        namelabel.centerYAnchor.constraint(equalTo: profileimage.centerYAnchor).isActive = true
        namelabel.heightAnchor.constraint(equalTo: profileimage.heightAnchor).isActive = true
        namelabel.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        self.navigationItem.titleView = titleview
        //        titleview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showchatlog)))
    }
    func showchatlogforuser(user: User){
        let chatcontroller = chatlogcontroller(collectionViewLayout: UICollectionViewFlowLayout())
        chatcontroller.user = user
        navigationController?.pushViewController(chatcontroller, animated: true)
    }
    @objc func handlelogout(){
        do{
            try Auth.auth().signOut()
        }catch let logouterr{
            print(logouterr)
        }
        let logincontrol = loginController()
        logincontrol.messagescontroller = self
        present(logincontrol, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

