import Foundation

import PerfectHTTP

private let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()

  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  encoder.dateEncodingStrategy = .iso8601

  return encoder
}()

extension HTTPResponse {

  private func setBody<T>(encoding data: T) -> Self where T: Encodable {
    self
      .setBody(bytes: [UInt8](try! jsonEncoder.encode(data)))
  }

  func JSON<T>(encoding data: T, status: HTTPResponseStatus = .ok) where T: Encodable {
    self
      .setHeader(.contentType, value: "application/json")
      .setBody(encoding: data)
      .completed(status: status)
  }

}
