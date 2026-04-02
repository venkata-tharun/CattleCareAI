import Foundation

/// Central manager for local user session data stored in UserDefaults.
/// All reads and writes to session-related keys go through here.
enum SessionManager {

    private static let keyUserName   = "userName"
    private static let keyFarmName   = "farmName"
    private static let keyUserEmail  = "userEmail"
    private static let keyUserId     = "userId"
    private static let keyIsLoggedIn = "isLoggedIn"

    // MARK: - Save

    /// Persists user profile to UserDefaults after a successful login.
    static func saveSession(user: UserProfile) {
        let ud = UserDefaults.standard
        ud.set(user.full_name,        forKey: keyUserName)
        ud.set(user.farm_name,        forKey: keyFarmName)
        ud.set(user.email_or_phone,   forKey: keyUserEmail)
        ud.set(user.id,               forKey: keyUserId)
        ud.set(true,                  forKey: keyIsLoggedIn)
    }

    // MARK: - Read

    static var userName:  String { UserDefaults.standard.string(forKey: keyUserName) ?? "" }
    static var farmName:  String { UserDefaults.standard.string(forKey: keyFarmName) ?? "" }
    static var userEmail: String { UserDefaults.standard.string(forKey: keyUserEmail) ?? "" }
    static var userId:    Int    { UserDefaults.standard.integer(forKey: keyUserId) }

    /// Quick local check — the source of truth is still the server `/api/auth/me` call.
    static var hasLocalSession: Bool {
        UserDefaults.standard.bool(forKey: keyIsLoggedIn)
    }

    // MARK: - Clear

    /// Removes all local session data. Call on logout or account deletion.
    static func clearLocalSession() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: keyUserName)
        ud.removeObject(forKey: keyFarmName)
        ud.removeObject(forKey: keyUserEmail)
        ud.removeObject(forKey: keyUserId)
        ud.removeObject(forKey: keyIsLoggedIn)
        clearServerCookies()
    }

    // MARK: - Cookie Cleanup

    /// Deletes the Flask session cookie so the server side session is gone too.
    static func clearServerCookies() {
        let storage = HTTPCookieStorage.shared
        let baseURL = NetworkManager.shared.baseURL
        if let url = URL(string: baseURL),
           let cookies = storage.cookies(for: url) {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
        // Belt-and-suspenders: also nuke every cookie with the server host
        if let hostURL = URL(string: baseURL), let host = hostURL.host {
            storage.cookies?.filter { $0.domain.contains(host) }.forEach {
                storage.deleteCookie($0)
            }
        }
    }
}
