//
//  MainViewController.swift
//  CoreMotionProject
//
//  Created by Yi-Cheng Lin on 2019/10/18.
//  Copyright © 2019 Yi-Cheng Lin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startButton.layer.borderColor = UIColor.systemGreen.cgColor
        startButton.layer.borderWidth = 3
    }
}
