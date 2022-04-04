//
//  newSUViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 30.08.2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UniformTypeIdentifiers

class newSUViewController: UIViewController, UITextViewDelegate {
    //let currentEmail = Auth.auth().currentUser?.email
    //var user = User(username: "",email: "",typeOfUser: "", profileImage: "")
    @IBOutlet var activityIndView: UIActivityIndicatorView!
    private var selectedImage: UIImage?
    private var selectedVideo:URL?
    private var selectedDocument: URL?
    //private var selectedVideo:
    @IBOutlet var titleField: UITextField!
    @IBOutlet var financingField: UITextField!
    @IBOutlet var incorrectInputLabel: UILabel!
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndView.isHidden = true
        textView.layer.cornerRadius = 10
        titleField.font = UIFont(name: "verdana", size: 18.0)
        textView.textColor = UIColor.lightGray
        textView.font = UIFont(name: "verdana", size: 17.0)
        textView.returnKeyType = .done
        textView.delegate = self
        // Do any additional setup after loading the view.
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Описание проекта" {
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
            textView.text = "Описание проекта"
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "system", size: 16.0)
        }
        else{
            textView.font = UIFont(name: "system", size: 16.0)
        }
    }

    @IBAction func addImageTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.restorationIdentifier = "image"
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func addFileTapped(_ sender: Any) {
        
        if #available(iOS 14.0, *) {
            let types = UTType.types(tag: "pdf", tagClass: .filenameExtension, conformingTo: nil)
            let pickerVC = UIDocumentPickerViewController(forOpeningContentTypes: types)
            pickerVC.delegate = self
            self.present(pickerVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "", message: "Требуется версия iOS 14 и новее", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func addVideoTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.restorationIdentifier = "video"
        picker.sourceType = .photoLibrary
        //UIImagePickerController.availableMediaTypes(for: .camera)
        picker.mediaTypes = ["public.movie"]
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addStartUpTapped(_ sender: Any) {
        var sum = Int(financingField.text!)
        if(sum == nil && sum ?? 0 < 1){
            incorrectInputLabel.isHidden = false
            return
        }
        guard let body = textView.text,
        let title = titleField.text,
        let headerImage = selectedImage,
        let email = Auth.auth().currentUser?.email,
        !title.trimmingCharacters(in: .whitespaces).isEmpty,
        !body.trimmingCharacters(in: .whitespaces).isEmpty else {

        /*let alert = UIAlertController(title: "Enter Post Details",
                                        message: "Please enter a title, body, and select a image to continue.",
                                          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                present(alert, animated: true)*/
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
        if let video = selectedVideo {
            StorageManager.shared.uploadVideo(email: email, videoURL: video, postId: newPostId){ success in guard success else {
                return
                }
            }
        }
        if let doc = selectedDocument{
            StorageManager.shared.uploadPDFFile(email: email, pdfFile: doc, postId: newPostId){ success in guard success else {
                return
                }
            }
        }
        StorageManager.shared.uploadBlogHeaderImage(
            email: email,
            image: headerImage,
            postId: newPostId
            ) { success in guard success else {
                    return
                }
                StorageManager.shared.downloadUrlForPostHeader(email: email, postId: newPostId) {
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
                let post = Post(
                    identifier: newPostId,
                    userEmail: email,
                    dateTime: dateFormatter.string(from: currentDateTime),
                    title: title,
                    caption: body,
                    image: headerUrl,
                    investmentAmount: sum,
                    numberOfComments: 0,
                    numberOfLikes: 0,
                    numberOfInvestors: 0,
                    investedAmount: 0)

                DatabaseManager.shared.insert(Post: post, email: email) { [weak self] posted in guard posted else {
                        DispatchQueue.main.async {
                            HapticsManager.shared.vibrate(for: .error)
                        }
                        print("Ошибочка")
                        return
                    }
                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrate(for: .success)
                        print("Вроде все")
                        self?.didTapCancel()
                    }
                }
            }
        }
        print("Posted")
    }
}

extension newSUViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        /*if let mediaType = info[.mediaType] as? String,
           mediaType == "public.video",
           let url = info[.mediaURL] as? URL {
            //TODO: load to firebase
            selectedVideo = url
            print(url)
        }*/
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            selectedVideo = videoURL
            print(videoURL)
        }
        else if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }
    }
}
extension newSUViewController: UIDocumentPickerDelegate{
    /*public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard controller.documentPickerMode == .open, let url = url, url.startAccessingSecurityScopedResource() else { return }
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
             }
    selectedDocument = url
        //Need to make a new image with the jpeg data to be able to close the security resources!
        //guard let image = UIImage(contentsOfFile: url.path), let imageCopy = //UIImage(data: image.jpegData(compressionQuality: 1.0)!) else { return }
        //self.delegate?.didSelect(image: imageCopy)
        controller.dismiss(animated: true)
    }*/
    /*public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {
        guard controller.documentPickerMode == .import, let url = urls.first,
            let doc = UIDocument(fileURL: url) else { return }
        selectedDocument = doc
        controller.dismiss(animated: true)
    }
        */
    
    
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        var error: NSError? = nil
        NSFileCoordinator().coordinate(
            readingItemAt: url,
            error: &error) { url in
            guard url.startAccessingSecurityScopedResource()
            else { return }
            //Using defer to always execute this line at the end.
            defer { url.stopAccessingSecurityScopedResource() }
            selectedDocument = url
            print("selected document\(url)")
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
    }
}
