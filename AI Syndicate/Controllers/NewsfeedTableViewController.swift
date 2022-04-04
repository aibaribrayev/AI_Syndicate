//
//  NewsfeedTableViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 28.08.2021.
//

import UIKit

class NewsfeedTableViewController: UITableViewController {
    //var posts: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.register(postViewCell.self, forCellReuseIdentifier: postViewCell.identifier)
        //fetchAllPosts()
    }
    private func fetchAllPosts() {
        print("Fetching home feed...")

 //       DatabaseManager.shared.getAllPosts { [weak self] posts in
   //         self?.posts = posts
     //       DispatchQueue.main.async {
         //       self?.tableView.reloadData()
       //     }
        //}
    }
    
}

/*
extension NewsfeedTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: postViewCell.identifier, for: indexPath) as? postViewCell else {
            fatalError()
        }
        post.getPost()
        cell.configure(with: .init(post: post))
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}*/
