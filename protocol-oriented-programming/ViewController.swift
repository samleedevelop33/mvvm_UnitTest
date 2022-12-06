//
//  ViewController.swift
//  protocol-oriented-programming
//
//  Created by Mac on 2022/12/02.
//

import UIKit

protocol UserViewModelOutput: AnyObject {
    //✏️3)UserViewModel과 VC간의 소통(컨트랙트 페이퍼) 할 protocol : "talkBack"
    func updateView(imageUrl: String, email: String)
}

class UserViewModel {
    //✏️2)assign this(directly APICall) responsibility into VM
    
    weak var output: UserViewModelOutput?
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func fetchUser() {
        //[directly APICall]APIManager.shared.fetchUser~~~ : 이거대신에
        userService.fetchUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.output?.updateView(imageUrl: user.avatar, email: user.email)
            case .failure:
                let errorImageUrl = "https://cdn1.iconfinder.com/data/icons/user-fill-icons-set/144/User003_Error-512.png"
                self?.output?.updateView(imageUrl: errorImageUrl, email: "No user found")
            }
        }
    }
    
    //✏️3)이제 어떻게 VC가 VM이 바뀌는걸 감지하느냐 : 또 protocol(UserViewModelOutput) 사용
    
}

class ViewController: UIViewController, UserViewModelOutput {
    //✏️UIViewController는 View(보통:껍데기)와 Controller(보통:비즈니스로직)이 섞여있어보인다
    //  따라서 ViewModel을 추출(Extract)해야한다
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: UserViewModel//✏️1))의존성 주입(Dependency injection)
    init(viewModel: UserViewModel) {//*who is gonna supply your viewModel
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        //✏️3)VC에서는 VM바뀐걸 어떻게 받지 : delegate받으면됌😏
        self.viewModel.output = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchUsers()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.heightAnchor.constraint(equalToConstant: 56),
            emailLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4)
        ])
    }

    
    private func fetchUsers() {
        viewModel.fetchUser()
    }
//👹모든시작
//    private func fatchUsers() {
//        viewModel.fetchUser()
////        APIManager.shared.fetchUser { result in
////            //협업시 이런식으로 작성하면 안됌 > 해결책 : assign this responsibility into VM 2)✏️
////            switch result {
////            case .success(let user):
////                let imageData = try! NSData(contentsOf: .init(string: user.avatar)!) as Data//예제용임 SDWebImage같은걸 써주는게 보통
////                self.imageView.image = UIImage(data: imageData)
////                self.emailLabel.text = user.email
////            case .failure:
////                let imageUrlString = "https://cdn1.iconfinder.com/data/icons/user-fill-icons-set/144/User003_Error-512.png"
////                let imageData = try! NSData(contentsOf: .init(string: imageUrlString)!) as Data//예제용임 SDWebImage같은걸 써주는게 보통
////                self.imageView.image = UIImage(data: imageData)
////                self.emailLabel.text = "No user found🤪"
////            }
////
////        }
//    }
    
    //✏️3)
    //MARK: - UserViewModelOutput
    func updateView(imageUrl: String, email: String) {
        let imageData = try! NSData(contentsOf: .init(string: imageUrl)!) as Data//예제용임 SDWebImage같은걸 써주는게 보통
        self.imageView.image = UIImage(data: imageData)
        self.emailLabel.text = email
    }
    
}

protocol UserService {
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void)
}

class APIManager: UserService {
   
    
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "https://reqres.in/api/users/2")!
        
        URLSession.shared.dataTask(with: url) { data, res, error in
            guard let data = data else {return}
            DispatchQueue.main.async {
                if let user = try? JSONDecoder().decode(UserResponse.self, from: data).data {
                    completion(.success(user))
                } else {
                    completion(.failure(NSError()))
                }
            }
        }.resume()
    }
    
    func fetchPost() {
        
    }
}

struct UserResponse: Decodable {
    let data: User
}

struct User: Decodable {
    let id: Int
    let email: String
    let avatar: String
}
