import SwiftUI

enum APIError: LocalizedError {
    case offline, server(String)
    var errorDescription: String? {
        switch self {
        case .offline: return "No connection. Proofd needs the internet to read your photo."
        case .server(let m): return m
        }
    }
}

enum ProofdAPI {
    static let base = "https://proofd-api.hxu92521.workers.dev"

    struct DiagDTO: Decodable { var kind: String; var state: String; var verdict: String; var detail: String; var actions: [String]; var confidence: String }

    static func diagnose(image: Data, mode: String) async throws -> Diagnosis {
        let b64 = image.base64EncodedString()
        let body = try JSONSerialization.data(withJSONObject: ["image": b64, "mode": mode])
        let dto: DiagDTO = try await post("/v1/diagnose", body)
        return Diagnosis(kind: dto.kind, state: StarterState(rawValue: dto.state) ?? (mode == "crumb" ? .sluggish : .rising),
                         verdict: dto.verdict, detail: dto.detail, actions: dto.actions, confidence: dto.confidence)
    }

    struct AskDTO: Decodable { var answer: String }
    static func ask(_ question: String) async throws -> String {
        let body = try JSONSerialization.data(withJSONObject: ["question": question])
        let dto: AskDTO = try await post("/v1/ask", body)
        return dto.answer
    }

    private static func post<T: Decodable>(_ path: String, _ body: Data) async throws -> T {
        var req = URLRequest(url: URL(string: base + path)!)
        req.httpMethod = "POST"; req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body; req.timeoutInterval = 90
        let (data, resp): (Data, URLResponse)
        do { (data, resp) = try await URLSession.shared.data(for: req) }
        catch { throw APIError.offline }
        guard let http = resp as? HTTPURLResponse, http.statusCode < 300 else {
            let msg = (try? JSONDecoder().decode([String:String].self, from: data))?["error"] ?? "Something went wrong. Try a clearer photo."
            throw APIError.server(msg)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
