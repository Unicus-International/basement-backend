import Foundation

import PerfectCrypto

struct User: NamedFetchable, Addressable {
  let id: UUID

  let username: String
  let password: String

  let email_address: String

  static let sortingKey: PartialKeyPath<Self> = \.username
  static let defaultNamedKeyPath: KeyPath<Self, String> = \.username
}

extension User {

  @discardableResult
  static func newUser(username: String, password: String, emailAddress: String) throws -> User? {
    try Self(username: username, password: password, emailAddress: emailAddress)?.insert()
  }

  static func isRegisterable(username: String) throws -> Bool {
    try User.named(username) == nil
  }

  init?(username: String, password: String, emailAddress: String) throws {
    guard
      emailAddress.isLikelyEmail,
      try Self.isRegisterable(username: username)
    else {
      return nil
    }

    self.id = UUID()
    self.username = username
    self.password = Password(hashing: password).description
    self.email_address = emailAddress
  }

  func checkPassword(_ password: String) -> Bool {
    Password(self.password).validate(against: password)
  }

}

private struct Password: CustomStringConvertible {
  let salt: String
  let hash: String

  init(_ password: String) {
    let components = password.split(separator: "$")
    salt = String(components.first!)
    hash = String(components.last!)
  }

  init(hashing password: String, salt: String = Self.makeSalt()) {
    self.salt = salt
    self.hash = (salt + password)
      .digest(.sha256)
      .flatMap({ $0.encode(.hex) })
      .flatMap({ String(validatingUTF8: $0) })!
  }

  var description: String {
    "$\(salt)$\(hash)"
  }

  static func makeSalt(length: Int = 16) -> String {
    [UInt8](randomCount: length).encode(.hex).flatMap { String(validatingUTF8: $0) }!
  }

  func validate(against password: String) -> Bool {
    self.description == Password(hashing: password, salt: salt).description
  }
}
