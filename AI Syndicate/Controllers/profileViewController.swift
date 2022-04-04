//
//  profileViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 31.07.2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class profileViewController: UIViewController {
    
    private var selectedProfileImage: UIImage?
    var email: String? { currentUser?.email }
    var investedPosts : [Post] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var userType: UILabel!
    @IBOutlet var addStartUpButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userName: UILabel!
    
    @IBOutlet var mystartUpsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        if let user = currentUser {
            self.setUpUserInfo(name: user.username, typeOfUser: user.typeOfUser)
        }
        DatabaseManager.shared.getInvestedPosts(){
            [weak self] posts in
            self!.investedPosts = posts
        }
        StorageManager.shared.downloadUrlForProfilePicture(email: email!) {[weak self] url in
            self?.profileImage.sd_setImage(with: url, completed: nil)
            if(url == nil){
                self?.profileImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setUpUserInfo(name: String? = nil,
                               typeOfUser: String? = nil){
        userName.text = name
        userType.text = typeOfUser
        if(typeOfUser == "Инвестор"){
            print("User is investor")
            addStartUpButton.isHidden = true
            mystartUpsButton.setTitle(" Мои инвестиции", for: .normal)
        }
        else if(typeOfUser == "Старапер"){
            mystartUpsButton.setTitle(" Мои стартапы", for: .normal)
        }
        StorageManager.shared.downloadUrlForProfilePicture(email: email!) {[weak self] url in
            self?.profileImage.sd_setImage(with: url, completed: nil)
            if(url == nil){
                self?.profileImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let stroyboard = UIStoryboard(name:"Main", bundle: nil)
            let vc = stroyboard.instantiateViewController(identifier: "login")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }catch{
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "myStartups"),
           let vc = segue.destination as? newsTableViewController {
            vc.currentContent = .myStartups
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        else if (segue.identifier == "likedStartups"),
                let vc = segue.destination as? newsTableViewController {
            vc.currentContent = .likedStartups
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        else if (segue.identifier == "likedNews"),
                let vc = segue.destination as? newsTableViewController {
            vc.currentContent = .likedNews
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

extension profileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        selectedProfileImage = image
        profileImage.image = image
        
        if let email = email {
            StorageManager.shared.uploadUserProfilePicture(email: email, image: image) { result in
                print(result)
            }
        }
    }
}

extension profileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            return investedPosts.count ?? 0
        case 1:
            return currentUser?.likedStartUpPostIds.count ?? 0
        default:
            return currentUser?.likedNewsPostIds.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            let data = investedPosts[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "myInvestCell") as! MyInvestTableViewCell
            cell.configure(post: data)
            return cell
        case 1:
            let data = currentUser?.likedStartUpPostIds[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "myPostCell") as! MyPostTableViewCell
            cell.configure(startupPost: data)
            return cell
        default:
            let data = currentUser?.likedNewsPostIds[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "myPostCell") as! MyPostTableViewCell
            cell.configure(newsPost: data)
            return cell
        }
    }
}
