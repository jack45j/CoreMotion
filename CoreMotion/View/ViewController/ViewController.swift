//
//  ViewController.swift
//  CoreMotion
//
//  Created by Yi-Cheng Lin on 2019/10/12.
//  Copyright © 2019 Yi-Cheng Lin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation
import RxCoreLocation
import CoreMotion
import RxCoreMotion
import DLRadioButton

class ViewController: UIViewController {
    
    // Configure Values
    var SelectedArticle = PublishSubject<Int>()
    var currentArticle = 0
    let defaultUDValue: [String : Any] =
        ["SelectedArticle": 0,
         "CircleScaleMag": 1,
         "CircleSize": 2]
    //---------
    
    let disposeBag = DisposeBag()
    
    var articles: ArticlesData?
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var questLabel: UILabel!
    @IBOutlet weak var firstOptionButton: DLRadioButton!
    @IBOutlet weak var secondOptionButton: DLRadioButton!
    @IBOutlet weak var thirdOptionButton: DLRadioButton!
    @IBOutlet weak var fourthOptionButton: DLRadioButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var endAnswerButton: UIButton!
    let UpContainerView = UIView()
    let ContainerView = UIView()
    var upCircles: [UIView]?
    var bottomCircles: [UIView]?
    
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let userDefaults = UserDefaults.standard
    let coreMotionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    
    // 設定
    var comporasion = 0.00
    let circleSpace = 60.0
    var currentHeading: Double = 0.0
    var scaleMag: CGFloat = 2.0
    var circleSize: CGFloat = 1.0
    var mainColor = UIColor.systemRed
    var subColor = UIColor.systemGreen
    
    // 答題紀錄
    var answeredQuestions = [Int: Bool]()
    var startArticles = 0
    var currentSelectedOption = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults.register(defaults: defaultUDValue)
        
        locationManager.requestWhenInUseAuthorization()
        coreMotionManager.accelerometerUpdateInterval = 0.5
        
        // get UserDefaults data
        let scaleMagIndex = Int(userDefaults.float(forKey: "CircleScaleMag"))
        switch scaleMagIndex {
        case 0:
            self.scaleMag = 0
        case 1:
            self.scaleMag = 2
        case 2:
            self.scaleMag = 3
        case 3:
            self.scaleMag = 5
        case 4:
            self.scaleMag = 8
        default:
            self.scaleMag = 2
        }
        self.circleSize = (CGFloat(userDefaults.integer(forKey: "CircleSize"))*0.25+0.5)
        self.mainColor = userDefaults.colorForKey(key: "MainColor")!
        self.subColor = userDefaults.colorForKey(key: "SubColor")!
        
        // Data Decode
        if let path = Bundle.main.path(forResource: "articles", ofType: "json") {
            guard
                let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                let articles = try? JSONDecoder().decode(ArticlesData.self, from: data)
            else { return }
            
            self.articles = articles
        }
        
        confirmButton.setTitleColor(self.subColor, for: .normal)
        confirmButton.layer.borderColor = self.subColor.cgColor
        confirmButton.layer.borderWidth = 3
        endAnswerButton.layer.borderColor = UIColor.systemRed.cgColor
        endAnswerButton.layer.borderWidth = 3
        
