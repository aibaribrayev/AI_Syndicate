//
//  CommentCell.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 21.09.2021.
//

import UIKit
import SDWebImage

struct CommentCellData {
    let comment: Comment
    let level: Int
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var indentationConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var postedTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.avatarImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
    }

    func configure(data: CommentCellData) {
        avatarImageView.image = nil
        DatabaseManager.shared.getUser(email: data.comment.userEmail) { [weak self] user in
            if let user = user {
                self?.authorLabel.text = user.username
                StorageManager.shared.downloadUrlForProfilePicture(email: user.email) { [weak self] url in
                    if let url = url{
                        self?.avatarImageView.sd_setImage(with: url, completed: nil)
                    }
                }
            }
        }
        if(avatarImageView.image == nil){
            self.avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
        self.postedTimeLabel.text = data.comment.dateTime
        self.messageLabel.text = data.comment.text
        //self.indentationConstraint.constant = CGFloat(8 * (data.level + 1))
        self.indentationLevel = data.level
        setNeedsLayout()
    }
}
