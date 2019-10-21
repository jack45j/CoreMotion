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
    var selectedArticle = 0
    let defaultUDValue: [String : Any] =
        ["selectedArticle": 0,
         "CircleColorR": 0,
         "CircleColorG": 0,
         "CircleColorB": 0,
         "CircleColorA": 1]
    //---------
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var questLabel: UILabel!
    @IBOutlet weak var firstOptionButton: DLRadioButton!
    @IBOutlet weak var secondOptionButton: DLRadioButton!
    @IBOutlet weak var thirdOptionButton: DLRadioButton!
    @IBOutlet weak var fourthOptionButton: DLRadioButton!
    let UpContainerView = UIView()
    let ContainerView = UIView()
    var upCircles: [UIView]?
    var bottomCircles: [UIView]?
    
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let userDefaults = UserDefaults.standard
    let coreMotionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    
    var comporasion = 0.00
    let circleSpace = 180.0
    var currentHeading:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults.register(defaults: defaultUDValue)
        
        locationManager.requestWhenInUseAuthorization()
        coreMotionManager.accelerometerUpdateInterval = 0.01
        
        // Data Decode
        if let path = Bundle.main.path(forResource: "articles", ofType: "json") {
            guard
                let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                let articles = try? JSONDecoder().decode(ArticlesData.self, from: data)
            else { return }
            
            userDefaults.set(Int(arc4random_uniform(UInt32("\(articles.articles?.count ?? 0)")!)), forKey: "selectedArticle")
            
            selectedArticle = userDefaults.integer(forKey: "selectedArticle")
            
            titleLabel.text = articles.articles?[selectedArticle].title
            descLabel.text = articles.articles?[selectedArticle].desc
            questLabel.text = articles.articles?[selectedArticle].quest
            
            let optionButtons = [firstOptionButton, secondOptionButton, thirdOptionButton, fourthOptionButton]
            let articleOptions = articles.articles?[selectedArticle].options
            optionButtons.enumerated().forEach {
                $0.element!.contentHorizontalAlignment = .left
                $0.element!.titleLabel?.lineBreakMode = .byCharWrapping
                $0.element!.titleLabel?.numberOfLines = 0
                $0.element!.setTitle(articleOptions?[$0.offset], for: .normal)
                $0.element!.addTarget(self, action: #selector(self.selected(radioButton:)), for: .touchUpInside)
            }
        }
        
        // bottom circles
        self.view.addSubview(self.ContainerView)
        self.ContainerView.snp.makeConstraints { (constraints) in
            constraints.width.equalTo(screenWidth*CGFloat(360/circleSpace) + screenWidth)
            constraints.left.top.bottom.equalTo(0)
        }
        ContainerView.backgroundColor = UIColor.clear
        self.view.sendSubviewToBack(ContainerView)
        
        applyCircles()
    }
    
    @objc func selected(radioButton: DLRadioButton) {
        print(radioButton.titleLabel?.text)
    }
    
    func applyCircles() {
        print("ApplyCircles")
        bottomCircles = [UIView]()
        for index in 0...360/Int(circleSpace) {
            let circle = UIView()
            ContainerView.addSubview(circle)
            circle.backgroundColor = userDefaults.colorForKey(key: "CircleColor")
            circle.snp.makeConstraints { (constraints) in
                constraints.width.equalTo(screenWidth/2)
                constraints.height.equalTo(circle.snp.width)
                let prefix = ((CGFloat(index))*screenWidth)
                constraints.centerX.equalTo(prefix+screenWidth/2)
                constraints.centerY.equalTo(UIScreen.main.bounds.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)
            }
            ContainerView.layoutSubviews()
            circle.layer.cornerRadius = circle.frame.size.height / 2
            circle.clipsToBounds = true
            bottomCircles?.append(circle)
        }
        
        
        upCircles = [UIView]()
        for index in 0...360/Int(circleSpace) {
            let circle = UIView()
            ContainerView.addSubview(circle)
            circle.backgroundColor = userDefaults.colorForKey(key: "CircleColor")
            circle.snp.makeConstraints { (constraints) in
                constraints.width.equalTo(screenWidth/2)
                constraints.height.equalTo(circle.snp.width)
                let prefix = ((CGFloat(index))*screenWidth)
                constraints.centerX.equalTo(prefix+screenWidth/2)
                constraints.centerY.equalTo(view.safeAreaLayoutGuide.snp.top)
            }
            ContainerView.layoutSubviews()
            circle.layer.cornerRadius = circle.frame.size.height / 2
            circle.clipsToBounds = true
            upCircles?.append(circle)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingHeading()
        coreMotionManager.stopAccelerometerUpdates()
        print("Stop")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startUpdatingHeading()
        coreMotionManager.startAccelerometerUpdates()
        
        locationManager.rx
            .didUpdateHeading
            .observeOn(MainScheduler.instance)
//            .debounce(.seconds(1), scheduler: MainScheduler.instance)
//            .buffer(timeSpan: .seconds(1), count: 2, scheduler: MainScheduler.instance)
//            .throttle(.seconds(1), latest: true, scheduler: MainScheduler.instance)
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
            .map { return fabs(Double(String(format: "%.2f", $0.acceleration.x))!) }
            .buffer(timeSpan: .milliseconds(200), count: 2, scheduler: MainScheduler.instance)
            
            .filter { $0.count == 2 }
            .subscribe(onNext: { [weak self] data in
                
                if data[0] - data[1] <= -0.02 {
//                    print("加速度 \(data[0]) \(data[1])")
                    UIView.animate(withDuration: 0.6) {
                        self?.bottomCircles?.forEach({ (circle) in
                            circle.transform = CGAffineTransform(scaleX: CGFloat(1 - 2*(data[0] - data[1])), y: CGFloat(1 - 2*(data[0] - data[1])))
                        })
                        
                        self?.upCircles?.forEach({ (circle) in
                            circle.transform = CGAffineTransform(scaleX: CGFloat(1 - 2*(data[0] - data[1])), y: CGFloat(1 - 2*(data[0] - data[1])))
                        })
                    }
                } else if data[0] - data[1] >= 0.02 {
//                    print("減速度 \(data[0]) \(data[1])")
                    UIView.animate(withDuration: 0.05) {
                        self?.bottomCircles?.forEach({ (circle) in
                            circle.transform = CGAffineTransform(scaleX: CGFloat(1 - 2*(data[0] - data[1])), y: CGFloat(1 - 2*(data[0] - data[1])))
                        })
                        
                        self?.upCircles?.forEach({ (circle) in
                            circle.transform = CGAffineTransform(scaleX: CGFloat(1 - 2*(data[0] - data[1])), y: CGFloat(1 - 2*(data[0] - data[1])))
                        })
                    }
                } else {
//                    print("平均 \(data[0]) \(data[1])")
                    UIView.animate(withDuration: 0.05) {
                        self?.bottomCircles?.forEach({ (circle) in
                            circle.transform = CGAffineTransform(scaleX: 1, y: 1)
                        })
                        
                        self?.upCircles?.forEach({ (circle) in
                            circle.transform = CGAffineTransform(scaleX: 1, y: 1)
                        })
                    }
                }
            })
            .disposed(by: disposeBag)
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