        SelectedArticle
            .debug()
            .subscribe(onNext: {
                self.currentArticle = $0
                self.titleLabel.text = self.articles?.articles?[$0].title
                self.titleLabel.textColor = self.mainColor
                self.titleLabel.font = UIFont(name: "PingFengTC", size: 0)
                self.titleLabel.font = UIFont.systemFont(ofSize: 22)
                
                self.descLabel.text = self.articles?.articles?[$0].desc
                self.descLabel.textColor = self.mainColor
                self.descLabel.font = UIFont(name: "PingFengTC", size: 0)
                self.descLabel.font = UIFont.systemFont(ofSize: 20)
                
                self.questLabel.text = self.articles?.articles?[$0].quest
                self.questLabel.textColor = self.mainColor
                self.questLabel.font = UIFont(name: "PingFengTC", size: 0)
                self.questLabel.font = UIFont.systemFont(ofSize: 20)
                
                let optionButtons = [self.firstOptionButton, self.secondOptionButton, self.thirdOptionButton, self.fourthOptionButton]
                let articleOptions = self.articles?.articles?[$0].options
                optionButtons.enumerated().forEach {
                    $0.element!.titleLabel?.font = UIFont(name: "PingFengTC", size: 0)
                    $0.element!.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                    $0.element!.setTitleColor(self.subColor, for: .normal)
                    $0.element!.iconColor = self.subColor
                    $0.element!.indicatorColor = self.subColor
                    $0.element!.contentHorizontalAlignment = .left
                    $0.element!.titleLabel?.lineBreakMode = .byCharWrapping
                    $0.element!.titleLabel?.numberOfLines = 0
                    $0.element!.setTitle(articleOptions?[$0.offset], for: .normal)
                    $0.element!.addTarget(self, action: #selector(self.selected(radioButton:)), for: .touchUpInside)
                }
            })
            .disposed(by: self.disposeBag)
        
        SelectedArticle.onNext(userDefaults.integer(forKey: "SelectedArticle"))
        self.startArticles = userDefaults.integer(forKey: "SelectedArticle")
        
        // bottom circles
        self.view.addSubview(self.ContainerView)
        self.ContainerView.snp.makeConstraints { (constraints) in
            constraints.width.equalTo(screenWidth*CGFloat(360/circleSpace) + screenWidth)
            constraints.left.top.bottom.equalTo(0)
        }
        ContainerView.backgroundColor = UIColor.clear
        self.view.sendSubviewToBack(ContainerView)
        
        if circleSpace <= 360 {
            applyCircles()
        }
    }
    
