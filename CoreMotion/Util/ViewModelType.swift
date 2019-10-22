//
//  ViewModelType.swift
//  CurDr
//
//  Created by 林翌埕 on 2019/4/8.
//  Copyright © 2019 tw.com.CURDr.Patient. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import DLRadioButton

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype Dependencies
    
    func transform(input: Input) -> Output
}

extension Reactive where Base: UILabel {
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { view, color in
            view.textColor = color
        }
    }
}

extension DLRadioButton {
    override open var intrinsicContentSize: CGSize {
        get {
             return titleLabel?.intrinsicContentSize ?? CGSize.zero
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        super.layoutSubviews()
    }
}
