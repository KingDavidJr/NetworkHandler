import Testing
import Foundation
@testable import NetworkHandler

//MARK: Setup TestNetworkHandler Environment

let mockNetworkHandler = NetworkHandler()

// Test this too
class NetworkHandlerMockURL: NetworkHandlerURLProtocol {
    var url: URL?
    var urlAsString: String?
    init(url: URL) {
        self.url = url
    }
    init (url: String) {
        self.urlAsString = url
    }
    
    func convertStringToURL() -> URL? {
        if let urlAsString = urlAsString {
            return URL(string: urlAsString)
        }
        return nil
    }
}

@Suite("Test GET Requests")
struct TestNetworkHandlerFetchMethods {
    
    let networkHandlerMockURL = NetworkHandlerMockURL(url: "https://postman-echo.com/get").convertStringToURL()
    
    @Test("Test Fetch Data")
    func testFetchData() async throws {
        if let networkHandlerMockURL {
            do {
                let data = try await mockNetworkHandler.fetchData(from: networkHandlerMockURL)
                if let data = data {
                    print(data)
                }
            }
        }
        #expect("Test" == "Test") // FIX THIS
    }
    
    @Test("Test Fetch Data with invalid URL")
    func testFetchDataWithInvalidURL() async throws {
        let _ = await #expect(throws: NetworkHandler.NetworkError.self) {
            try await mockNetworkHandler.fetchData(from: URL(filePath: "postman-echo.com/get")!)
        }
    }
}
