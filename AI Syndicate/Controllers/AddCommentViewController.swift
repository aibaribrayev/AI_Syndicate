//
//  AddCommentViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 21.09.2021.
//

import UIKit

protocol AddCommentViewControllerDelegate {
    func sendMessage(_ text: String, parent: Comment?)
}

class AddCommentViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var delegate: AddCommentViewControllerDelegate?
    var parentComment: Comment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
    }
    
    @IBAction func cancelButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTap(_ sender: Any) {
        delegate?.sendMessage(textView.text, parent: parentComment)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
