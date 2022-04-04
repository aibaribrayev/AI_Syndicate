import UIKit
import FirebaseAuth

class editViewController: UIViewController {
    private var selectedProfileImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let stroyboard = UIStoryboard(name:"Main", bundle: nil)
            let vc = stroyboard.instantiateViewController(identifier: "login")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }catch{
            print(error)
        }
    }
}
