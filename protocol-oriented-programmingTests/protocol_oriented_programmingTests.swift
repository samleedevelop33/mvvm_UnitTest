//
//  protocol_oriented_programmingTests.swift
//  protocol-oriented-programmingTests
//
//  Created by Mac on 2022/12/02.
//

import XCTest
@testable import protocol_oriented_programming//뜻: 이파일의 타겟은 다른파일이다

class protocol_oriented_programmingTests: XCTestCase {
    
    private var sut: UserViewModel!
    private var userService: MockUserService!
    private var output: MockUserViewOutput!
    
    override func setUpWithError() throws {
        output = MockUserViewOutput()
        userService = MockUserService()
        sut = UserViewModel(userService: userService)
        sut.output = output
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {//초기화
        sut = nil
        userService = nil
        try super.tearDownWithError()
    }
    
    func testUpdateView_onAPISuccess_showsImageAndEmail() {
        //given
        let user = User(id: 1, email: "me@gmail.com", avatar: "https://www.hi.com/2")
        userService.fetchUserMockResult = .success(user)
        //when
        sut.fetchUser()
        //then
        XCTAssertEqual(output.updateViewArray.count, 1)
        XCTAssertEqual(output.updateViewArray[0].email, "me@gmail.com")
        XCTAssertEqual(output.updateViewArray[0].imageUrl, "https://www.hi.com/2")
    }
    
    func testUpdateView_onAPIFailure_showsErrorImageAndDefaultNoUserFoundText() {
        //given
        userService.fetchUserMockResult = .failure(NSError())
        //when
        sut.fetchUser()
        //then
        XCTAssertEqual(output.updateViewArray.count, 1)
        XCTAssertEqual(output.updateViewArray[0].email, "No user found")
      //  XCTAssertEqual(output.updateViewArray[0].imageUrl, "")
    }
    
}

class MockUserService: UserService {
    var fetchUserMockResult: Result<User, Error>?
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
        if let result = fetchUserMockResult {
            completion(result)
        }
    }
}

class MockUserViewOutput: UserViewModelOutput {
    var updateViewArray: [(imageUrl: String, email: String)] = []
    func updateView(imageUrl: String, email: String) {
        updateViewArray.append((imageUrl, email))
    }
}
