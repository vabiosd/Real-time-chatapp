//
//  newmessageViewController.swift
//  chatapp
//
//  Created by vaibhav singh on 8/1/17.
//  Copyright © 2017 vaibhav singh. All rights reserved.
//

import UIKit
import Firebase
class newmessageViewController: UITableViewController{
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:#selector(handlecancel))
        tableView.register(usercell.self, forCellReuseIdentifier: "cellid")
        fetchuser()
    }
    func fetchuser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let user = User(dictionary: dict)
                user.id = snapshot.key
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    @objc func handlecancel(){
        dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! usercell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
//        cell.imageView?.image = UIImage(named: "icon")
//        if let url = URL(string: profileurl){
//            let session = URLSession.shared
//            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
//                if error != nil {
//                    print(error)
//                    return
//                }
//                DispatchQueue.main.async {
////                    cell.imageView?.image = UIImage(data: data!)
//                    cell.profileimage.image = UIImage(data: data!)
//                }
//                
//            })
//            task.resume()
//        }
        if let profileurl = user.profileImageUrl{
            cell.profileimage.loadimagewithcacahe(url: profileurl)
        }
        
//        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }
    var messages: ViewController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messages?.showchatlogforuser(user: user)
        }
    }
}
