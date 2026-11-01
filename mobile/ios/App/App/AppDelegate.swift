import UIKit
import Capacitor
import CallKit
import PushKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CXProviderDelegate, PKPushRegistryDelegate {

    var window: UIWindow?
    var callProvider: CXProvider?
    var activeCallUUID: UUID?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup CallKit Provider
        let config = CXProviderConfiguration(localizedName: "YChat")
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.generic]
        
        callProvider = CXProvider(configuration: config)
        callProvider?.setDelegate(self, queue: nil)

        // Setup PushKit for VoIP Push
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        return true
    }

    // MARK: - PushKit VoIP Delegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("VoIP Token: \(token)")
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        defer { completion() }
        guard type == .voIP else { return }

        let dict = payload.dictionaryPayload
        let caller = dict["caller"] as? String ?? "YChat Friend"
        let isVideo = (dict["type"] as? String) == "video"

        reportIncomingCall(caller: caller, isVideo: isVideo)
    }

    func reportIncomingCall(caller: String, isVideo: Bool) {
        let uuid = UUID()
        self.activeCallUUID = uuid

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: caller)
        update.hasVideo = isVideo
        update.localizedCallerName = caller

        callProvider?.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("Failed to report CallKit incoming call: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - CXProviderDelegate (Lock Screen Call Actions)
    func providerDidReset(_ provider: CXProvider) {
        activeCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // User answered call from lock screen
        action.fulfill()
        NotificationCenter.default.post(name: NSNotification.Name("YChatCallAnswered"), object: nil)
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // User declined call
        action.fulfill()
        activeCallUUID = nil
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}
