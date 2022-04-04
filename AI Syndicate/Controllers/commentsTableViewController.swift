//
//  CommentsTableViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 21.09.2021.
//

import UIKit

class CommentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var post: DataPost?
    public var startupPost: Post? {
        didSet {
            if let newPost = startupPost {
                post = DataPost(startupPost: newPost)
                newsPost = nil
            }
        }
    }
    public var newsPost: NewsPost? {
        didSet {
            if let newPost = newsPost {
                post = DataPost(newsPost: newPost)
                startupPost = nil
            }
        }
    }
    
    var comments: [Comment] = []
    var replies: [Comment] = []
    var data: [CommentCellData] = []
    var selectedComment: Comment?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var isLoadingComments = false
    var isLoadingReplies = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //refreshControl?.beginRefreshing()
        refresh(self)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .long
        var parent:Comment? = nil
        if let text = textField.text,
           text.count > 0,
           let email = currentUser?.email {
            textField.isEnabled = false
            //refreshControl?.beginRefreshing()
            let comment = Comment()
            comment.identifier = UUID().uuidString
            comment.userEmail = email
            comment.text = text
            comment.parentComment = parent
            comment.dateTime = dateFormatter.string(from: currentDateTime)
            // comment.dateTime = ""
            if let post = post {
                DatabaseManager.shared.addComment(post: post, comment: comment) {[weak self] comment in
                    self?.refresh(comment)
                    self?.textField.text = ""
                    self?.textField.isEnabled = true
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if bottomConstraint.constant == 0 {
                bottomConstraint.constant = keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if bottomConstraint.constant != 0 {
            bottomConstraint.constant = 0
        }
    }
    
    func appendComments(_ comment: Comment, level: Int) {
        data.append(CommentCellData(comment: comment, level: level))
        if let replies = comment.replies {
            for reply in replies {
                appendComments(reply, level: level + 1)
            }
        }
    }
    
    func endRefresh() {
        if !isLoadingComments && !isLoadingReplies {
            for reply in replies {
                if let parentId = reply.parentComment?.identifier,
                   let comment = comments.first(where: { $0.identifier == parentId }) {
                    comment.replies?.append(reply)
                }
            }
            data = []
            for comment in comments {
                appendComments(comment, level: 0)
            }
            
            //self.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        guard let post = post else { return }
        isLoadingReplies = true
        isLoadingComments = true
        DatabaseManager.shared.getComments(for: post) { [weak self] comments in
            self?.comments = comments
            self?.isLoadingComments = false
            self?.endRefresh()
        }
        DatabaseManager.shared.getReplies(for: post) { [weak self] replies in
            self?.replies = replies
            self?.isLoadingReplies = false
            self?.endRefresh()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMessage(self)
        return false
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentCell
        cell.configure(data: data[indexPath.row])
        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedComment = data[indexPath.row].comment
        performSegue(withIdentifier: "addComment", sender: nil)
    }
     */
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addComment",
           let vc = segue.destination as? AddCommentViewController {
            vc.delegate = self
            if let comment = selectedComment {
                vc.parentComment = comment
            }
        }
    }
     */
}
