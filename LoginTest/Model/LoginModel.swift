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
            return ""
        case .invalidPassword:
            return ""
        case .invalidEmailAndPassword:
            return ""
        case .invalidResponseData:
            return ""
        }
    }
}

protocol LoginModelProtocol {
    func validate(email: String?, password: String?) -> Observable<Void>
    func createHttpBody(email: String, password: String) throws -> Data
    func login(data: Data) throws -> Observable<User>
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
    
    func createHttpBody(email: String, password: String) throws -> Data {
        let params: [String: Any] = ["email": email, "password": password]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            return data
        } catch (let error){
            throw error
        }
    }
    
    func login(data: Data) throws -> Observable<User> {
        return Observable<User>.create() { observer -> Disposable in
            self.api.post(url: "", body: data, success: { data in
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
