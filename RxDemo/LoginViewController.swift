//
//  LoginViewController.swift
//  RxDemo
//
//  Created by luowailin on 2020/8/25.
//  Copyright © 2020 luowailin. All rights reserved.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingUpOutlet: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录"
        
        let viewmodel = GithupSignupViewModel1(input: (username: usernameOutlet.rx.text.orEmpty.asObservable(),
                                                       password: passwordOutlet.rx.text.orEmpty.asObservable(),
                                                       repeatedPassword: repeatedPasswordOutlet.rx.text.orEmpty.asObservable(),
                                                       loginTaps: signupOutlet.rx.tap.asObservable()),
                                               dependency: (API: GitHubDefaultAPI.shareAPI,
                                                            validationService: GitHubDefaultValidationService.shareValidationService,
                                                wireframe: DefaultWireframe.shared))
        
        viewmodel.signupEnabled.subscribe(onNext: { [weak self] valid in
            self?.signupOutlet.isEnabled = valid
            self?.signupOutlet.alpha = valid ? 1.0 : 0.5
            }).disposed(by: disposeBag)

        viewmodel.validateUsername
            .bind(to: usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewmodel.validatePassword
            .bind(to: passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewmodel.validatePasswordRepeated
            .bind(to: repeatPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewmodel.signingIn
            .bind(to: signingUpOutlet.rx.isAnimating)
        .disposed(by: disposeBag)
        
        viewmodel.signedIn.subscribe(onNext: { signedIn in
            print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event.subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
    }
}
