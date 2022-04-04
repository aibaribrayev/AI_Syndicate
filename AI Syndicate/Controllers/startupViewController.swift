//
//  StartupViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 20.09.2021.
//

import UIKit
import AVKit

class StartupViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var post: Post?
    var videoVC: AVPlayerViewController?
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var investButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var postStatsLabel: UILabel!
    @IBOutlet weak var numOfInvestorsLabel: UILabel!
    @IBOutlet weak var commentsAmountLabel: UILabel!
    var isLiked = false{
        didSet {
            likeButton.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postStatsLabel.text = "\(Int((post?.investedAmount ?? 0)))\nиз \(Int(post?.investmentAmount ?? 1))"
        numOfInvestorsLabel.text = "\(Int(post?.numberOfInvestors ?? 0))\nИнвесторов"
        isLiked = currentUser?.likedStartUpPostIds.contains(post!.identifier) ?? false
        if(currentUser?.typeOfUser == "Стартапер" || currentUser?.typeOfUser == "Гость"){
            investButton.isHidden = true
        }
        DatabaseManager.shared.getUser(email: post!.userEmail){ [weak self] user in
            guard let user = user else {
                return
            }
            self?.setUpUserInfo(name: user.username, email: user.email)
        }
        titleLabel.text = post?.title
        captionTextView.text = post?.caption
        progressView.progress = Float(post?.investedAmount ?? 0) / Float(post?.investmentAmount ?? 1)
        StorageManager.shared.downloadUrlForProfilePicture(email: post!.userEmail){[weak self] url in
            if let url = url {
            self?.userImage.sd_setImage(with: url, completed: nil)
            }
        }
        StorageManager.shared.downloadUrlForVideo(email: post!.userEmail, postId: post!.identifier){[weak self] url in
            if let url = url {
                let player = AVPlayer(url: url)
                self!.videoVC?.player = player
                player.play()
            }
        }
        // Do any additional setup after loading the view.
        /*if let post = post {
            let postUrlString =    "https://firebasestorage.googleapis.com/v0/b/ai-syndicate-b562a.appspot.com/o/post_headers%2Fadelya_icloud_com%2F0AED45CF-97BD-4AA4-8F5A-21C665E47A50.mov?alt=media&token=65e7557d-a682-4618-9da7-fa78c6ecd219"

            
            if let url = URL(string: postUrlString) {
                let player = AVPlayer(url: url)
                videoVC?.player = player
                player.play()
            }
        }*/
    }
    
    
    @IBAction func likeTapped(_ sender: Any) {
        if (isLiked) {
            DatabaseManager.shared.unlikePost(postID: post!.identifier, postType: "Стартап")
            isLiked = false
            if let index = currentUser?.likedStartUpPostIds.firstIndex(of: post!.identifier){
                currentUser?.likedStartUpPostIds.remove(at: index)
            }
        }
        else {
            DatabaseManager.shared.likePost(postID: post!.identifier, postType: "Стартап")
            isLiked = true
            currentUser?.likedStartUpPostIds.append(post!.identifier)
        }
    }
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private func setUpUserInfo(name: String? = nil, email: String){
        guard let name = name else { return }
        userNameLabel.text = "От  \(name)"
        StorageManager.shared.downloadUrlForProfilePicture(email: email) {[weak self] url in
            self?.userImage.sd_setImage(with: url, completed: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showComments",
           let vc = segue.destination as? CommentsTableViewController {
            vc.startupPost = post
        }
        else if segue.identifier == "showFile",
                let vc = segue.destination as? FileViewController {
        StorageManager.shared.downloadURLForPDFFile(email: post!.userEmail, postId: post!.identifier){[weak self] url in
                if let url = url {
                    vc.fileUrl = url
                }
            }
            //vc.fileUrl = post
            //DatabaseManager.shared.
        }
        else if segue.identifier == "showInvest",
                let vc = segue.destination as? investViewController {
            vc.post = post
        }
        else if let vc = segue.destination as? AVPlayerViewController {
            videoVC = vc
        }
    }

}
