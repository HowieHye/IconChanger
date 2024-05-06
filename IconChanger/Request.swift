//
//  Request.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/28.
//  Modified by seril on 2023/7/25.
//

import Foundation
import AppKit
import AlgoliaSearchClient

class MyRequestController {
    func sendRequest(_ URL: URL) async throws -> NSImage? {
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Request (16) (GET https://media.macosicons.com/parse/files/macOSicons/acb24773e8384e032faf6b07704796d3_Spark_icon.icns)
         */
        
        if URL.isFileURL {
            return NSImage(byReferencing: URL)
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        // Headers
        
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        /* Start a new Task */
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return nil
        }
        
        return NSImage(data: data)
    }
}

class MyQueryRequestController {
    private var client: SearchClient!
    private var index: Index!
    
    init() {
        // 初始化Algolia客户端和索引
        let appId = ApplicationID(rawValue: UserDefaults.standard.string(forKey: "appID") ?? "P1TXH7ZFB3")
        let apiKey = APIKey(rawValue: UserDefaults.standard.string(forKey: "apiKey") ?? "766fcf8cd4746fa79b3d99852cfe8027")
        client = SearchClient(appID: appId, apiKey: apiKey)
        index = client.index(withName: "macOSicons")
    }
    
    func sendRequest(_ query: String) async throws -> [IconRes] {
        let query = qeuryMix(query)
        
        var searchQuery = Query(query)
        searchQuery.hitsPerPage = 100
        searchQuery.filters = "approved:true"
        searchQuery.page = 0
        do {
            let searchResult: SearchResponse = try await index.search(query: searchQuery)
            let res: [IconRes] = searchResult.hits.compactMap { hit in
                if case let .string(lowResPngUrlValue) = hit.object["lowResPngUrl"],
                   let lowResPngUrl = URL(string: lowResPngUrlValue),
                   case let .string(icnsUrlValue) = hit.object["icnsUrl"],
                   let icnsUrl = URL(string: icnsUrlValue),
                   case let .string(appName) = hit.object["appName"],
                   case let .number(downloadsNumber) = hit.object["downloads"],
                   let downloads = Int(exactly: downloadsNumber) {
                    return IconRes(appName: appName, icnsUrl: icnsUrl, lowResPngUrl: lowResPngUrl, downloads: downloads)
                } else {
                    print("Error parsing hit: \(hit)")
                    return nil
                }
            }
            
            return res
                .filter {
                    $0.appName.lowercased().replacingOccurrences(of: " ", with: "").contains(query.lowercased().replacingOccurrences(of: " ", with: ""))
                }
                .sorted { res1, res2 in
                    res1.downloads > res2.downloads
                }
            
        } catch {
            print("Error during search: \(error)")
            return []
        }
    }
    
    func qeuryMix(_ query: String) -> String {
        switch query {
        case "PyCharm Professional Edition": return "PyCharm"
        case "Discord PTB": return "Discord"
        default: return query
        }
    }
}
