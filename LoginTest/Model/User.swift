import Foundation

struct User {
    let id: String
    let name: String
    
    init?(json: [String: Any])  {
        guard let id = json["id"] as? String else {
            return nil
        }
        self.id = id
        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
    }
}
