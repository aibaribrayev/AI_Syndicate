//
//  newsTableViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 07.09.2021.
//

import UIKit

enum ContentType {
    case news, startups, myStartups, likedStartups, likedNews
}

class newsTableViewController: UITableViewController {
    var newsPosts:[NewsPost] = []
    var posts: [Post] = []
    var currentContent = ContentType.startups
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchButton.isHidden = currentContent != .news && currentContent != .startups
        self.switchList(to: currentContent)
        if (switchButton.isHidden) {
            exitButton.setTitle("Назад", for: .normal)
        }
        else {
            exitButton.setTitleColor(.systemRed, for: .normal)
            if currentUser?.typeOfUser != "Гость" {
                exitButton.isHidden = true
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        if (switchButton.isHidden) {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.refreshControl?.beginRefreshing()
        switch currentContent {
        case .news:
            fetchAllNewsPosts()
            break
        case .startups:
            fetchAllStartUpPosts()
            break
        case .myStartups:
            fetchMyStartups()
            break
        case .likedStartups:
            fetchLikedStartups()
            break
        case .likedNews:
            fetchLikedNews()
            break
        }
    }
    
    @IBAction func switchButtonTap(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Новости", style: .default, handler: { [weak self] action in
            self?.switchList(to: .news)
        }))
        alertController.addAction(UIAlertAction(title: "Стартапы", style: .default, handler: { [weak self] action in
            self?.switchList(to: .startups)
        }))
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func switchList(to: ContentType) {
        currentContent = to
        switch to {
        case .news:
            self.switchButton.setTitle("Новости", for: .normal)
            break
        case .startups:
            self.switchButton.setTitle("Стартапы", for: .normal)
            break
        default:
            break
        }
        refresh(self)
    }
    
    private func fetchAllStartUpPosts() {
        print("Fetching home feed...")

        DatabaseManager.shared.getAllPosts { [weak self] posts in
            self?.posts = posts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    private func fetchAllNewsPosts() {
        print("Fetching home feed...")

        DatabaseManager.shared.getAllNewsPosts { [weak self] newsPosts in
            self?.newsPosts = newsPosts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    private func fetchMyStartups() {
        if(currentUser?.typeOfUser=="Инвестор"){
            DatabaseManager.shared.getInvestedPosts() { [weak self] posts in
                self?.posts = posts
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
            }
        }
        else if(currentUser?.typeOfUser=="Стартапер"){
            DatabaseManager.shared.getPosts(for: currentUser!.email){[weak self] posts in
                self?.posts = posts
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
                
            }
        }
    }
    private func fetchLikedStartups() {
        DatabaseManager.shared.getLikedStartUpPosts(){[weak self] posts in
            self?.posts = posts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    private func fetchLikedNews() {
        DatabaseManager.shared.getLikedNewsPosts(){[weak self] newsPosts in
                self?.newsPosts = newsPosts
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentContent {
        case .news, .likedNews:
            return newsPosts.count
        default:
            return posts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentContent == .news || currentContent == .likedNews {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: postCell.identifier, for: indexPath) as? postCell else { fatalError() }
            
            let newsPost = newsPosts[indexPath.row]
            cell.configure(with: .init(newsPost: newsPost)) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.captionLabel?.text = newsPost.caption
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StartupCell.identifier, for: indexPath) as? StartupCell else { fatalError() }
            
            let post = posts[indexPath.row]
            cell.configure(with: .init(post: post)) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startupDetails",
           let vc = segue.destination as? StartupViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            vc.post = posts[indexPath.row]
        }
        else if segue.identifier == "showNewsComments",
                let vc = segue.destination as? CommentsTableViewController,
                let button = sender as? UIButton,
                let view = button.superview as? UIView,
                let view = view.superview as? UIView,
                let cell = view.superview as? postCell,
                let indexPath = tableView.indexPath(for: cell) {
            let newsPost = self.newsPosts[indexPath.row]
            vc.newsPost = newsPost
        }
    }
}
