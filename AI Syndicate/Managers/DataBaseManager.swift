import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let database = Firestore.firestore()

    private init() {}

    public func insert(
        NewsPost: NewsPost,
        email: String,
        completion: @escaping (Bool) -> Void){
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        let data: [String: Any] = [
            "id": NewsPost.identifier,
            "userEmail": NewsPost.userEmail,
            "dateTime": NewsPost.dateTime,
            "title": NewsPost.title,
            "caption": NewsPost.caption,
            "image": NewsPost.image?.absoluteString ?? "",
            "numberOfComments": NewsPost.numberOfComments,
            "numberOfLikes": NewsPost.numberOfLikes
        ]
        database
            .collection("users")
            .document(userEmail)
            .collection("news")
            .document(NewsPost.identifier)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    public func insert(
        Post: Post,
        email: String,
        completion: @escaping (Bool) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")

        let data: [String: Any] = [
            "id": Post.identifier,
            "userEmail": Post.userEmail,
            "dateTime": Post.dateTime,
            "title": Post.title,
            "caption": Post.caption,
            "image": Post.image?.absoluteString ?? "",
            "investmentAmount": Post.investmentAmount!,
            "numberOfComments": Post.numberOfComments!,
            "numberOfLikes": Post.numberOfLikes!,
            "numberOfInvestors": Post.numberOfInvestors!,
            "investedAmount": Post.investedAmount!
        ]

        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(Post.identifier)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    public func update(newsPost: NewsPost, amount: Int, completion: @escaping (Bool) -> Void = { _ in }) {
        let userEmail = newsPost.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection("news")
            .document(newsPost.identifier)
            .updateData(["numberOfLikes": amount]) { error in
                completion(error == nil)
            }
        
    }
    public func update(post: Post, data: [String: Any], completion: @escaping (Bool) -> Void = { _ in }) {
        let userEmail = post.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(post.identifier)
            .updateData(data) { error in
                completion(error == nil)
            }
        
    }
    
    public func getAllNewsPosts(
        completion: @escaping ([NewsPost]) -> Void
    ) {
        database
            .collection("users")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let emails: [String] = documents.compactMap({ $0["email"] as? String })
                print(emails)
                guard !emails.isEmpty else {
                    completion([])
                    return
                }

                let group = DispatchGroup()
                var result: [NewsPost] = []

                for email in emails {
                    group.enter()
                    self?.getNewsPosts(for: email) { userPosts in
                        defer {
                            group.leave()
                        }
                        result.append(contentsOf: userPosts)
                    }
                }

                group.notify(queue: .global()) {
                    print("Feed posts: \(result.count)")
                    completion(result)
                }
            }
    }
    public func getNewsPosts(
        for email: String,
        completion: @escaping ([NewsPost]) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection("news")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let newsPosts: [NewsPost] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String,
                          let userEmail = dictionary["userEmail"] as? String,
                          let datetime = dictionary["dateTime"] as? String,
                          let title = dictionary["title"] as? String,
                          let caption = dictionary["caption"] as? String,
                          let image = dictionary["image"] as? String,
                          let numberOfComments = dictionary["numberOfComments"] as? Int,
                          let numberOfLikes = dictionary["numberOfLikes"] as? Int else {
                        print("Invalid post fetch conversion")
                        return nil
                    }

                    let newsPost = NewsPost(
                        //createdBy: user,
                        identifier: id,
                        userEmail: userEmail,
                        dateTime: datetime,
                        title: title,
                        caption: caption,
                        image: URL(string: image),
                        numberOfComments: numberOfComments,
                        numberOfLikes: numberOfLikes
                    )
                    return newsPost
                })

                completion(newsPosts)
            }
    }
    public func getAllPosts(
        completion: @escaping ([Post]) -> Void
    ) {
        database
            .collection("users")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let emails: [String] = documents.compactMap({ $0["email"] as? String })
                print(emails)
                guard !emails.isEmpty else {
                    completion([])
                    return
                }

                let group = DispatchGroup()
                var result: [Post] = []

                for email in emails {
                    group.enter()
                    self?.getPosts(for: email) { userPosts in
                        defer {
                            group.leave()
                        }
                        result.append(contentsOf: userPosts)
                    }
                }

                group.notify(queue: .global()) {
                    print("Feed posts: \(result.count)")
                    completion(result)
                }
            }
    }

    public func getPosts(
        for email: String,
        completion: @escaping ([Post]) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let posts: [Post] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String,
                          let userEmail = dictionary["userEmail"] as? String,
                          let datetime = dictionary["dateTime"] as? String,
                          let title = dictionary["title"] as? String,
                          let caption = dictionary["caption"] as? String,
                          let image = dictionary["image"] as? String,
                          let investmentAmount = dictionary["investmentAmount"] as? Int,
                          let numberOfComments = dictionary["numberOfComments"] as? Int,
                          let numberOfLikes = dictionary["numberOfLikes"] as? Int,
                          let numberOfInvestors = dictionary["numberOfInvestors"] as? Int,
                          let investedAmount =  dictionary["investedAmount"] as? Int else {
                        print("Invalid post fetch conversion")
                        return nil
                    }

                    let post = Post(
                        //createdBy: user,
                        identifier: id,
                        userEmail: userEmail,
                        dateTime: datetime,
                        title: title,
                        caption: caption,
                        image: URL(string: image),
                        investmentAmount: investmentAmount,
                        numberOfComments: numberOfComments,
                        numberOfLikes: numberOfLikes,
                        numberOfInvestors: numberOfInvestors,
                        investedAmount: investedAmount
                    )
                    return post
                })

                completion(posts)
            }
    }

    public func insert(
        user: User,
        completion: @escaping (Bool) -> Void
    ) {
        let documentId = user.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")

        let data = [
            "email": user.email,
            "name": user.username,
            "typeOfUser": user.typeOfUser
        ]

        database
            .collection("users")
            .document(documentId)
            .setData(data) { error in
                completion(error == nil)
            }
    }

    public func getUser(
        email: String,
        completion: @escaping (User?) -> Void
    ) {
        let documentId = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")

        database
            .collection("users")
            .document(documentId)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() as? [String: String],
                      let name = data["name"],
                      let typeOfUser = data["typeOfUser"],
                      error == nil else {
                    return
                }

                let ref = data["profile_photo"]
                let user = User(username: name, email: email, typeOfUser: typeOfUser, profileImage: ref)
                completion(user)
            }
    }

    func updateProfilePhoto(
        email: String,
        completion: @escaping (Bool) -> Void
    ) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")

        let photoReference = "profile_pictures/\(path)/photo.png"

        let dbRef = database
            .collection("users")
            .document(path)

        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {
                return
            }
            data["profile_photo"] = photoReference

            dbRef.setData(data) { error in
                completion(error == nil)
            }
        }

    }
    public func likePost(postID: String, postType: String,completion: @escaping (Bool) -> Void = { _ in }){
        let currentUserEmail = currentUser!.email.replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        if(postType == "Новость"){
            database
                .collection("users")
                .document(currentUserEmail)
                .collection("liked_news")
                .document(postID).setData(["id": postID]){
                    error in
                    completion(error == nil)
                }
        }
        else{
            database
                .collection("users")
                .document(currentUserEmail)
                .collection("liked_startups")
                .document(postID).setData(["id": postID]){
                    error in
                    completion(error == nil)
                }
        }
    }
    public func unlikePost(postID: String, postType: String,completion: @escaping (Bool) -> Void = { _ in }){
        let currentUserEmail = currentUser!.email.replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        if(postType == "Новость"){
            database
                .collection("users")
                .document(currentUserEmail)
                .collection("liked_news")
                .document(postID)
                .delete()
        }
        else{
            database
                .collection("users")
                .document(currentUserEmail)
                .collection("liked_startups")
                .document(postID)
                .delete()
        }
    }
    public func getLikedNewsPostsID(
        completion: @escaping ([String]) -> Void
    ) {
        let userEmail = currentUser!.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection("liked_news")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let NewsID: [String] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    let ID = id
                    return ID
                })

                completion(NewsID)
            }
    }
    public func getLikedStartUpPostsID(
        completion: @escaping ([String]) -> Void
    ) {
        let userEmail = currentUser!.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection("liked_startups")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let startUpsID: [String] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    let startUpID = id
                    return startUpID
                })

                completion(startUpsID)
            }
    }
    public func addComment(post: DataPost, comment: Comment,completion: @escaping (Bool) -> Void = { _ in }){
        let userEmail = post.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        let data:[String: Any] = [
            "id": comment.identifier,
            "userEmail": comment.userEmail,
            "dateTime": comment.dateTime,
            "text": comment.text]
        database
            .collection("users")
            .document(userEmail)
            .collection(post.postType)
            .document(post.identifier)
            .collection("comments")
            .document(comment.identifier)
            .setData(data){ error in
                completion(error == nil)
            }
    }
    public func addReply(post: Post, comment: Comment, reply: Comment,completion: @escaping (Bool) -> Void = { _ in }){
        let userEmail = post.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        let data:[String: Any] = [
            "id": reply.identifier,
            "userEmail": reply.userEmail,
            "dateTime": reply.dateTime,
            "text": reply.text]
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(post.identifier)
            .collection("comments")
            .document(comment.identifier)
            .collection("replies")
            .document(reply.identifier)
            .setData(data){ error in
                completion(error == nil)
            }
    }
    public func getComments(
        for post: DataPost,
        completion: @escaping ([Comment]) -> Void
    ) {
        let userEmail = post.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection(post.postType)
            .document(post.identifier)
            .collection("comments")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let comments: [Comment] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String,
                          let userEmail = dictionary["userEmail"] as? String,
                          let dateTime = dictionary["dateTime"] as? String,
                          let text = dictionary["text"] as? String else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    let comment = Comment()
                    comment.identifier = id
                    comment.userEmail = userEmail
                    comment.dateTime = dateTime
                    comment.text = text
                    return comment
                })

                completion(comments)
            }
    }
    
    public func getReplies(for post: DataPost, completion: @escaping ([Comment]) -> Void) {
        let userEmail = post.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection(post.postType)
            .document(post.identifier)
            .collection("comments")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let comments: [Comment] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String,
                          let userEmail = dictionary["userEmail"] as? String,
                          let dateTime = dictionary["dateTime"] as? String,
                          let text = dictionary["text"] as? String else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    let comment = Comment()
                    comment.identifier = id
                    comment.userEmail = userEmail
                    comment.dateTime = dateTime
                    comment.text = text
                    return comment
                })

                completion(comments)
            }
    }
    
    public func getReply(
        for post: Post,
        comment: Comment,
        completion: @escaping ([Comment]) -> Void
    ) {
        let userEmail = post.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(post.identifier)
            .collection("comments")
            .document(comment.identifier)
            .collection("replies")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let comments: [Comment] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String,
                          let userEmail = dictionary["userEmail"] as? String,
                          let dateTime = dictionary["dateTime"] as? String,
                          let text = dictionary["text"] as? String else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    let comment = Comment()
                    comment.identifier = id
                    comment.userEmail = userEmail
                    comment.dateTime = dateTime
                    comment.text = text
                    comment.parentComment = comment
                    return comment
                })

                completion(comments)
            }
    }
    
    public func updateInvest(post: Post, amount: Int, completion: @escaping (Bool) -> Void = { _ in }) {
        let userEmail = post.userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        var numbOfInvestors = post.numberOfInvestors!
        if(currentUser?.investedStartUps.contains(post.identifier) == false){
            numbOfInvestors += 1
        }
        let sum = post.investedAmount! + amount
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(post.identifier)
            .updateData(["investedAmount": sum, "numberOfInvestors": numbOfInvestors]) { error in
                completion(error == nil)
            }
        let currentUserEmail = currentUser!.email.replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(currentUserEmail)
            .collection("invested_startups")
            .document(post.identifier).setData(["id": post.identifier, "investedAmount": amount, "autorEmail": userEmail]){
                error in
                completion(error == nil)
            }
    }

    public func getInvestedPostsIds(completion: @escaping ([String]) -> Void){
        let userEmail = currentUser?.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        database
            .collection("users")
            .document(userEmail!)
            .collection("invested_startups")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }

                let startUpsID: [String] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    let startUpID = id
                    return startUpID
                })

                completion(startUpsID)
            }
    }
    public func getInvestedPosts(completion: @escaping ([Post]) -> Void){
        getAllPosts(){ [weak self] allposts in
            var posts: [Post] = []
            for post in allposts{
                if(currentUser?.investedStartUps.contains(post.identifier) == true){
                    posts.append(post)
                    print(post.identifier)
                }
            }
            completion(posts)
        }
    }
    public func getLikedStartUpPosts(completion: @escaping ([Post]) -> Void){
        getAllPosts(){ [weak self] allposts in
            var posts: [Post] = []
            for post in allposts {
                if(currentUser?.likedStartUpPostIds.contains(post.identifier) == true){
                    posts.append(post)
                }
            }
            completion(posts)
        }
    }
    public func getLikedNewsPosts(completion: @escaping ([NewsPost]) -> Void){
        getAllNewsPosts(){ [weak self] allposts in
            var posts: [NewsPost] = []
            for post in allposts{
                if(currentUser?.likedNewsPostIds.contains(post.identifier) == true){
                    posts.append(post)
                }
            }
            completion(posts)
        }
    }
    public func getUserInvestedAmount(postId: String,completion: @escaping (Int) -> Void){
        
        let userEmail = currentUser?.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        /*database
            .collection("users")
            .document(userEmail!)
            .collection("invested_startups")
            .document(postId)
            .getData(){
                
            }
         */
    }
}
