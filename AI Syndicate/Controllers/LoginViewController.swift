//
//  ViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 22.07.2021.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var eyeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    override func viewDidAppear(_ animated: Bool) {
        checkUserInfo()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func loginAsGuest(_ sender: Any) {
        currentUser = User(username: "", email: "guess", typeOfUser: "Гость", profileImage: nil)
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "guestMainVC") {
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        validateFields()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let stroyboard = UIStoryboard(name:"Main", bundle: nil)
        let vc = stroyboard.instantiateViewController(identifier: "signUp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func validateFields(){
        if(email.text?.isEmpty == true){
            print("No Email Text")
            return
        }
        if(password.text?.isEmpty == true){
            print("No Password")
            return
        }
        
        login()
    }
    
    func login(){
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] authResult, err in
            guard let strongSelf = self else{ return}
            if let err = err{
                print(err.localizedDescription)
                return
            }
            self?.checkUserInfo()
        }
    }
    
    func checkUserInfo(){
        if let user = Auth.auth().currentUser {
            DatabaseManager.shared.getUser(email:user.email!) { user in
                guard let user = user else {
                    return
                }
                currentUser = User(username: user.username, email: user.email, typeOfUser: user.typeOfUser, profileImage: user.profileImage)
                DatabaseManager.shared.getLikedNewsPostsID() { likedPostsIds in
                    currentUser?.likedNewsPostIds = likedPostsIds
                }
                DatabaseManager.shared.getLikedStartUpPostsID(){
                    likedPostsIds in
                    currentUser?.likedStartUpPostIds = likedPostsIds
                }
                if(currentUser?.typeOfUser == "Инвестор"){
                    
                    DatabaseManager.shared.getInvestedPostsIds(){ investedStartUpIds in
                        currentUser?.investedStartUps = investedStartUpIds
                    }
                }
            }
            
            print(user.uid)
            let stroyboard = UIStoryboard(name:"Main", bundle: nil)
            let vc = stroyboard.instantiateViewController(identifier: "mainHome")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func eyeTapped(_ sender: Any) {
        if(password.isSecureTextEntry == true){
            password.isSecureTextEntry = false
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
        else{
            password.isSecureTextEntry = true
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
}

