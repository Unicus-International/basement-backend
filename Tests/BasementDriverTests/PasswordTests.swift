import XCTest
@testable import BasementDriver

final class PasswordTests: XCTestCase {

  func testPassword() {
    let password = Password(hashing: "matching password")

    XCTAssertTrue(password.validate(against: "matching password"), "Unable to validate a matching password")
    XCTAssertFalse(password.validate(against: "non-matching password"), "Validated a non-matching password")
  }

  func testRepassword() {
    let password = Password(Password(hashing: "matching password").description)

    XCTAssertTrue(password.validate(against: "matching password"), "Unable to validate a matching password")
    XCTAssertFalse(password.validate(against: "non-matching password"), "Validated a non-matching password")
  }

  func testSalt() {
    let passwordOne = Password(hashing: "matching password")
    let passwordTwo = Password(hashing: "matching password")

    XCTAssertNotEqual(passwordOne, passwordTwo, "Matching passwords with different salts match")
  }

  func testResalt() {
    let passwordOne = Password(hashing: "matching password", salt: "salt")
    let passwordTwo = Password(hashing: "matching password", salt: "salt")
    let passwordThree = Password(hashing: "matching password", salt: "pepper")

    XCTAssertEqual(passwordOne, passwordTwo, "Matching passwords with the same salt don't match")
    XCTAssertNotEqual(passwordTwo, passwordThree, "Matching passwords with different salts match")
  }

}
