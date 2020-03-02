import PerfectCrypto

struct Password: CustomStringConvertible, Equatable {
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
      .flatMap({ $0.encode(.base64) })
      .flatMap({ String(validatingUTF8: $0) })!
  }

  var description: String {
    "$\(salt)$\(hash)"
  }

  func validate(against password: String) -> Bool {
    self == Password(hashing: password, salt: salt)
  }

  static func ==(a: Password, b: Password) -> Bool {
    a.hash == b.hash
  }

}

private extension Password {

  static func makeSalt(length: Int = 16) -> String {
    [UInt8](randomCount: length).encode(.base64).flatMap { String(validatingUTF8: $0) }!
  }

}
