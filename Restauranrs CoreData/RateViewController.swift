//
//  RateViewController.swift
//  Restaraunts
//
//  Created by Семен Осипов on 10.11.16.
//  Copyright © 2016 Семен Осипов. All rights reserved.
//

import UIKit

class RateViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var stack: UIStackView!
    var rating: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scaleTransform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        let moveTransform = CGAffineTransform(translationX: 27.0, y: -600.0)
        stack.transform = scaleTransform.concatenating(moveTransform)
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImage.addSubview(blurEffectView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.stack.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @IBAction func rateSelect(sender: UIButton) {
        switch sender.tag {
        case 1: rating = "dislike"
        case 2: rating = "good"
        case 3: rating = "great"
        default:
            break
        }
        performSegue(withIdentifier: "unwindToDetail", sender: sender)
    }
}
