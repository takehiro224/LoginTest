//
//  ViewController.swift
//  LoginTest
//
//  Created by Watanabe Takehiro on 2019/05/15.
//  Copyright © 2019 Watanabe Takehiro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    private let disposeBag = DisposeBag()
    private var viewModel: LoginViewModel!
    
    var loginButtonEnableFlag: Bool = false {
        didSet {
            self.loginButton.backgroundColor = loginButtonEnableFlag ? .orange : .yellow
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.backgroundColor = .yellow
        self.loginButton.tintColor = .white
        
        self.viewModel = LoginViewModel(model: LoginModel(apiClient: APIClient()))
        
        let input = LoginViewModelInput(emailTextObservable: emailTextField.rx.text.asObservable(), passwordTextObservable: passwordTextField.rx.text.asObservable(), submitButton: loginButton.rx.tap.asObservable())
        
        self.viewModel.setup(input: input)
        self.viewModel.isLoginButtonEnabled.bind(to: loadFlag).disposed(by: self.disposeBag)
    }

    private var loadFlag: Binder<Bool> {
        return Binder(self, binding: { me, flag in
            me.loginButtonEnableFlag = flag
        })
    }
}

