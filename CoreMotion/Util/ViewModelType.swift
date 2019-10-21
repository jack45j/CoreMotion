//
//  ViewModelType.swift
//  CurDr
//
//  Created by 林翌埕 on 2019/4/8.
//  Copyright © 2019 tw.com.CURDr.Patient. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype Dependencies
    
    func transform(input: Input) -> Output
}
