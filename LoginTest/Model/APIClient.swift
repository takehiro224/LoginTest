import Foundation

enum APIError: Error, CustomStringConvertible {
    case unknown
    case invalidURL
    case invalidResponse
    
    var description: String {
        switch self {
        case .unknown:
            return ""
        case .invalidURL:
            return ""
        case .invalidResponse:
            return ""
        }
    }
}

protocol APIClientProtocol {
    func post(url: String, body: Data?, success: @escaping ([String: Any]) -> (), failure: @escaping (Error) -> Void)
}

final class APIClient: APIClientProtocol {
    func post(url: String, body: Data?, success: @escaping ([String: Any]) -> (), failure: @escaping (Error) -> Void) {
        guard let url = URL(string: url) else {
            failure(APIError.invalidURL)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                failure(error)
                return
            }
            
            guard let data = data else {
                failure(APIError.unknown)
                return
            }
            
            guard let jsonOptional = try? JSONSerialization.jsonObject(with: data, options: []), let json = jsonOptional as? [String: Any] else {
                failure(APIError.invalidResponse)
                return
            }
            
            success(json)
        }
        
        task.resume()
    }
}

final class MocAPIClient: APIClientProtocol {
    func post(url: String, body: Data?, success: @escaping ([String: Any]) -> (), failure: @escaping (Error) -> Void) {
        
    }
}
