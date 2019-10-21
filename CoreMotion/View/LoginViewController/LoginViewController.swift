//
//  LoginViewController.swift
//  CoreMotionProject
//
//  Created by Yi-Cheng Lin on 2019/10/17.
//  Copyright © 2019 Yi-Cheng Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
    
    let viewModel: LoginViewControllerViewModel!
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    required init?(coder: NSCoder) {
        self.viewModel = LoginViewControllerViewModel(dependencies: LoginViewControllerViewModel.Dependencies())
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        loginTextField.resignFirstResponder()
    }
    
    func bindViewModel() {
        let viewModelInput = LoginViewControllerViewModel.Input(loginTextFieldValue: loginTextField.rx.controlEvent(.editingDidEnd).flatMap { self.loginTextField.rx.text.asObservable() })
        let viewModelOutput = viewModel.transform(input: viewModelInput)
        
        
        _ = viewModelOutput.validatedUsername
            .do(onNext: { enable in
                if enable {
                    self.loginButton.tintColor = UIColor.systemGreen
                } else {
                    self.loginButton.tintColor = UIColor.lightGray
                }
            })
            .drive(loginButton.rx.isEnabled)
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    
}
