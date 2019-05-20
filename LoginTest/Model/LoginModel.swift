import Foundation
import RxSwift

enum LoginError: Error, CustomStringConvertible {
    case invalidEmail
    case invalidPassword
    case invalidEmailAndPassword
    case invalidResponseData
    
    var description: String {
        switch self {
        case .invalidEmail:
            return "e-mailが不正です"
        case .invalidPassword:
            return "パスワードが不正です。"
        case .invalidEmailAndPassword:
            return "e-mailとパスワードが不正です。"
        case .invalidResponseData:
            return "不正なレスポンスデータです。"
        }
    }
}

protocol LoginModelProtocol {
    func validate(email: String?, password: String?) -> Observable<Void>
    func createHttpBody(email: String?, password: String?) -> Data?
    func login(data: Data) -> Observable<User>
}

final class LoginModel: LoginModelProtocol {
    
    private let api: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.api = apiClient
    }

    func validate(email: String?, password: String?) -> Observable<Void> {
        switch (email, password) {
        case (.none, .none):
            return Observable.error(LoginError.invalidEmailAndPassword)
        case (.some, .none):
            return Observable.error(LoginError.invalidPassword)
        case (.none, .some):
            return Observable.error(LoginError.invalidEmail)
        case (let mailText, let passwordText):
            switch (mailText?.isEmpty, passwordText?.isEmpty) {
            case (true, true):
                return Observable.error(LoginError.invalidEmailAndPassword)
            case (false, true):
                return Observable.error(LoginError.invalidEmailAndPassword)
            case (true, false):
                return Observable.error(LoginError.invalidEmailAndPassword)
            case (false, false):
                return Observable.just(())
            default:
                return  Observable.error(LoginError.invalidEmailAndPassword)
            }
        }
    }
    
    func createHttpBody(email: String?, password: String?) -> Data? {
        guard let email = email, let password = password else { return nil }
        let params: [String: Any] = ["email": email, "password": password]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            return data
        } catch {
            return nil
        }
    }
    
    func login(data: Data) -> Observable<User> {
        return Observable<User>.create() { observer -> Disposable in
            self.api.post(url: "URLを指定する", body: data, success: { data in
                if let user = User(json: data) {
                    observer.onNext(user)
                    observer.onCompleted()
                }
                observer.onError(LoginError.invalidResponseData)
            }, failure: { error in
                observer.onError(error)
            })
            return Disposables.create()
            
        }
    }
    
}
