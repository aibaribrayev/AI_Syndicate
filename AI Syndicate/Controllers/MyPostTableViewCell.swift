//
//  MyPostTableViewCell.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 27.09.2021.
//

import UIKit
import SDWebImage

class MyPostTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
    }
    
    private func configure(postID: String?, postType: String) {
        self.nameLabel.text = postID
        self.postImageView.sd_setImage(with: nil, completed: nil)
        // TODO: get post by ID and set view
    }
    
    func configure(newsPost postID: String?) {
        self.configure(postID: postID, postType: "news")
    }
    
    func configure(startupPost postID: String?) {
        self.configure(postID: postID, postType: "posts")
    }

}
