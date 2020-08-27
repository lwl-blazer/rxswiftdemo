//
//  ViewController.swift
//  RxDemo
//
//  Created by luowailin on 2020/5/15.
//  Copyright © 2020 luowailin. All rights reserved.
//  https://www.jianshu.com/p/87df472317f1

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    let musiclist = MusicListViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rxswift"
        musiclist.data.bind(to: tableview.rx.items(cellIdentifier: "musicCell")){_, music, cell in
            cell.textLabel?.text = music.name
            cell.detailTextLabel?.text = music.signer
        }.disposed(by: disposeBag)
        
        tableview.rx.modelSelected(Music.self).subscribe(onNext: { music in
            print("你选中的歌曲信息\(music)")
            self.navigationController?.pushViewController(ViewController1.init(), animated: true)
            }).disposed(by: disposeBag)
       
        
        
        let observable = Observable<String>.create { observer in
            observer.onNext("hangge.com")
            observer.onCompleted()
            return Disposables.create()
        }
        observable.subscribe{
            print($0)
        }.disposed(by: disposeBag)
        
        
        var isOdd = true
        /** deferred
         * 直到订阅，才创建Observable,并且为每位订阅者创建全新的Observable
         * 它会通过一个构建函数为每一位订阅者创建新的Observable,
         * 在一些情况下，直到订阅时才创建Observable是可以保证拿到的数据都是最新的*/
        let factory: Observable<Int> = Observable.deferred {
            isOdd = !isOdd
            if isOdd {
                // 创建新的Observable
                return Observable.of(1,3,5,7,9)
            } else {
                return Observable.of(2,4,6,8,10)
            }
        }
        factory.subscribe{ event in
            print(event)
        }.disposed(by: disposeBag)
        
        factory.subscribe{ event in
            print(event)
        }.disposed(by: disposeBag)
        
        /** flatMap
         * 将Observable的元素转换成其他的Observable，然后将这些Observables合并
         * flatMap操作符将源Observable的每一个元素应用一个转换方法，将他们转换成Observables. 然后将这些Observables的元素合并之后再发送出来
         * 用处:
         * 当Observable的元素本身拥有其他的Observable时，你可以将所有子Observables的元素发送出来
         */
        let flatMap1 = BehaviorSubject(value: "👦🏻")
        let flatMap2 = BehaviorSubject(value: "🅰️")
        let variable = Variable(flatMap1)
        
        variable.asObservable()
            .flatMap({ $0 })
            .subscribe(onNext: {
                print($0)
            }).disposed(by: disposeBag)
        flatMap1.onNext("🐱")
        variable.value = flatMap2
        flatMap2.onNext("🅱️")
        flatMap1.onNext("🐶")
        //打印结果:👦🏻 🐱 🅰️ 🅱️ 🐶
        
        /** flatMapLatest
         * 将Observable的元素转换成其他的Observable,然后取这些Observables中最新的一个
         * 跟flatMap不同的是：一旦转换出一个新的Observable，就只发出它的元素，旧的Observables的元素将被忽略掉
         */
        let flatMapLatest1 = BehaviorSubject(value: "👦🏻")
        let flatMapLatest2 = BehaviorSubject(value: "🅰️")
        let variable2 = Variable(flatMapLatest1)
        variable2.asObservable()
            .flatMapLatest { $0 }
            .subscribe(onNext: {
                print($0)
            }).disposed(by: disposeBag)
        flatMapLatest1.onNext("🐱")
        variable2.value = flatMapLatest2
        flatMapLatest2.onNext("🅱️")
        flatMapLatest1.onNext("🐶")
        //打印结果:👦🏻 🐱 🅰️ 🅱️
        
        /** Map
         * 通过转换函数，将Observable的每个元素转换一遍
         * map操作任将源Observable的每个元素应用你提供的转换方法，然后返回含有转换结果的Observable
         **/
        Observable.of(1,2,3).map { $0 * 10 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        //打印结果 10 20 30
        
        /**
         * combineLatest
         * 组合
         */
        let combine1 = PublishSubject<String>()
        let combine2 = PublishSubject<String>()
        Observable.combineLatest(combine1, combine2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        combine1.onNext("1")
        combine2.onNext("A")
        combine1.onNext("2")
        combine2.onNext("B")
        combine2.onNext("C")
        combine2.onNext("D")
        combine1.onNext("3")
        combine1.onNext("4")
        //打印结果 ("1", "A") ("2", "A") ("2", "B") ("2", "C") ("2", "D")("3", "D") ("4", "D")
        
        /**
         * withLatestFrom
         * 将两个Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。当第一个Observable发出一个元素时，就立即取出第二个Observable中最新的元素，通过一个组合函数将两个最新的元素合并后发送出去
         */
        //例1--当第一个Observable发出第一个元素时，就立即取出第二个Observable中最新元素，然后把第二个Observable中最新元素发送出去
        let withLatestFrom1 = PublishSubject<String>()
        let withLatestFrom2 = PublishSubject<String>()
        
        withLatestFrom1
            .withLatestFrom(withLatestFrom2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        withLatestFrom1.onNext("🅰️")
        withLatestFrom1.onNext("🅱️")
        withLatestFrom2.onNext("1")
        withLatestFrom2.onNext("2")
        withLatestFrom1.onNext("🆎")
        //打印结果： 2
        
        //例2--当第一个Observable发出第一个元素时，就立即取出第二个Observable中最新元素，将第一个Observable中最新元素first和第二个Observable中最新的元素second组合，然后把组合结果发送出去
        let withLatestFrom3 = PublishSubject<String>()
        let withLatestFrom4 = PublishSubject<String>()
        withLatestFrom3.withLatestFrom(withLatestFrom4){ (first, second) in
            return first + second
        }
        .subscribe(onNext: { print($0)})
        .disposed(by: disposeBag)
        withLatestFrom3.onNext("🅰️")
        withLatestFrom3.onNext("🅱️")
        withLatestFrom4.onNext("1")
        withLatestFrom4.onNext("2")
        withLatestFrom3.onNext("🆎")
        //打印结果： 🆎2
    }
}
