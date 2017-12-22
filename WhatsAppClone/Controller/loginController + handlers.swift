//
//  loginController + handlers.swift
//  chatapp
//
//  Created by vaibhav singh on 8/1/17.
//  Copyright © 2017 vaibhav singh. All rights reserved.
//

import UIKit
import Firebase
extension loginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func handleregister(){
        guard let email = emailtext.text, let password = passwordtext.text, let name = nametext.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
            if err != nil{
                print(err)
                return
            }
           
            guard let uid = user?.uid else { return }
            let imagename = NSUUID().uuidString
            let storageref = Storage.storage().reference().child("profile_images").child("\(imagename).jpg")
            if let uploaddata = UIImageJPEGRepresentation(self.profileimage.image!, 0.1){
                storageref.putData(uploaddata, metadata: nil, completion: { (metadata, err) in
                    if err != nil{
                        print(err)
                        return
                    }
                    if let imageurl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageUrl": imageurl]
                        self.registeruser(uid: uid, values: values)

                    }
                    
                                   })
            }
        }
    }
    func registeruser(uid: String, values: [String: Any]){
        
        let ref = Database.database().reference(fromURL: "https://whatsappclone-b3a26.firebaseio.com/")
        let userref = ref.child("users").child(uid)
        userref.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error)
                return
            }
//            self.messagescontroller?.fetchusersetuptitle() 
            let user = User(dictionary: values)
            self.messagescontroller?.setupnavbarwithuser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleselectprofileimage(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
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
              profileimage.image = selected
        }
        dismiss(animated: true, completion: nil)
    }
}
