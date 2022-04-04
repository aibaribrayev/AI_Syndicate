import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()

    private let container = Storage.storage()

    private init() {}

    public func getProfilePhotoPath(email: String) -> String {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        return "profile_pictures/\(path)/photo.png"
    }
    
    public func uploadUserProfilePicture(
        email: String,
        image: UIImage?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let pngData = image?.pngData() else {
            return
        }

        container
            .reference(withPath: getProfilePhotoPath(email: email))
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    public func downloadUrlForPostHeader(
        email: String,
        postId: String,
        completion: @escaping (URL?) -> Void){
        let emailComponent = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        container
            .reference(withPath: "post_headers/\(emailComponent)/\(postId).png")
            .downloadURL { url, _ in
                completion(url)
            }
    }
    public func downloadUrlForProfilePicture(
        email: String,
        completion: @escaping (URL?) -> Void
    ) {
        container.reference(withPath: getProfilePhotoPath(email: email))
            .downloadURL { url, _ in
                completion(url)
            }
    }
    
    
    public func uploadNewsPostHeaderImage(
        email: String,
        image: UIImage,
        postId: String,
        completion: @escaping (Bool) -> Void
    ){
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        guard let pngData = image.pngData() else {
            return
        }

        container
            .reference(withPath: "news_post_headers/\(path)/\(postId).png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                print("News Post Image posted")
                completion(true)
            }
    }
    public func downloadUrlForNewsPostHeader(
        email: String,
        postId: String,
        completion: @escaping (URL?) -> Void){
        let emailComponent = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        container
            .reference(withPath: "news_post_headers/\(emailComponent)/\(postId).png")
            .downloadURL { url, _ in
                completion(url)
            }
    }
    
    
    public func uploadBlogHeaderImage(
        email: String,
        image: UIImage,
        postId: String,
        completion: @escaping (Bool) -> Void
    ){
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        guard let pngData = image.pngData() else {
            return
        }

        container
            .reference(withPath: "post_headers/\(path)/\(postId).png")
            .putData(pngData, metadata: nil) { metadata, error in
                guard metadata != nil, error == nil else {
                    completion(false)
                    return
                }
                print("Start Up Image posted")
                completion(true)
            }
    }
    public func uploadVideo(
        email: String,
        videoURL: URL,
        postId: String,
        completion: @escaping (Bool) -> Void
    ){
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        let metaData = StorageMetadata()
        metaData.contentType = "video/quicktime"
        guard let data = try? Data(contentsOf: videoURL) else { return }
        Storage.storage()
            .reference(withPath: "post_headers/\(path)/\(postId).mov")
            .putData(data, metadata: metaData) { (metadata, error) in
            if error == nil {
                print("Successful video upload")
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    public func downloadUrlForVideo(
        email: String,
        postId: String,
        completion: @escaping (URL?) -> Void){
        let emailComponent = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        container
            .reference(withPath: "post_headers/\(emailComponent)/\(postId).mov")
            .downloadURL { url, _ in
                completion(url)
            }
    }
    public func uploadPDFFile(
        email: String,
        pdfFile: URL,
        postId: String,
        completion: @escaping (Bool) -> Void
    ){
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        let metaData = StorageMetadata()
        
        pdfFile.startAccessingSecurityScopedResource()
        guard let data = try? Data(contentsOf: pdfFile) else {
            pdfFile.stopAccessingSecurityScopedResource()
            return
        }
        pdfFile.stopAccessingSecurityScopedResource()
        Storage.storage()
            .reference(withPath: "post_headers/\(path)/\(postId).pdf")
            .putData(data, metadata: metaData) { (metadata, error) in
            if error == nil {
                print("Successful file upload")
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    public func downloadURLForPDFFile(
        email: String,
        postId: String,
        completion: @escaping (URL?) -> Void){
        let emailComponent = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        container
            .reference(withPath: "post_headers/\(emailComponent)/\(postId).pdf")
            .downloadURL { url, _ in
                completion(url)
            }
    }
}


