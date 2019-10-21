//
//  LoginViewControllerViewModel.swift
//  CoreMotionProject
//
//  Created by Yi-Cheng Lin on 2019/10/18.
//  Copyright © 2019 Yi-Cheng Lin. All rights reserved.
//

import RxSwift
import RxCocoa

class LoginViewControllerViewModel: ViewModelType {
    
    struct Dependencies {
        
    }
    
    struct Input {
        let loginTextFieldValue: Observable<String?>
    }
    
    struct Output {
        let validatedUsername: Driver<Bool>
    }
    
    init(dependencies: Dependencies) {
        
    }
    
    func transform(input: LoginViewControllerViewModel.Input) -> LoginViewControllerViewModel.Output {
        let validatedUsername = input
            .loginTextFieldValue
            .filter { $0 != nil }
            .map { return $0!.count > 2 ? true : false }
            .asDriver(onErrorJustReturn: false)
            
        
        return LoginViewControllerViewModel.Output(validatedUsername: validatedUsername)
    }
}
