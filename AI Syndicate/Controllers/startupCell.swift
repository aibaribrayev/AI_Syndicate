//
//  startupCell.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 19.09.2021.
//

import UIKit
import SDWebImage

class StartUpPostPreviewTableViewCellViewModel {
    /*let title: String
    let imageUrl: URL?*/
    var imageData: Data?
    var post:Post
    
    init(post:Post) {
        self.post = post
    }
}

class StartupCell: UITableViewCell {
    static let identifier = "startupCell"
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var investorsCountLabel: UILabel!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    var isLiked = false{
        didSet {
            likeButton.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
        }
    }
    var viewModel: StartUpPostPreviewTableViewCellViewModel?
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
    
    @IBAction func likeTapped(_ sender: Any) {
        if (isLiked) {
            DatabaseManager.shared.unlikePost(postID: viewModel!.post.identifier, postType: "Стартап")
            isLiked = false
            if let index = currentUser?.likedStartUpPostIds.firstIndex(of: viewModel!.post.identifier){
                currentUser?.likedStartUpPostIds.remove(at: index)
            }
        }
        else {
            DatabaseManager.shared.likePost(postID: viewModel!.post.identifier, postType: "Стартап")
            isLiked = true
            currentUser?.likedStartUpPostIds.append(viewModel!.post.identifier)
        }
    }
    func configure(with viewModel: StartUpPostPreviewTableViewCellViewModel, completion: @escaping  () -> Void) {
        //likeButton.layer.cornerRadius = 0.5 * likeButton.bounds.size.width
        //likeButton.backgroundColor = UIColor.white
        self.viewModel = viewModel
        if currentUser?.typeOfUser == "Стартапер" {
            //TODO: configure for startuper
            // captionLabel.isHidden = true
        }
        else if currentUser?.typeOfUser == "" {
            //TODO: configure for investor
        }
        else if currentUser?.typeOfUser == "Гость" {
            likeButton.isHidden = true
        }
        investorsCountLabel.text = String( Int(viewModel.post.numberOfInvestors ?? 0))
        isLiked = currentUser?.likedStartUpPostIds.contains(viewModel.post.identifier) ?? false
        print(viewModel.post.caption)
        self.captionLabel.text = "\(viewModel.post.title): \(viewModel.post.caption)"
        self.progressView.progress = Float(viewModel.post.investedAmount ?? 0) / Float(viewModel.post.investmentAmount ?? 1)
        self.progressLabel.text = "\(Int(progressView.progress * 100))%"

        if let data = viewModel.imageData {
            if let image = UIImage(data: data) {
                postImageView.image = image
                postImageViewHeightConstraint.constant = image.size.height / image.size.width * self.frame.size.width
            }
        }
        else {
            postImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            postImageView.sd_setImage(with: viewModel.post.image) { [weak self] image, errir, imageCacheType, url in
                guard let image = image else { return }
                self?.postImageViewHeightConstraint.constant = image.size.height / image.size.width * (self?.frame.size.width ?? image.size.width)
                self?.setNeedsLayout()
                completion()
            }
        }
    }
}
