//
//  MyInvestTableViewCell.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 27.09.2021.
//

import UIKit
import SDWebImage

class MyInvestTableViewCell: UITableViewCell {

    var imageData: Data?
    @IBOutlet weak var investLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var investImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        investImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
    }
    
    func configure(post:Post) {
        self.nameLabel.text = post.title
        if let data = imageData {
            if let image = UIImage(data: data) {
                investImageView.image = image
            }
        }
        else {
            investImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            investImageView.sd_setImage(with: post.image) { [weak self] image, errir, imageCacheType, url in
                guard let image = image else { return }
                self?.setNeedsLayout()
                //completion()
            }
        }
        //self.investImageView.sd_setImage(with: nil, completed: nil)
        // TODO: get post by ID and set view
    }
}
