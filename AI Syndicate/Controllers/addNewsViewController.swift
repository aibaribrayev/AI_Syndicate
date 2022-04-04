//
//  addNewsViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 19.09.2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class addNewsViewController: UIViewController, UITextViewDelegate{

    //let currentEmail = Auth.auth().currentUser?.email
    //var user = User(username: "",email: "",typeOfUser: "", profileImage: "")
    @IBOutlet var activityIndView: UIActivityIndicatorView!
    private var selectedImage: UIImage?
    @IBOutlet var titleField: UITextField!
    @IBOutlet var incorrectInputLabel: UILabel!
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndView.isHidden = true
        textView.layer.cornerRadius = 10
        titleField.font = UIFont(name: "verdana", size: 18.0)
        textView.textColor = UIColor.lightGray
        textView.font = UIFont(name: "verdana", size: 16.0)
        textView.returnKeyType = .done
        textView.delegate = self
        // Do any additional setup after loading the view.
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Описание" {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Описание"
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "system", size: 16.0)
        }
        else{
            textView.font = UIFont(name: "system", size: 16.0)
        }
    }

    @IBAction func addImageTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addStartUpTapped(_ sender: Any) {
        guard let body = textView.text,
        let title = titleField.text,
        let headerImage = selectedImage,
        let email = Auth.auth().currentUser?.email,
        !title.trimmingCharacters(in: .whitespaces).isEmpty,
        !body.trimmingCharacters(in: .whitespaces).isEmpty else {
            incorrectInputLabel.isHidden = false
            return
        }
        activityIndView.isHidden = false
        activityIndView.startAnimating()
        print(email)
        print("Starting post...")
        let newPostId = UUID().uuidString
        print(newPostId)
            // Upload header Image
        StorageManager.shared.uploadNewsPostHeaderImage(
            email: email,
            image: headerImage,
            postId: newPostId
            ) { success in guard success else {
                    return
                }
                StorageManager.shared.downloadUrlForNewsPostHeader(email: email, postId: newPostId) {
                url in guard let headerUrl = url else {
                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrate(for: .error)
                    }
                    return
                }
        
                let currentDateTime = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .long
                let newsPost = NewsPost(
                    identifier: newPostId,
                    userEmail: email,
                    dateTime: dateFormatter.string(from: currentDateTime),
                    title: title,
                    caption: body,
                    image: headerUrl,
                    numberOfComments: 0,
                    numberOfLikes: 0)

                DatabaseManager.shared.insert(NewsPost: newsPost, email: email) { [weak self] posted in guard posted else {
                        DispatchQueue.main.async {
                            HapticsManager.shared.vibrate(for: .error)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrate(for: .success)
                        self?.didTapCancel()
                    }
                }
            }
        }
        print("Posted")
    }
}

extension addNewsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        selectedImage = image
    }
}
