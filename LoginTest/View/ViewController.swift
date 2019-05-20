import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private var viewModel: LoginViewModel!
    
    var loginButtonEnableFlag: Bool = false {
        didSet {
            self.loginButton.backgroundColor = loginButtonEnableFlag ? .activeButtonColor : .inactiveButtonColor
            self.loginButton.isUserInteractionEnabled = loginButtonEnableFlag
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.loginButton.backgroundColor = .inactiveButtonColor
        self.loginButton.layer.cornerRadius = 5
        self.indicator.isHidden = true
        self.indicator.style = .whiteLarge
        self.indicator.color = .white
        self.view.addSubview(self.indicator)
        
        self.viewModel = LoginViewModel(model: LoginModel(apiClient: MocAPIClient()))
        
        let input = LoginViewModelInput(emailTextObservable: emailTextField.rx.text.asObservable(), passwordTextObservable: passwordTextField.rx.text.asObservable(), submitButton: loginButton.rx.tap.asObservable())
        self.viewModel.setup(input: input)
        
        self.viewModel.isLoginButtonEnabled.bind(to: loadFlag).disposed(by: self.disposeBag)
        self.viewModel.isLoading.bind(to: self.loginButton.rx.isUserInteractionEnabled).disposed(by: self.disposeBag)
        
        self.viewModel.stateDidUpdate = { [weak self] state in
            switch state {
            case .loading:
                
                self?.indicator.isHidden = false
                self?.indicator.startAnimating()
                self?.loginButton.backgroundColor = .inactiveButtonColor
                self?.loginButton.isUserInteractionEnabled = false
            case .finish:
                self?.indicator.isHidden = true
                self?.indicator.stopAnimating()
                self?.loginButton.isUserInteractionEnabled = true
                self?.loginButton.backgroundColor = .activeButtonColor
                let alert = UIAlertController(title: "OK", message: "Succeeded to authenticate", preferredStyle: .alert)
                let action = UIAlertAction(title: "Yes", style: .default, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
            case .error(_):
                self?.indicator.isHidden = true
                self?.indicator.stopAnimating()
                self?.loginButton.isUserInteractionEnabled = true
                self?.loginButton.backgroundColor = .activeButtonColor
                let alert = UIAlertController(title: nil, message: "Failed to authenticate", preferredStyle: .alert)
                let action = UIAlertAction(title: "Yes", style: .default, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    private var loadFlag: Binder<Bool> {
        return Binder(self, binding: { me, flag in
            me.loginButtonEnableFlag = flag
        })
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        return true
    }
}
