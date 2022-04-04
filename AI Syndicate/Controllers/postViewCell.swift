//
//  postViewCell.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 07.09.2021.
//

import UIKit
import FirebaseAuth

class PostTableViewCellViewModel {
    /*let title: String
    let imageUrl: URL?*/
    var imageData: Data?
    let post:Post
    
    init(post:Post) {
        self.post = post
    }
}
class postViewCell: UITableViewCell {
    static let identifier = "postViewCell"
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postsStatsLabel: UILabel!
    @IBOutlet weak var investButton: UIButton!
    
    func configure(with viewModel: PostTableViewCellViewModel) {
        //postTitleLabel.text = viewModel.title
        DatabaseManager.shared.getUser(email:viewModel.post.userEmail) { [weak self] user in
            guard let user = user else {
                return
            }
            self?.setUpUserInfo(name: user.username)
        }
        timeAgoLabel.text = viewModel.post.dateTime
        captionLabel.text = viewModel.post.caption
        postsStatsLabel.text = "\(viewModel.post.numberOfLikes!) Likes     \(viewModel.post.numberOfComments!) Comments     \(viewModel.post.numberOfInvestors!) Investors"
        if let data = viewModel.imageData {
            postImageView.image = UIImage(data: data)
        }
        else if let url = viewModel.post.image {
            // Fetch image & cache
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else {
                    return
                }

                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.postImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
    private func setUpUserInfo(name: String? = nil){
        usernameLabel.text = name
    }
}
