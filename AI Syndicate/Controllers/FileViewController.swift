//
//  FileViewController.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 22.09.2021.
//

import UIKit
import WebKit

class FileViewController: UIViewController, WKNavigationDelegate {

    var task: URLSessionDataTask?
    var fileUrl: URL? {
        didSet {
            if let task = task {
                task.cancel()
            }
            if let url = fileUrl {
                task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async { [weak self] in
                            self?.webView.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: url.deletingLastPathComponent())
                        }
                    }
                    else {
                        print(error)
                    }
                }
                task?.resume()
            }
        }
    }
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView.navigationDelegate = self
        activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
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
