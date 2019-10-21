//
//  SettingsViewController.swift
//  CoreMotionProject
//
//  Created by Yi-Cheng Lin on 2019/10/20.
//  Copyright © 2019 Yi-Cheng Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewController: UIViewController {
    @IBOutlet weak var circleColorLabel: UILabel!
    @IBOutlet weak var redColorSlider: UISlider!
    @IBOutlet weak var greenColorSlider: UISlider!
    @IBOutlet weak var blueColorSlider: UISlider!
    @IBOutlet weak var alphaColorSlider: UISlider!
    
    let userDefault = UserDefaults.standard
    let defaultUDValue: [String : Any] =
    ["CircleColorR": 0,
     "CircleColorG": 0,
     "CircleColorB": 0,
     "CircleColorA": 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redColorSlider.value = userDefault.float(forKey: "CircleColorR")
        greenColorSlider.value = userDefault.float(forKey: "CircleColorG")
        blueColorSlider.value = userDefault.float(forKey: "CircleColorB")
        alphaColorSlider.value = userDefault.float(forKey: "CircleColorA")
        
        let red = redColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorR") })
            .share()
        
        let green = greenColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorG") })
            .share()
        
        let blue = blueColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorB") })
            .share()
        
        let alpha = alphaColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorA") })
            .share()
        
        let _ = Observable.combineLatest(red, green, blue, alpha) {
            return UIColor(red: $0/225, green: $1/225, blue: $2/225, alpha: $3)
        }
        .asObservable()
        .do(onNext: { self.userDefault.setColor(color: $0, forKey: "CircleColor") })
        .bind(to: circleColorLabel.rx.backgroundColor)
        
    }
}
