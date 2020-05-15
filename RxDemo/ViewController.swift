//
//  ViewController.swift
//  RxDemo
//
//  Created by luowailin on 2020/5/15.
//  Copyright © 2020 luowailin. All rights reserved.
//

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
        
        let factory: Observable<Int> = Observable.deferred {
            isOdd = !isOdd
            if isOdd {
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
    }
}
