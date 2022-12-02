//
//  ViewController.swift
//  protocol-oriented-programming
//
//  Created by Mac on 2022/12/02.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fatchUsers()
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
    
    private func fatchUsers() {
        
        APIManager.shared.fetchUser { result in
            //협업시 이런식으로 작성하면 안됌
            switch result {
            case .success(let user):
                let imageData = try! NSData(contentsOf: .init(string: user.avatar)!) as Data//예제용임 SDWebImage같은걸 써주는게 보통
                self.imageView.image = UIImage(data: imageData)
                self.emailLabel.text = user.email
            case .failure:
                let imageUrlString = "https://cdn1.iconfinder.com/data/icons/user-fill-icons-set/144/User003_Error-512.png"
                let imageData = try! NSData(contentsOf: .init(string: imageUrlString)!) as Data//예제용임 SDWebImage같은걸 써주는게 보통
                self.imageView.image = UIImage(data: imageData)
                self.emailLabel.text = "No user found🤪"
            }
            
        }
    }
    
}

class APIManager {
    
    static let shared = APIManager()
    private init() {}
    
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
}

struct UserResponse: Decodable {
    let data: User
}

struct User: Decodable {
    let id: Int
    let email: String
    let avatar: String
}
