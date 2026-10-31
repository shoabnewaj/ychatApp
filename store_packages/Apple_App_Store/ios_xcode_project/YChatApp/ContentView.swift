import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        YChatWebView(urlString: "http://3.26.151.171:8080/")
            .edgesIgnoringSafeArea(.all)
    }
}

struct YChatWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Persistent cookie sync
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            if url.scheme == "tel" || url.scheme == "mailto" || url.scheme == "sms" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
