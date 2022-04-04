//
//  commentsViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 23.09.2021.
//

import UIKit

class commentsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        dismiss(animated: true, completion: nil)
    }
    

}
