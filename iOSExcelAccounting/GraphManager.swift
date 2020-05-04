import Foundation
import MSGraphClientSDK
import MSGraphClientModels
import SwiftyJSON

public class GraphManager {

    public enum error : Error {
        case IllegalID
        case IllegalUrl
        case IllegalQuery
    }
    
    public enum selectType : String {
        case name
        case id
        case webUrl
        case downloadUrl = "@microsoft.graph.downloadUrl"
    }
    // Implement singleton pattern
    public static let instance = GraphManager()

    private let client: MSHTTPClient?

    private init() {
        client = MSClientFactory.createHTTPClient(with: AuthenticationManager.instance)
    }

    public func getMe(completion: @escaping(MSGraphUser?, Error?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me")!)
        let task = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                do {
                    // Deserialize response as a user
                    let user = try MSGraphUser(data: data)
                    completion(user, nil)
                } catch {
                    completion(nil, error)
                }                
            }
        })
        task?.execute()
    }
    
    public func updateFile(id: String, fileUrl: URL, completion: @escaping(JSON?, Error?) -> Void){
        let string = "\(MSGraphBaseURL)/me/drive/items/\(id)/content"
        guard let url = URL(string: string) else {
            print("Illegal id: \(id)")
            completion(nil, error.IllegalID)
            return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "PUT"
        let task = MSURLSessionUploadTask(request: request, fromFile: fileUrl, client: self.client, completionHandler: {
            (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            completion(JSON(data), nil)
        })
        task?.execute()
    }
    
    public func updateFile(id: String, content: String, completion: @escaping(JSON?, Error?) -> Void){
        let string = "\(MSGraphBaseURL)/me/drive/items/\(id)/content"
        guard let url = URL(string: string) else {
            print("Illegal id: \(id)")
            completion(nil, error.IllegalUrl)
            return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "PUT"
        let task = MSURLSessionUploadTask(request: request, data: content.data(using: .utf8), client: self.client, completionHandler: {
            (data, response, error) in
            DispatchQueue.main.async { // back to the main thread here
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                completion(JSON(data), nil)
            }
        })
        task?.execute()
    }
    
    /**
     - Parameter query: string of the search query.
                        Note: cannot contains any non-English characters or symbols
     */
    public func searchDrive(query: String, selects: [selectType], completion: @escaping(JSON?, Error?) -> Void) {
        let string = "\(MSGraphBaseURL)/me/drive/root/search(q='\(query)')?select=\(selects.map{ $0.rawValue }.joined(separator: ","))"
        guard let url = URL(string: string) else {
            print("Illegal query: \(string)")
            completion(nil, error.IllegalQuery)
            return
        }
        let request = NSMutableURLRequest(url: url)
        let task = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                completion(JSON(data), nil)
            }
        })
        task?.execute()
    }
    
    public func getFile(id: String, completion: @escaping(JSON?, Error?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/drive/items/\(id)")!)
        let task = MSURLSessionDataTask(request: request, client: client, completion: {
            (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                completion(JSON(data), nil)
            }
        })
        task?.execute()
    }
    
    
}
