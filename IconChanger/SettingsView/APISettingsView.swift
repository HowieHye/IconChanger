//
//  APISettingsView.swift
//  IconChanger
//
//  Created by Hugh on 2024/5/2.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var url: URL
    var onReceivedValues: ((String, String) -> Void)?  // 添加一个回调闭包来传递解析的值

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onReceivedValues: onReceivedValues)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var onReceivedValues: ((String, String) -> Void)?  // 存储回调闭包

        init(onReceivedValues: ((String, String) -> Void)?) {
            self.onReceivedValues = onReceivedValues
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let js = """
            document.querySelector('link[rel="modulepreload"][href*="IconDialog"]').getAttribute('href')
            """
            webView.evaluateJavaScript(js) { [weak self] (result, error) in
                guard let href = result as? String else { return }
                self?.downloadAndParseJavaScript(href: href)
                print(href)
            }
        }

        func downloadAndParseJavaScript(href: String) {
            guard let url = URL(string: href) else { return }
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil,
                      let fileContent = String(data: data, encoding: .utf8) else { return }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.parseJavaScriptContent(fileContent: fileContent)
                }
            }
            task.resume()
        }

        func parseJavaScriptContent(fileContent: String) {
            print(fileContent)
            let pattern = "y\\(\"([^\"]+)\",\"([^\"]+)\"\\);"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let nsrange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
            if let match = regex?.firstMatch(in: fileContent, options: [], range: nsrange),
               let firstRange = Range(match.range(at: 1), in: fileContent),
               let secondRange = Range(match.range(at: 2), in: fileContent) {
                let firstValue = String(fileContent[firstRange])
                let secondValue = String(fileContent[secondRange])
                
                print(firstValue)
                print(secondValue)
                
                DispatchQueue.main.async {
                    self.onReceivedValues?(firstValue, secondValue)
                }
            }
        }
    }
}

struct APISettingsView: View {
    @AppStorage("appID") private var appID: String = ""
    @AppStorage("apiKey") private var apiKey: String = ""
    @State private var isLoading: Bool = false
    @State private var showWebView: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                HStack{
                    Text("App ID:")
                        .frame(width: 60)
                    TextField("App ID", text: $appID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack{
                    Text("API Key:")
                        .frame(width: 60)
                    TextField("API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .frame(minWidth: 300, minHeight: 100)
            
            if showWebView {
                WebView(url: URL(string: "https://macosicons.com/#/")!, onReceivedValues: { id, key in
                    self.appID = id
                    self.apiKey = key
                    self.isLoading = false
                    self.showWebView = false  // 确保在弹出确认框后关闭 WebView
                    self.showAlert(title: "获取成功", message: "已成功获取到 App ID 和 API Key。")
                })
                .frame(width: 0, height: 0)
            }
            
            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .frame(height: 100)

            Button("Fetch Data") {
                isLoading = true
                showWebView = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
        .frame(minWidth: 300, minHeight: 300)
    }

    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}

#Preview {
    APISettingsView()
}
