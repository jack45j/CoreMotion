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
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var modeSegment: UISegmentedControl!
    @IBOutlet weak var articleSelectTxtField: UITextField!
    @IBOutlet weak var mainColorLabel: UILabel!
    @IBOutlet weak var mainColorRedSlider: UISlider!
    @IBOutlet weak var mainColorGreenSlider: UISlider!
    @IBOutlet weak var mainColorBlueSlider: UISlider!
    @IBOutlet weak var subColorLabel: UILabel!
    @IBOutlet weak var subColorRedSlider: UISlider!
    @IBOutlet weak var subColorGreenSlider: UISlider!
    @IBOutlet weak var subColorBlueSlider: UISlider!
    @IBOutlet weak var circleColorLabel: UILabel!
    @IBOutlet weak var redColorSlider: UISlider!
    @IBOutlet weak var greenColorSlider: UISlider!
    @IBOutlet weak var blueColorSlider: UISlider!
    @IBOutlet weak var alphaColorSlider: UISlider!
    @IBOutlet weak var scaleMagSegment: UISegmentedControl!
    @IBOutlet weak var circleSizeSegment: UISegmentedControl!
    
    let userDefault = UserDefaults.standard
    let defaultUDValue: [String : Any] =
        ["SelectedArticle": 0,
         "CircleColorR": 0,
         "CircleColorG": 0,
         "CircleColorB": 0,
         "CircleColorA": 0,
         "CircleScaleMag": 1,
         "CircleSize": 2,
         "MainColorR": 255,
         "MainColorG": 59,
         "MainColorB": 48,
         "SubColorR": 52,
         "SubColorG": 199,
         "SubColorB": 89]
    
    var articlesAmount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefault.register(defaults: defaultUDValue)
        
        redColorSlider.value = userDefault.float(forKey: "CircleColorR")
        greenColorSlider.value = userDefault.float(forKey: "CircleColorG")
        blueColorSlider.value = userDefault.float(forKey: "CircleColorB")
        alphaColorSlider.value = userDefault.float(forKey: "CircleColorA")
        
        mainColorRedSlider.value = userDefault.float(forKey: "MainColorR")
        mainColorGreenSlider.value = userDefault.float(forKey: "MainColorG")
        mainColorBlueSlider.value = userDefault.float(forKey: "MainColorB")
        
        subColorRedSlider.value = userDefault.float(forKey: "SubColorR")
        subColorGreenSlider.value = userDefault.float(forKey: "SubColorG")
        subColorBlueSlider.value = userDefault.float(forKey: "SubColorB")
        
        
        scaleMagSegment.selectedSegmentIndex = userDefault.integer(forKey: "CircleScaleMag")
        circleSizeSegment.selectedSegmentIndex = userDefault.integer(forKey: "CircleSize")
        modeSegment.selectedSegmentIndex = userDefault.integer(forKey: "gameMode")
        articleSelectTxtField.text = "\(userDefault.integer(forKey: "SelectedArticle")+1)"
        
        // 球體顏色
        let circleRed = redColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorR") })
        
        let circleGreen = greenColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorG") })
        
        let circleBlue = blueColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorB") })
        
        let circleAlpha = alphaColorSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "CircleColorA") })
        
        Observable.combineLatest(circleRed, circleGreen, circleBlue, circleAlpha) {
            return UIColor(red: $0/225, green: $1/225, blue: $2/225, alpha: $3)
        }
        .asObservable()
        .do(onNext: { self.userDefault.setColor(color: $0, forKey: "CircleColor") })
        .bind(to: circleColorLabel.rx.textColor)
        .disposed(by: self.disposeBag)
        
        // 主色調
        let mainRed = mainColorRedSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "MainColorR") })
        
        let mainGreen = mainColorGreenSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "MainColorG") })
        
        let mainBlue = mainColorBlueSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "MainColorB") })
            
        
        Observable.combineLatest(mainRed, mainGreen, mainBlue) {
            return UIColor(red: $0/225, green: $1/225, blue: $2/225, alpha: 1)
        }
        .asObservable()
        .do(onNext: { self.userDefault.setColor(color: $0, forKey: "MainColor") })
        .bind(to: mainColorLabel.rx.textColor)
        .disposed(by: self.disposeBag)
        
        // 副色調
        let subRed = subColorRedSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "SubColorR") })
        
        let subGreen = subColorGreenSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "SubColorG") })
        
        let subBlue = subColorBlueSlider.rx.value
            .map { CGFloat($0) }
            .do(onNext: { self.userDefault.set($0, forKey: "SubColorB") })
        
        Observable.combineLatest(subRed, subGreen, subBlue) {
            return UIColor(red: $0/225, green: $1/225, blue: $2/225, alpha: 1)
        }
        .asObservable()
        .do(onNext: { self.userDefault.setColor(color: $0, forKey: "SubColor") })
        .bind(to: subColorLabel.rx.textColor)
        .disposed(by: self.disposeBag)
        
        // 模式切換
        modeSegment.rx.value
        .do(onNext: { self.userDefault.set($0, forKey: "gameMode") })
        .filter { $0 == 0 }
        .subscribe(onNext: { _ in
            self.scaleMagSegment.selectedSegmentIndex = 0
            self.userDefault.set(0, forKey: "CircleScaleMag")
        })
        .disposed(by: self.disposeBag)
        
        // 縮放速度
        scaleMagSegment.rx.value
        .subscribe(onNext: {
            if self.modeSegment.selectedSegmentIndex == 0 {
                self.scaleMagSegment.selectedSegmentIndex = 0
                self.userDefault.set(0, forKey: "CircleScaleMag")
            }
            self.userDefault.set($0, forKey: "CircleScaleMag")
        })
        .disposed(by: self.disposeBag)
        
        // 初始球大小
        circleSizeSegment.rx.value
        .subscribe(onNext: {
            self.userDefault.set($0, forKey: "CircleSize")
        })
        .disposed(by: self.disposeBag)
        
        // 選擇第幾篇
        if let path = Bundle.main.path(forResource: "articles", ofType: "json") {
            guard
                let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                let articles = try? JSONDecoder().decode(ArticlesData.self, from: data)
            else { return }
            
            self.articlesAmount = articles.articles!.count
        }
        
        articleSelectTxtField.rx.text
        .changed
        .ifEmpty(default: "0")
        .map { Int($0!) }
        .filter { $0 != nil }
        .subscribe(onNext: {
            if $0! > self.articlesAmount {
                self.articleSelectTxtField.text = "\(self.articlesAmount)"
                self.userDefault.set(self.articlesAmount-1, forKey: "SelectedArticle")
            } else if($0! <= 0) {
                self.articleSelectTxtField.text = "1"
                self.userDefault.set(0, forKey: "SelectedArticle")
            } else {
                self.articleSelectTxtField.text = "\($0 ?? 1)"
                self.userDefault.set($0!-1, forKey: "SelectedArticle")
            }
        })
        .disposed(by: self.disposeBag)
    }
}
