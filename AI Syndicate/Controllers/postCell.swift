//
//  postCell.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 07.09.2021.
//

import Foundation
import FirebaseAuth
import SDWebImage

class PostPreviewTableViewCellViewModel {
    /*let title: String
    let imageUrl: URL?*/
    var imageData: Data?
    var newsPost:NewsPost
    
    init(newsPost:NewsPost) {
        self.newsPost = newsPost
    }
}

class postCell:UITableViewCell{
    static let identifier = "postCell"
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postsStatsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    var isLiked = false {
        didSet {
            likeButton.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        }
    }
    var viewModel: PostPreviewTableViewCellViewModel?
    
    @IBAction func likeTapped(_ sender: Any) {
        if(isLiked){
            isLiked = false
            DatabaseManager.shared.unlikePost(postID: viewModel!.newsPost.identifier, postType: "Новость")
            viewModel?.newsPost.numberOfLikes = (viewModel?.newsPost.numberOfLikes ?? 0) - 1
            //currentUser?.likedStartUpPostIds.
        }
        else{
            isLiked = true
            DatabaseManager.shared.likePost(postID: viewModel!.newsPost.identifier, postType: "Новость")
            viewModel?.newsPost.numberOfLikes = (viewModel?.newsPost.numberOfLikes ?? 0) + 1
            currentUser?.likedNewsPostIds.append((viewModel?.newsPost.identifier)!)
        }
        DatabaseManager.shared.update(newsPost: viewModel!.newsPost, amount: viewModel?.newsPost.numberOfLikes ?? 0)
        //DatabaseManager.shared.update(newsPost: viewModel!.newsPost, data: ["numberOfLikes": viewModel?.newsPost.numberOfLikes ?? 0])
        likeButton.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        updatePostStatsLabel()
    }
    
    func updatePostStatsLabel() {
        postsStatsLabel.text = "\(viewModel?.newsPost.numberOfLikes ?? 0) Likes     \(viewModel?.newsPost.numberOfComments ?? 0) Comments"
    }
    
    func configure(with viewModel: PostPreviewTableViewCellViewModel, completion: @escaping  () -> Void) {
        self.viewModel = viewModel
        if currentUser?.typeOfUser == "Стартапер" {
            //TODO: configure for startuper
            // captionLabel.isHidden = true
        }
        else if currentUser?.typeOfUser == "" {
            //TODO: configure for investor
        }
        else if currentUser?.typeOfUser == "Гость" {
            commentButton.isHidden = true
            likeButton.isHidden = true
        }
        
        DatabaseManager.shared.getUser(email:viewModel.newsPost.userEmail) { [weak self] user in
            guard let user = user else {
                return
            }
            self?.setUpUserInfo(name: user.username)
        }
        
        isLiked = currentUser?.likedNewsPostIds.contains(viewModel.newsPost.identifier) ?? false
        
        //print(viewModel.post.caption)
        self.titleLabel.text = viewModel.newsPost.title
        timeAgoLabel?.text = viewModel.newsPost.dateTime
        self.captionLabel?.text = viewModel.newsPost.caption
        updatePostStatsLabel()
        
        StorageManager.shared.downloadUrlForProfilePicture(email: viewModel.newsPost.userEmail) { [weak self] url in
            self?.profileImageView.sd_setImage(with: url, completed: nil)
        }
        
        if let data = viewModel.imageData {
            if let image = UIImage(data: data) {
                postImageView.image = image
                postImageViewHeightConstraint.constant = image.size.height / image.size.width * self.frame.size.width
            }
        }
        else {
            postImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            postImageView.sd_setImage(with: viewModel.newsPost.image) { [weak self] image, errir, imageCacheType, url in
                guard let image = image else { return }
                self?.postImageViewHeightConstraint.constant = image.size.height / image.size.width * (self?.frame.size.width ?? image.size.width)
                self?.setNeedsLayout()
                completion()
            }
        }
    }
    
    private func setUpUserInfo(name: String? = nil){
        usernameLabel?.text = name
    }
}
