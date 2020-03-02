import Foundation

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
    self.password = hashPassword(password)
    self.email_address = emailAddress
  }

  func checkPassword(_ password: String) -> Bool {
    hashPassword(password, salt: self.password) == self.password
  }

}

private func hashPassword(_ password: String, salt: String? = nil) -> String {
  password
}
