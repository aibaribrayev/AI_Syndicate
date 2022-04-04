//
//  SignUpViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 22.07.2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class SignUpViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    private let database = Database.database().reference()
    @IBOutlet var userName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var typeOfUser: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func signUpTapped(_ sender: Any) {
        var userType = ""
        switch typeOfUser.selectedSegmentIndex {
        case 0:
            userType = "Инвестор"
        case 1:
            userType = "Стартапер"
        default:
            print("No type of user")
            return
        }
        
        //signUp()
        guard let email = email.text, !email.isEmpty,
              let password = password.text, !password.isEmpty,
              let name = userName.text, !name.isEmpty else {
            return
        }

        HapticsManager.shared.vibrateForSelection()

        // Create User
        AuthManager.shared.signUp(email: email, password: password) { [weak self] success in
            if success {
                // Update database
                let newUser = User(username: name, email: email, typeOfUser: userType,profileImage: nil)
                DatabaseManager.shared.insert(user: newUser) { inserted in
                    guard inserted else {
                        return
                    }

                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(userType, forKey: "typeOfUser")
                    /*DispatchQueue.main.async {
                        let vc = TabBarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }*/
                    currentUser = User(username: name, email: email, typeOfUser: userType, profileImage: nil)
                    
                    let stroyboard = UIStoryboard(name:"Main", bundle: nil)
                    let vc = stroyboard.instantiateViewController(withIdentifier: "mainHome")
                    vc.modalPresentationStyle = .overFullScreen
                    self!.present(vc, animated: true)
                }
            } else {
                print("Failed to create account")
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        let stroyboard = UIStoryboard(name:"Main", bundle: nil)
        let vc = stroyboard.instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func signUp(){
        Auth.auth().createUser(withEmail: email.text!, password: password.text!){(authResult, error) in
            guard let user = authResult?.user, error == nil else {
                print("Error \(error?.localizedDescription)")
                return
            }
            //self.addInfo()
            
            let stroyboard = UIStoryboard(name:"Main", bundle: nil)
            let vc = stroyboard.instantiateViewController(withIdentifier: "mainHome")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    /*@objc func addInfo(){
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let object: [String: String] =
            ["userName": userName.text!,
             "typeOfUser": userType]
        database.child("users").child(userID).setValue(object)
    }*/
    /*func selectHomePage(){
        let stroyboard = UIStoryboard(name:"Main", bundle: nil)
        let vc = stroyboard.instantiateViewController(withIdentifier: "mainHome")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }*/
    
}
