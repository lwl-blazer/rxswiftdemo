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

class ViewController1: UIViewController {

    
    var label1 = UILabel.init(frame: CGRect(x: 20, y: 100, width: 200, height: 40))
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
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
