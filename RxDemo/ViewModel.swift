//
//  ViewModel.swift
//  RxDemo
//
//  Created by luowailin on 2020/5/15.
//  Copyright © 2020 luowailin. All rights reserved.
//

import Foundation
import RxSwift




struct MusicListViewModel {
    let data = Observable.just([
        Music(name: "无条件", signer: "陈奕迅"),
        Music(name: "你曾是少年", signer: "S.H.E"),
        Music(name: "从前的我", signer: "陈洁仪"),
        Music(name: "在木星", signer: "朴树")
    ])
}
