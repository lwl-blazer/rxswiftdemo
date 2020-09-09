//
//  ViewController1.swift
//  RxDemo
//
//  Created by luowailin on 2020/5/15.
//  Copyright © 2020 luowailin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

struct SampleError: Error {
    let test: Int;
}

class ViewController1: UIViewController {

    var label1 = UILabel.init(frame: CGRect(x: 20, y: 100, width: 200, height: 40))
    
    let successbtn = UIButton.init(type: .system)
    let successLabel = UILabel.init(frame: CGRect(x: 20.0, y: 230.0, width: 200, height: 20))
    
    let faileBtn = UIButton.init(type: .system)
    let faileLabel = UILabel.init(frame: CGRect(x: 20.0, y: 320.0, width: 200.0, height: 30.0))
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label1)
        
        label1.text = "RxSwift"
        
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        observable.map{ CGFloat($0)}
            .bind(to: label1.rx.fontSize)
            .disposed(by:disposeBag)
        
        successbtn.frame = CGRect(x: 20.0, y: 180.0, width: 80.0, height: 30.0)
        successbtn.setTitle("success", for: .normal)
        view.addSubview(successbtn)
        view.addSubview(successLabel)
        
        faileBtn.frame = CGRect(x: 20.0, y: 270.0, width: 200.0, height: 30.0)
        faileBtn.setTitle("faile", for: .normal)
        view.addSubview(faileBtn)
        view.addSubview(faileLabel)
    
        /*
        let successCount = Observable.of(successbtn.rx.tap.map{true}, faileBtn.rx.tap.map{false})
        .merge()
            .flatMap { [unowned self] performWithSuccess in
                return self.performAPICall(shouldEndWithSuccess: performWithSuccess)
        }.scan(0) { accumulator, _ in
                return accumulator + 1
        }.map {"\($0)"}
        
        successCount.bind(to: successLabel.rx.text).disposed(by: disposeBag)
 */
        
        
        let result = Observable.of(successbtn.rx.tap.map{true}, faileBtn.rx.tap.map{false})
            .merge()
            .flatMap { [unowned self] performWithSuccess in
                return self.performAPICall(shouldEndWithSuccess: performWithSuccess)
                .materialize()
        }.share()
        
        result.elements().scan(0) { accumulator, _ in
            return accumulator + 1
        }.map{"\($0)"}
            .bind(to: successLabel.rx.text)
        .disposed(by: disposeBag)
        
        result.errors()
            .scan(0) { accumulator, _ in
                return accumulator + 1
        }.map { "\($0)" }
            .bind(to: faileLabel.rx.text)
        .disposed(by: disposeBag)

    }
    
    private func performAPICall(shouldEndWithSuccess: Bool) -> Observable<Void> {
        if shouldEndWithSuccess {
            return .just(())
        } else {
            return .error(SampleError.init(test: 2))
        }
    }
}

extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
