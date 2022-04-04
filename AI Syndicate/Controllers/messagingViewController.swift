//
//  messagingViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 07.09.2021.
//

import UIKit

class messagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var posts: [Post] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(messagingTableViewCell.self, forCellReuseIdentifier: messagingTableViewCell.identifier)
        fetchAllPosts()
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
    }
    private func fetchAllPosts() {
        print("Fetching home feed...")

        DatabaseManager.shared.getAllPosts { [weak self] posts in
            self?.posts = posts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: messagingTableViewCell.identifier, for: indexPath) as? messagingTableViewCell else {
            fatalError()
        }
        
        //cell.titleLabel?.text = post.title
        //cell.textLabel?.text = post.title
        
        return cell
    }
}
