import Foundation
import Security

class LocalStorage {
    static let shared = LocalStorage()

    private let userDefaults = UserDefaults.standard

    private init() {}

    // MARK: - Keychain (Secure Storage)

    func setAuthToken(_ token: String) {
        setKeychainValue(token, forKey: Constants.Storage.authTokenKey)
    }

    func getAuthToken() -> String? {
        return getKeychainValue(forKey: Constants.Storage.authTokenKey)
    }

    func setOrganizationId(_ orgId: String) {
        userDefaults.set(orgId, forKey: Constants.Storage.organizationIdKey)
    }

    func getOrganizationId() -> String? {
        return userDefaults.string(forKey: Constants.Storage.organizationIdKey)
    }

    func clearAuth() {
        deleteKeychainValue(forKey: Constants.Storage.authTokenKey)
        userDefaults.removeObject(forKey: Constants.Storage.organizationIdKey)
        userDefaults.removeObject(forKey: Constants.Storage.userIdKey)
    }

    // MARK: - Keychain Helpers

    private func setKeychainValue(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func getKeychainValue(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func deleteKeychainValue(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
