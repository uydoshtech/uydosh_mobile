import Foundation

public enum APIError: Error, Equatable {
    case invalidResponse
    case httpStatus(Int)
    case notFound
    case decoding(String)
    case network(String)
}

/// Minimal JSON HTTP client shared between the App Clip and (later) the full
/// app's native code. Exact routes live in `ScanSessionAPI` so they can change
/// without touching call sites.
///
/// @unchecked Sendable: the decoder/encoder are configured once in init and
/// never mutated afterwards.
public final class APIClient: @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(baseURL: URL = AppClipConfig.apiBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = APIClient.iso8601Fractional.date(from: raw) ?? APIClient.iso8601.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized ISO8601 date: \(raw)"
            )
        }
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    private static let iso8601: ISO8601DateFormatter = ISO8601DateFormatter()
    private static let iso8601Fractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public func get<Response: Decodable>(_ path: String, headers: [String: String] = [:]) async throws -> Response {
        try await send(path: path, method: "GET", body: nil as Data?, headers: headers)
    }

    public func post<Body: Encodable, Response: Decodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> Response {
        let data = try encoder.encode(body)
        return try await send(path: path, method: "POST", body: data, headers: headers)
    }

    private func send<Response: Decodable>(
        path: String,
        method: String,
        body: Data?,
        headers: [String: String]
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = body
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        switch http.statusCode {
        case 200...299:
            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw APIError.decoding(String(describing: error))
            }
        case 404:
            throw APIError.notFound
        default:
            throw APIError.httpStatus(http.statusCode)
        }
    }
}
