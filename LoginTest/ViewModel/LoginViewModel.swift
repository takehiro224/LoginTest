import Foundation
import RxSwift
import RxCocoa

struct LoginViewModelInput {
    let emailTextObservable: Observable<String?>
    let passwordTextObservable: Observable<String?>
    let submitButton: Observable<Void>
}

protocol LoginViewModelOutput {
    var isLoginButtonEnabled: Observable<Bool> { get }
    var isLoading: Observable<Bool> { get }
}

protocol LoginViewModelType {
    var outputs: LoginViewModelOutput? { get }
    func setup(input: LoginViewModelInput)
}

enum LoginViewModelState {
    case loading
    case finish
    case error(Error)
}

final class LoginViewModel: LoginViewModelType {
    
    private let disposeBag = DisposeBag()
    
    var outputs: LoginViewModelOutput?
    var model: LoginModelProtocol!
    var event: Observable<Event<Void>>!
    var mailTextRelay = BehaviorRelay<String?>(value: "")
    var passwordTextRelay = BehaviorRelay<String?>(value: "")
    var loadingState = BehaviorRelay<Bool>(value: false)
    var stateDidUpdate: ((LoginViewModelState) -> Void)?
    
    init(model: LoginModelProtocol) {
        self.outputs = self
        self.model = model
    }
    
    func setup(input: LoginViewModelInput) {
        self.event = Observable
            .combineLatest(input.emailTextObservable, input.passwordTextObservable)
            .skip(1)
            .flatMap { (arg) -> Observable<Event<Void>> in
                let (mailText, passwordText) = arg
                return self.model.validate(email: mailText, password: passwordText).materialize()
        }.share()
        
        Observable.combineLatest(input.emailTextObservable, input.passwordTextObservable).subscribe(onNext: { (mailText, passwordText) in
            self.setText(mailText: mailText, passwordText: passwordText)
        }).disposed(by: self.disposeBag)
        
        input.submitButton.subscribe(onNext: {
            self.login()
        }).disposed(by: self.disposeBag)
        
    }
    
    private func setText(mailText: String?, passwordText: String?) {
        self.mailTextRelay.accept(mailText)
        self.passwordTextRelay.accept(passwordText)
    }
    
    private func login() {
        // インジケーター表示
        self.stateDidUpdate?(.loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let body = self.model.createHttpBody(email: self.mailTextRelay.value, password: self.passwordTextRelay.value)  {
                self.model.login(data: body).subscribe(
                    onNext: { user in
                        self.stateDidUpdate?(.finish)
                },
                    onError: { error in
                        self.stateDidUpdate?(.error(error))
                },
                    onCompleted: {
                }).disposed(by: self.disposeBag)
            }
        }
    }
    
}

extension LoginViewModel: LoginViewModelOutput {
    
    var isLoginButtonEnabled: Observable<Bool> {
        return self.event.flatMap { event -> Observable<Bool> in
            switch event {
            case .next:
                return .just(true)
            case .error:
                return .just(false)
            case .completed:
                return .just(true)
            }
        }
    }
    
    var isLoading: Observable<Bool> {
        return self.loadingState.asObservable()
    }
    
}
