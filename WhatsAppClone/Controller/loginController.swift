//
//  loginController.swift
//  chatapp
//
//  Created by vaibhav singh on 7/31/17.
//  Copyright © 2017 vaibhav singh. All rights reserved.
//

import UIKit
import Firebase
class loginController: UIViewController {
    var messagescontroller: ViewController?
    let registerbutton: UIButton = {
        let button  = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleloginregister), for: .touchUpInside)
        return button
    }()
    @objc func handleloginregister(){
        if segmentedlogin.selectedSegmentIndex == 0{
            handlelogin()
        }else{
            handleregister()
        }
    }
    func handlelogin(){
        guard let email = emailtext.text, let password = passwordtext.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error)
                return
            }else{
                self.messagescontroller?.fetchusersetuptitle()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
        let nametext: UITextField = {
        let text = UITextField()
        text.placeholder = "Name"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    let emailtext: UITextField = {
        let text = UITextField()
        text.placeholder = "Email ID"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    let passwordtext: UITextField = {
        let text = UITextField()
        text.isSecureTextEntry = true
        text.placeholder = "Password"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    let top = (UIScreen.main.bounds.height - 150) / 2
    let inputcontainer: UIView = {
        let inputview = UIView()
        inputview.backgroundColor = .white
        inputview.layer.cornerRadius = 5
        inputview.layer.masksToBounds = true
        inputview.translatesAutoresizingMaskIntoConstraints = false
        return inputview
    }()
    let nameseparator: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        return line
    }()
    let emailseparator: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        return line
    }()
    lazy var profileimage : UIImageView = {
        let imageview = UIImageView()
        imageview.image = #imageLiteral(resourceName: "icon")
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleselectprofileimage)))
        return imageview
    }()
    func setupsegment(){
        segmentedlogin.heightAnchor.constraint(equalToConstant: 50).isActive = true
        segmentedlogin.leftAnchor.constraint(equalTo: inputcontainer.leftAnchor).isActive = true
        segmentedlogin.bottomAnchor.constraint(equalTo: inputcontainer.topAnchor, constant: -12).isActive = true
        segmentedlogin.rightAnchor.constraint(equalTo: inputcontainer.rightAnchor).isActive = true
    }
    let segmentedlogin: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handlesegment), for: .valueChanged)
        return sc
    }()
    @objc func handlesegment(){
        let title = segmentedlogin.titleForSegment(at: segmentedlogin.selectedSegmentIndex)
        registerbutton.setTitle(title, for: .normal )
        inputcontainerheightconstraint?.constant = segmentedlogin.selectedSegmentIndex == 0 ? 100 : 150
        nametextheightconstraint?.isActive = false
        nametextheightconstraint = nametext.heightAnchor.constraint(equalTo: inputcontainer.heightAnchor, multiplier: segmentedlogin.selectedSegmentIndex == 0 ? 0 : 1/3)
        nametextheightconstraint?.isActive = true
        emailheightconstraint?.isActive = false
         emailheightconstraint = emailtext.heightAnchor.constraint(equalTo: inputcontainer.heightAnchor, multiplier: segmentedlogin.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailheightconstraint?.isActive = true
        passheightconstraint?.isActive = false
        passheightconstraint = passwordtext.heightAnchor.constraint(equalTo: inputcontainer.heightAnchor, multiplier: segmentedlogin.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passheightconstraint?.isActive = true
    }
    func setupimage(){
        profileimage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileimage.bottomAnchor.constraint(equalTo: segmentedlogin.topAnchor, constant: -12).isActive = true
        profileimage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileimage.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    func setupregisterbutton(){
        registerbutton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        registerbutton.topAnchor.constraint(equalTo: inputcontainer.bottomAnchor, constant: 12).isActive = true
        
        registerbutton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        
        registerbutton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    var inputcontainerheightconstraint : NSLayoutConstraint?
    var nametextheightconstraint : NSLayoutConstraint?
    var emailheightconstraint: NSLayoutConstraint?
    var passheightconstraint: NSLayoutConstraint?
    func setupinput(){
        inputcontainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputcontainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputcontainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputcontainerheightconstraint = inputcontainer.heightAnchor.constraint(equalToConstant: 150)
        inputcontainerheightconstraint?.isActive = true
        inputcontainer.addSubview(nametext)
        inputcontainer.addSubview(nameseparator)
        inputcontainer.addSubview(emailtext)
        inputcontainer.addSubview(emailseparator)
        inputcontainer.addSubview(passwordtext)
        nametext.topAnchor.constraint(equalTo: inputcontainer.topAnchor).isActive = true
        nametext.leftAnchor.constraint(equalTo: inputcontainer.leftAnchor, constant: 12).isActive = true
        nametext.rightAnchor.constraint(equalTo: inputcontainer.rightAnchor, constant: 12).isActive = true
        nametextheightconstraint = nametext.heightAnchor.constraint(equalTo: inputcontainer.heightAnchor, multiplier: 1/3)
        nametextheightconstraint?.isActive = true
        nameseparator.topAnchor.constraint(equalTo: nametext.bottomAnchor).isActive = true
        nameseparator.leftAnchor.constraint(equalTo: inputcontainer.leftAnchor).isActive = true
        nameseparator.rightAnchor.constraint(equalTo: inputcontainer.rightAnchor).isActive = true
        nameseparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        emailtext.topAnchor.constraint(equalTo: nametext.bottomAnchor).isActive = true
        emailtext.leftAnchor.constraint(equalTo: inputcontainer.leftAnchor, constant: 12).isActive = true
        emailtext.rightAnchor.constraint(equalTo: inputcontainer.rightAnchor, constant: 12).isActive = true
        emailheightconstraint = emailtext.heightAnchor.constraint(equalTo: inputcontainer.heightAnchor, multiplier: 1/3)
        emailheightconstraint?.isActive = true
        emailseparator.topAnchor.constraint(equalTo: emailtext.bottomAnchor).isActive = true
        emailseparator.leftAnchor.constraint(equalTo: inputcontainer.leftAnchor).isActive = true
        emailseparator.rightAnchor.constraint(equalTo: inputcontainer.rightAnchor).isActive = true
        emailseparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        passwordtext.topAnchor.constraint(equalTo: emailtext.bottomAnchor).isActive = true
        passwordtext.leftAnchor.constraint(equalTo: inputcontainer.leftAnchor, constant: 12).isActive = true
        passwordtext.rightAnchor.constraint(equalTo: inputcontainer.rightAnchor, constant: 12).isActive = true
        passheightconstraint = passwordtext.heightAnchor.constraint(equalTo: inputcontainer.heightAnchor, multiplier: 1/3)
        passheightconstraint?.isActive = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        view.addSubview(inputcontainer)
        view.addSubview(registerbutton)
        view.addSubview(segmentedlogin)
        view.addSubview(profileimage)
        setupinput()
        setupregisterbutton()
        setupsegment()
        setupimage()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
