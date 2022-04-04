//
//  investViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 23.09.2021.
//

import UIKit

class investViewController: UIViewController {
    var post:Post?
    var requireAmount:Int = 0
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var investAmountField: UITextField!
    @IBOutlet weak var incorrectInputLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        requireAmount = Int(post?.investmentAmount ?? 0) - Int(post?.investedAmount ?? 0)
        slider.minimumValue = 0
        slider.maximumValue = Float(requireAmount)
        // Do any additional setup after loading the view.
    }
    @IBAction func confirmTapped(_ sender: Any) {
        let sum = Int(investAmountField.text!)
        if(sum == nil && sum ?? 0 < 1){
            incorrectInputLabel.isHidden = false
            return
        }
        DatabaseManager.shared.updateInvest(post: post!, amount: sum!)
        currentUser?.investedStartUps.append(post!.identifier)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sliderSlide(_ sender: Any) {
        investAmountField.text = "\(Int(slider.value))"
    }
}
