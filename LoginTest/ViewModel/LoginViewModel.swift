import Foundation
import RxSwift
import RxCocoa

struct LoginViewModelInput {
    let emailTextObservable: Observable<String?>
    let passwordTextObservable: Observable<String?>
    let submitButton: Observable<Void>
}

protocol LoginViewModelOutput {
    var result: Observable<Bool> { get }
    var isLoginButtonEnabled: Observable<Bool> { get }
    var isLoading: Observable<Bool> { get }
}

protocol LoginViewModelType {
    var outputs: LoginViewModelOutput? { get }
    func setup(input: LoginViewModelInput)
}

final class LoginViewModel: LoginViewModelType {
    
    private let disposeBag = DisposeBag()
    
    var outputs: LoginViewModelOutput?
    var model: LoginModelProtocol!
    var event: Observable<Event<Void>>!
    
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
    }
    
}

extension LoginViewModel: LoginViewModelOutput {
    
    var result: Observable<Bool> {
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
    
    var isLoginButtonEnabled: Observable<Bool> {
        return self.event.flatMap { event -> Observable<Bool> in
            switch event {
            case .next:
                return .just(true)
            default:
                return .just(false)
            }
        }
    }
    
    var isLoading: Observable<Bool> {
        return self.event.flatMap { event -> Observable<Bool> in
            switch event {
            case .next:
                return .just(true)
            default:
                return .just(false)
            }
        }
    }
    
}
