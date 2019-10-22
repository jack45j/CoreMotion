//
//  ResultViewController.swift
//  CoreMotionProject
//
//  Created by Yi-Cheng Lin on 2019/10/22.
//  Copyright © 2019 Yi-Cheng Lin. All rights reserved.
//

import UIKit
import SnapKit

class ResultViewController: UIViewController {
    
    var answered = 0
    var correct = 0
    var incorrect = 0
    var startArticle = 0
    var endArticle = 0
    
    lazy var containerView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.systemBackground
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { (constraints) in
            constraints.left.equalTo(64)
            constraints.right.equalTo(-64)
            constraints.center.equalTo(view.snp.center)
        }
        
        let UserNameLabel = UILabel()
        UserNameLabel.text = "\(UserDefaults.standard.string(forKey: "UserName") ?? "我是誰")"
        UserNameLabel.font = UIFont.systemFont(ofSize: 32)
        UserNameLabel.textColor = UserDefaults.standard.colorForKey(key: "SubColor")
        UserNameLabel.textAlignment = .center
        containerView.addArrangedSubview(UserNameLabel)
        UserNameLabel.snp.makeConstraints { (constraints) in
            constraints.left.right.equalTo(0)
            constraints.height.equalTo(64)
        }
        
        let DescLabel = UILabel()
        DescLabel.text = "從第 \(self.startArticle) 篇到第 \(self.endArticle) 篇"
        DescLabel.font = UIFont.systemFont(ofSize: 28)
        DescLabel.textColor = UserDefaults.standard.colorForKey(key: "SubColor")
        DescLabel.textAlignment = .center
        containerView.addArrangedSubview(DescLabel)
        DescLabel.snp.makeConstraints { (constraints) in
            constraints.left.right.equalTo(0)
            constraints.height.equalTo(64)
        }
        
        let AnsweredLabel = UILabel()
        AnsweredLabel.text = "共讀 \(self.answered) 篇文章"
        AnsweredLabel.font = UIFont.systemFont(ofSize: 28)
        AnsweredLabel.textColor = UserDefaults.standard.colorForKey(key: "SubColor")
        AnsweredLabel.textAlignment = .center
        containerView.addArrangedSubview(AnsweredLabel)
        AnsweredLabel.snp.makeConstraints { (constraints) in
            constraints.left.right.equalTo(0)
            constraints.height.equalTo(64)
        }
        
        let CorrectLabel = UILabel()
        CorrectLabel.text = "答對 \(self.correct) 題"
        CorrectLabel.font = UIFont.systemFont(ofSize: 28)
        CorrectLabel.textColor = UserDefaults.standard.colorForKey(key: "SubColor")
        CorrectLabel.textAlignment = .center
        containerView.addArrangedSubview(CorrectLabel)
        CorrectLabel.snp.makeConstraints { (constraints) in
            constraints.left.right.equalTo(0)
            constraints.height.equalTo(64)
        }
        
//        let IncorrectLabel = UILabel()
//        IncorrectLabel.text = "答錯：\(self.incorrect)"
//        IncorrectLabel.font = UIFont.systemFont(ofSize: 28)
//        IncorrectLabel.textColor = .systemGreen
//        IncorrectLabel.textAlignment = .center
//        containerView.addArrangedSubview(IncorrectLabel)
//        IncorrectLabel.snp.makeConstraints { (constraints) in
//            constraints.left.right.equalTo(0)
//            constraints.height.equalTo(64)
//        }
    }
    
    init(StartArticle: Int, EndArticle: Int, Answered: Int, Correct: Int, Incorrect: Int) {
        super.init(nibName: nil, bundle: nil)
        self.answered = Answered
        self.correct = Correct
        self.incorrect = Incorrect
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
}