    @objc func selected(radioButton: DLRadioButton) {
        switch radioButton {
        case firstOptionButton:
            self.currentSelectedOption = 1
        case secondOptionButton:
            self.currentSelectedOption = 2
        case thirdOptionButton:
            self.currentSelectedOption = 3
        case fourthOptionButton:
            self.currentSelectedOption = 4
            
        default:
            fatalError()
        }
    }
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        if firstOptionButton.selected() == nil {
            let alertController = UIAlertController(title: "注意！", message: "您必須選擇一個答案", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            // 對答案
            if self.currentSelectedOption == articles?.articles?[self.currentArticle].answer {
                self.answeredQuestions[self.currentArticle] = true
            } else {
                self.answeredQuestions[self.currentArticle] = false
            }
            
        
            
            // 換題
            if (self.currentArticle >= ((articles?.articles!.count)!-1)) {
                self.SelectedArticle.onNext(0)
                self.mainScrollView.setContentOffset(.zero, animated: false)
            } else {
                self.SelectedArticle.onNext(self.currentArticle+1)
                self.mainScrollView.setContentOffset(.zero, animated: false)
            }
        
        if(self.currentArticle == self.startArticles) {
            let resultVC = ResultViewController(StartArticle: self.startArticles+1,
                                                EndArticle: self.currentArticle+1,
                                                Answered: self.answeredQuestions.count,
                                                Correct: self.answeredQuestions.filter { $0.value == true }.count,
                                                Incorrect: self.answeredQuestions.filter { $0.value == false }.count)
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
            
            firstOptionButton.isSelected = false
            secondOptionButton.isSelected = false
            thirdOptionButton.isSelected = false
            fourthOptionButton.isSelected = false
        }
    }
    @IBAction func endAnswerButtonPressed(_ sender: Any) {
        
        if (firstOptionButton.selected() != nil) {
            // 對答案
            if self.currentSelectedOption == articles?.articles?[self.currentArticle].answer {
                self.answeredQuestions[self.currentArticle] = true
            } else {
                self.answeredQuestions[self.currentArticle] = false
            }
        }
        
        let resultVC = ResultViewController(StartArticle: self.startArticles+1,
                                            EndArticle: self.currentArticle+1,
                                            Answered: self.answeredQuestions.count,
                                            Correct: self.answeredQuestions.filter { $0.value == true }.count,
                                            Incorrect: self.answeredQuestions.filter { $0.value == false }.count)
        self.navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func applyCircles() {
        bottomCircles = [UIView]()
        for index in 0...360/Int(circleSpace) {
            let circle = UIView()
            ContainerView.addSubview(circle)
            circle.backgroundColor = userDefaults.colorForKey(key: "CircleColor")
            circle.snp.makeConstraints { (constraints) in
                constraints.width.equalTo(screenWidth/2 * self.circleSize)
                constraints.height.equalTo(circle.snp.width)
                let prefix = ((CGFloat(index))*screenWidth)
                constraints.centerX.equalTo(prefix+screenWidth/2)
                constraints.centerY.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            ContainerView.layoutSubviews()
            
            circle.layer.cornerRadius = circle.frame.size.height / 2
            
//            circle.clipsToBounds = true
            bottomCircles?.append(circle)
        }
        
        
        upCircles = [UIView]()
        for index in 0...360/Int(circleSpace) {
            let circle = UIView()
            ContainerView.addSubview(circle)
            circle.backgroundColor = userDefaults.colorForKey(key: "CircleColor")
            circle.snp.makeConstraints { (constraints) in
                constraints.width.equalTo(screenWidth/2 * self.circleSize)
                constraints.height.equalTo(circle.snp.width)
                let prefix = ((CGFloat(index))*screenWidth)
                constraints.centerX.equalTo(prefix+screenWidth/2)
                constraints.centerY.equalTo(view.safeAreaLayoutGuide.snp.top)
            }
            ContainerView.layoutSubviews()
            
            circle.layer.cornerRadius = circle.frame.size.height / 2
            
//            circle.clipsToBounds = true
            upCircles?.append(circle)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingHeading()
        coreMotionManager.stopAccelerometerUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        locationManager.startUpdatingHeading()
        coreMotionManager.startAccelerometerUpdates()
        
        locationManager.rx
            .didUpdateHeading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { heading in
                
                let headDegree = heading.newHeading.trueHeading
                self.currentHeading = headDegree
                let prefix = CGFloat(Int(headDegree/self.circleSpace))*self.screenWidth
                let expextPosition = CGFloat((Int(headDegree)%Int(self.circleSpace)))/CGFloat(self.circleSpace)
                
                if headDegree != 360 || headDegree != 1 {
                    UIView.animate(withDuration: 0.01) {
                        self.ContainerView.frame.origin.x = -prefix - (expextPosition * self.screenWidth)
                    }
                } else {
                    self.ContainerView.frame.origin.x = -prefix - (expextPosition * self.screenWidth)
                }
            })
            .disposed(by: disposeBag)
        
        coreMotionManager.rx
            .accelerometerData
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                let xData = (Double(String(format: "%.2f", data.acceleration.x))!)
                let yData = (Double(String(format: "%.2f", data.acceleration.y))!)
                let zData = (Double(String(format: "%.2f", data.acceleration.z))!)
                let newData = (xData + yData + zData)/3
                let scaleValue = CGFloat((newData - self!.comporasion))
                
                UIView.animate(withDuration: 0.8, animations: {
                    self?.upCircles?.forEach({ (circle) in
                        circle.transform = CGAffineTransform(scaleX: 1 - self!.scaleMag*scaleValue, y: 1 - self!.scaleMag*scaleValue)
                    })
                })
                UIView.animate(withDuration: 0.8, animations: {
                    self?.bottomCircles?.forEach({ (circle) in
                        circle.transform = CGAffineTransform(scaleX: 1 - self!.scaleMag*scaleValue, y: 1 - self!.scaleMag*scaleValue)
                    })
                })
                self?.comporasion = newData
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let prefix = CGFloat(Int(self.currentHeading/self.circleSpace))*self.screenWidth
        let expextPosition = CGFloat((Int(self.currentHeading)%Int(self.circleSpace)))/CGFloat(self.circleSpace)
        if self.currentHeading != 360 || self.currentHeading != 1 {
            UIView.animate(withDuration: 0.01) {
                self.ContainerView.frame.origin.x = -prefix - (expextPosition * self.screenWidth)
            }
        } else {
            self.ContainerView.frame.origin.x = -prefix - (expextPosition * self.screenWidth)
        }
    }
}
