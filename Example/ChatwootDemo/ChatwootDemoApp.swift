import SwiftUI
import ChatwootSDK
import UserNotifications

@main
struct ChatwootDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene { WindowGroup { DemoHome(model: DemoState.shared) } }
}
@MainActor
final class DemoState: ObservableObject {
    static let shared = DemoState()
    @Published var client: ChatwootClient?
    @Published var showingChat = false
    @Published var status = ""
    func configure(host: String, token: String) {
        guard let url = URL(string: host), ["http", "https"].contains(url.scheme), url.host != nil, !token.isEmpty else { status = "Enter a valid URL and SDK app identifier."; return }
        if let client, client.configuration.baseURL == url, client.configuration.sdkAppID == token { return }
        status = ""
        client?.pause()
        var configuration = ChatwootConfiguration(baseURL: url, sdkAppID: token)
        // Live Chat V2 preview palette. Omit these overrides to use inbox branding.
        configuration.accentColor = "#00ff9d"
        configuration.outgoingMessageColor = "#cee5d6"
        client = ChatwootClient(configuration: configuration)
    }
    func notification(_ payload: [AnyHashable: Any]) async {
        do { if try await client?.handleNotification(payload) == true { showingChat = true } }
        catch { status = error.localizedDescription }
    }
}
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        let host = UserDefaults.standard.string(forKey: "sdkHost") ?? "http://localhost:3127"
        let token = UserDefaults.standard.string(forKey: "sdkAppID") ?? ""
        DemoState.shared.configure(host: host, token: token)
        Task { @MainActor in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if [.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus) {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task { @MainActor in
            do {
                #if DEBUG
                let environment = "development"
                #else
                let environment = "production"
                #endif
                guard let client = DemoState.shared.client else { return }
                try await client.registerDeviceToken(deviceToken, environment: environment, name: UIDevice.current.name)
                DemoState.shared.status = "Push device registered."
            } catch { DemoState.shared.status = error.localizedDescription }
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) { DemoState.shared.status = error.localizedDescription }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Task { @MainActor in
            if notification.request.content.userInfo["chatwoot"] != nil {
                DemoState.shared.status = "Push received at \(Date().formatted(date: .omitted, time: .standard))."
            }
            completionHandler([.banner, .sound])
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Task { @MainActor in await DemoState.shared.notification(response.notification.request.content.userInfo); completionHandler() }
    }
}
struct DemoHome: View {
    @ObservedObject var model: DemoState
    @AppStorage("sdkHost") private var host = "http://localhost:3127"
    @AppStorage("sdkAppID") private var token = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("SDK app") {
                    TextField("Chatwoot URL", text: $host)
                    TextField("SDK app identifier", text: $token)
                    Button("Connect and open support") { model.configure(host: host, token: token); model.showingChat = model.client != nil }
                }.textInputAutocapitalization(.never).autocorrectionDisabled()
                Section("Push notifications") {
                    Button("Enable notifications") { Task {
                        do { if try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { UIApplication.shared.registerForRemoteNotifications() } else { model.status = "Notifications are disabled in Settings." } }
                        catch { model.status = error.localizedDescription }
                    } }.disabled(model.client == nil)
                }
                if !model.status.isEmpty { Section("Status") { Text(model.status) } }
                Button("Sign out and clear session", role: .destructive) { Task {
                    do { try await model.client?.reset(); model.status = "Session cleared." }
                    catch { model.status = error.localizedDescription }
                } }
            }.navigationTitle("Chatwoot SDK")
        }
        .sheet(isPresented: $model.showingChat) { if let client = model.client { ChatwootView(client: client) } }
    }
}
