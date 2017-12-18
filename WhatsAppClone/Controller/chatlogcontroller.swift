//
//  chatlogcontroller.swift
//  chatapp
//
//  Created by vaibhav singh on 8/2/17.
//  Copyright © 2017 vaibhav singh. All rights reserved.
//

import UIKit
import Firebase
class chatlogcontroller: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            observemessages()
        }
    }
    var messages = [Message]()
    func observemessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toid = user?.id else{
            return
        }
        let usermessageref = Database.database().reference().child("user_messages").child(uid).child(toid)
        usermessageref.observe(.childAdded, with: { (snapshot) in
            let messagesid = snapshot.key
            let messagesref = Database.database().reference().child("messages").child(messagesid)
            messagesref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String: Any] else{
                    return
                }
                self.messages.append(Message(dictionary: dict))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexpath = IndexPath(item: self.messages.count - 1 , section: 0)
                    self.collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
                }
//                if message.chatpartnerid() == self.user?.id{
//                    self.messages.append(message)
//                    DispatchQueue.main.async {
//                        self.collectionView?.reloadData()
//                    }                }
//                
//                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    lazy var containerview: UIView = {
        let containerview = UIView()
        containerview.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerview.backgroundColor = UIColor.white
        let sendbutton = UIButton(type: .system)
        sendbutton.setTitle("Send", for: .normal)
        sendbutton.translatesAutoresizingMaskIntoConstraints = false
        sendbutton.addTarget(self, action: #selector(handlesend), for: .touchUpInside)
        let separator = UIView()
        separator.backgroundColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        let uploadimageview =  UIImageView()
        uploadimageview.image = UIImage(named: "uploadimage")
        uploadimageview.contentMode = .scaleAspectFill
        uploadimageview.isUserInteractionEnabled = true
        uploadimageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadgesture)))
        uploadimageview.translatesAutoresizingMaskIntoConstraints = false
        
        containerview.addSubview(sendbutton)
        containerview.addSubview(self.inputtext)
        containerview.addSubview(separator)
        containerview.addSubview(uploadimageview)
        
        uploadimageview.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        uploadimageview.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        uploadimageview.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadimageview.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        sendbutton.rightAnchor.constraint(equalTo: containerview.rightAnchor).isActive = true
        sendbutton.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        sendbutton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendbutton.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        
        self.inputtext.leftAnchor.constraint(equalTo: uploadimageview.rightAnchor, constant: 8).isActive = true
        self.inputtext.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        self.inputtext.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        self.inputtext.rightAnchor.constraint(equalTo: sendbutton.leftAnchor).isActive = true
        
        separator.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: containerview.widthAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: containerview.topAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return containerview
    }()
    @objc  func uploadgesture(){
        let imagepickerc = UIImagePickerController()
        imagepickerc.delegate = self
        imagepickerc.allowsEditing = true
        present(imagepickerc, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedimage: UIImage?
        if let editedimage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedimage = editedimage
        }
        else if let originalimage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedimage = originalimage
        }
        if let selected = selectedimage{
            uploadtofirebase(image: selected)
        }
        dismiss(animated: true, completion: nil)

    }
    func uploadtofirebase(image: UIImage){
        let imagename = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imagename)
        if let uploaddata = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploaddata, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                if let imageurl = metadata?.downloadURL()?.absoluteString{
                    self.sendmessagewithimage(imageurl: imageurl, image: image)
                }
            })
        }
        
    }
        override var inputAccessoryView: UIView?{
        get{
            return containerview
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupinputcomponents()
        setupkeyboard()
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.register(chatMesaageCell.self, forCellWithReuseIdentifier: "cellid")
    }
    func setupkeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(handelkeyboarddidshow), name: .UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handelshowkeyboard), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handelhidekeyboard), name: .UIKeyboardWillHide, object: nil)
    }
    @objc func handelkeyboarddidshow(){
        if messages.count > 0 {
            let index = IndexPath(item: messages.count - 1 , section: 0)
            collectionView?.scrollToItem(at: index, at: .top, animated: true)
        }
            }
    func handelhidekeyboard(notification: NSNotification){
        containerbottomanchor?.constant = 0
        let keyboardduration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: keyboardduration!) {
            self.view.layoutIfNeeded()
        }

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func handelshowkeyboard(notification: NSNotification){
        let keyboardframe = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        containerbottomanchor?.constant = -keyboardframe!.height
        let keyboardduration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: keyboardduration!) { 
            self.view.layoutIfNeeded()
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid", for: indexPath) as! chatMesaageCell
        cell.chatlogcontroller = self
        cell.textview.text = messages[indexPath.row].text
        let message = messages[indexPath.row]
        setupchatcell(cell: cell, message: message)
        if let text = message.text{
            cell.textview.isHidden = false
            cell.bubblewidthanchor?.constant = estimatedframefortexts(text: text).width + 28
        }else if message.imageurl != nil{
            cell.bubblewidthanchor?.constant = 200
            cell.textview.isHidden = true
        }
        
        return cell
    }
    func setupchatcell(cell: chatMesaageCell, message: Message){
            if message.fromid == Auth.auth().currentUser?.uid{
            cell.bubble.backgroundColor = UIColor.init(red: 0, green: 137, blue: 249, alpha: 1)
            cell.textview.textColor = .white
            cell.profileimage.isHidden = true
            cell.bubbleviewrightanchor?.isActive = true
            cell.bubbleleftanchor?.isActive = false

        }else{
            cell.profileimage.isHidden = false
            cell.bubble.backgroundColor = UIColor.init(red: 220, green: 220, blue: 220, alpha: 1)
                cell.textview.textColor = .black
            cell.bubbleviewrightanchor?.isActive = false
            cell.bubbleleftanchor?.isActive = true
        }
        if let imageurl = self.user?.profileImageUrl{
            cell.profileimage.loadimagewithcacahe(url: imageurl)
        }
        if let messageimageur = message.imageurl{
            cell.messageimage.loadimagewithcacahe(url: messageimageur)
            cell.messageimage.isHidden = false
            cell.bubble.backgroundColor = .clear
        }else{
            cell.messageimage.isHidden = true
            
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text{
            height = estimatedframefortexts(text: text).height + 28
        }else if let imagewidth = message.imagewidth?.doubleValue, let imageheight = message.imageheight?.doubleValue{
            height = CGFloat(imageheight / imagewidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width:  width, height: height)
    }
    func estimatedframefortexts(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    @objc func handlesend(){
        let property = ["text": inputtext.text!] as [String : Any]
        senmessagewithproperties(property: property)

    }
    func sendmessagewithimage(imageurl: String, image: UIImage){
        let properties = ["imageurl": imageurl, "imageheight": image.size.height, "imagewidth": image.size.width ] as [String : Any]
        senmessagewithproperties(property: properties)
       
    }
    
    func senmessagewithproperties( property: [String: Any]){
        let ref = Database.database().reference().child("messages")
        let toid = user!.id!
        
        let fromid = Auth.auth().currentUser!.uid
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        var values = ["toid": toid, "fromid": fromid, "time": timestamp ] as [String : Any]
        property.forEach({values[$0] = $1})
        let childref = ref.childByAutoId()
        childref.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            self.inputtext.text = nil
            let usermessagesref = Database.database().reference().child("user_messages").child(fromid).child(toid)
            let messageid = childref.key
            usermessagesref.updateChildValues([messageid: 1] )
            let recipientref = Database.database().reference().child("user_messages").child(toid).child(fromid)
            recipientref.updateChildValues([messageid: 1])
        }

    }
    
    
    lazy var inputtext: UITextField = {
        let inputtext = UITextField()
        inputtext.placeholder = "Enter message"
        inputtext.delegate = self
        inputtext.backgroundColor = .white
        inputtext.translatesAutoresizingMaskIntoConstraints = false
        return inputtext

    }()
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handlesend()
        return true
    }
    var containerbottomanchor: NSLayoutConstraint?
    func setupinputcomponents(){
        let containerview = UIView()
        containerview.translatesAutoresizingMaskIntoConstraints = false
        
        let sendbutton = UIButton(type: .system)
        sendbutton.setTitle("Send", for: .normal)
        sendbutton.translatesAutoresizingMaskIntoConstraints = false
        sendbutton.addTarget(self, action: #selector(handlesend), for: .touchUpInside)
        
        let separator = UIView()
        separator.backgroundColor = UIColor.init(red: 220, green: 220, blue: 220, alpha: 1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerview)
        containerview.addSubview(sendbutton)
        containerview.addSubview(inputtext)
        containerview.addSubview(separator)
        
        containerview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerbottomanchor = containerview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerbottomanchor?.isActive = true
        containerview.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerview.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        sendbutton.rightAnchor.constraint(equalTo: containerview.rightAnchor).isActive = true
        sendbutton.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        sendbutton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendbutton.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        
        inputtext.leftAnchor.constraint(equalTo: containerview.leftAnchor, constant: 8).isActive = true
        inputtext.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        inputtext.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        inputtext.rightAnchor.constraint(equalTo: sendbutton.leftAnchor).isActive = true
        
        separator.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: containerview.widthAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: containerview.topAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    @objc func handlezoomout(tapgesture: UITapGestureRecognizer){
        if let zoomoutimageview = tapgesture.view{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                zoomoutimageview.frame = self.startingframe!
                self.blackview?.alpha = 0
                self.containerview.alpha = 1
                zoomoutimageview.layer.cornerRadius = 16
                zoomoutimageview.layer.masksToBounds = true
            
            }, completion: { (completed) in
                self.blackview?.alpha = 0
                           })
         
        }
    }
    var startingframe: CGRect?
    var blackview: UIView?
    func performzoom(imageview: UIImageView){
        startingframe = imageview.superview?.convert(imageview.frame, to: nil)
        let zoomingimageview = UIImageView(frame: startingframe!)
        zoomingimageview.backgroundColor = UIColor.green
        zoomingimageview.image = imageview.image
        zoomingimageview.isUserInteractionEnabled = true
        zoomingimageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlezoomout)))
        if let keywindow = UIApplication.shared.keyWindow{
            
            blackview = UIView(frame: keywindow.frame)
            blackview?.backgroundColor = .black
            blackview?.alpha = 0
            keywindow.addSubview(blackview!)
            keywindow.addSubview(zoomingimageview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackview?.alpha = 1
                self.containerview.alpha = 0
                let height = self.startingframe!.height / self.startingframe!.width * keywindow.frame.width
                zoomingimageview.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
            }, completion: { (completed) in
                
            })

            zoomingimageview.center = keywindow.center
        }
            }
}
