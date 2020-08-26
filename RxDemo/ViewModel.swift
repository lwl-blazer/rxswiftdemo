//
//  ViewModel.swift
//  RxDemo
//
//  Created by luowailin on 2020/5/15.
//  Copyright © 2020 luowailin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

struct MusicListViewModel {
    /**
     Observable 可监听序列
     * 操作符:just(0) 将某个元素转换为Observable
     */
    let data = Observable.just([
        Music(name: "无条件", signer: "陈奕迅"),
        Music(name: "你曾是少年", signer: "S.H.E"),
        Music(name: "从前的我", signer: "陈洁仪"),
        Music(name: "在木星", signer: "朴树")
    ])
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
        }
    }
}


// 'Reactive' 用于用户自定义, 创建UI观察者
extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        //Binder 只会处理next事件
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

protocol GitHubAPI {
    func usernameAvailable(_ username: String) -> Observable<Bool>
    func signup(_ username: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUsername(_ username: String) -> Observable<ValidationResult>
    func validatePassword(_ password: String) -> ValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

class GithupSignupViewModel1 {
    
    //outputs
    let validateUsername: Observable<ValidationResult>
    let validatePassword: Observable<ValidationResult>
    let validatePasswordRepeated: Observable<ValidationResult>
    
    let signupEnabled: Observable<Bool>
    let signedIn: Observable<Bool>
    let signingIn: Observable<Bool>
    
    init(input: (username: Observable<String>,
        password: Observable<String>,
        repeatedPassword: Observable<String>,
        loginTaps: Observable<Void>),
         dependency: (API: GitHubAPI,
        validationService: GitHubValidationService,
        wireframe: Wireframe)) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
    
        validateUsername = input.username.flatMapLatest{ username in
            return validationService.validateUsername(username)
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(.failed(message: "Error contacting server"))
        }.share(replay: 1)
        
        validatePassword = input.password.map { passwd in
            return validationService.validatePassword(passwd)
        }.share(replay: 1)
        
        validatePasswordRepeated = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
            .share(replay: 1)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
        let usernameAndPassword = Observable.combineLatest(input.username, input.password) {(username: $0, password: $1)}
        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword).flatMapLatest {pair in
            return API.signup(pair.username, password: pair.password)
                .observeOn(MainScheduler.instance)
            .catchErrorJustReturn(false)
            .trackActivity(signingIn)
        }.flatMapLatest {loggedIn -> Observable<Bool> in
            let message = loggedIn ? "Mock:Signed in to Github." : "Mock: Sign in to Githup failed"
            return wireframe.promptFor(message,
                                       cancelAction: "OK",
                                       actions: []).map { _ in
                                        loggedIn
            }
        }.share(replay: 1)
        
        signupEnabled = Observable.combineLatest(validateUsername,
                                                 validatePassword,
                                                 validatePasswordRepeated,
                                                 signingIn.asObservable())
        { username, password, repeatPassword, signingIn in
            username.isValid &&
            password.isValid &&
            repeatPassword.isValid && !signingIn
        }.distinctUntilChanged()
        .share(replay: 1)
    }
}
