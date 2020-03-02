import XCTest
@testable import BasementDriver

final class PasswordTests: XCTestCase {

  func testPassword() {
    let password = Password(hashing: "matching password")

    XCTAssertTrue(password.validate(against: "matching password"))
    XCTAssertFalse(password.validate(against: "non-matching password"))
  }

  func testRepassword() {
    let password = Password(Password(hashing: "matching password").description)

    XCTAssertTrue(password.validate(against: "matching password"))
    XCTAssertFalse(password.validate(against: "non-matching password"))
  }

  func testSalt() {
    let passwordOne = Password(hashing: "matching password")
    let passwordTwo = Password(hashing: "matching password")

    XCTAssertNotEqual(passwordOne, passwordTwo)
  }

  func testResalt() {
    let passwordOne = Password(hashing: "matching password", salt: "salt")
    let passwordTwo = Password(hashing: "matching password", salt: "salt")
    let passwordThree = Password(hashing: "matching password", salt: "pepper")

    XCTAssertEqual(passwordOne, passwordTwo)
    XCTAssertNotEqual(passwordTwo, passwordThree)
  }

}
