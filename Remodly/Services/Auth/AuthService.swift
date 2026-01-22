import Foundation
import SwiftUI
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?

    private let storage = LocalStorage.shared

    init() {
        checkExistingSession()
    }

    private func checkExistingSession() {
        if let token = storage.getAuthToken() {
            Task {
                await APIClient.shared.setAuthToken(token)
                if let orgId = storage.getOrganizationId() {
                    await APIClient.shared.setOrganizationId(orgId)
                }
                await fetchCurrentUser()
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            let request = LoginRequest(email: email, password: password)
            let response: LoginResponse = try await APIClient.shared.request(
                endpoint: .login,
                method: .post,
                body: request
            )

            storage.setAuthToken(response.token)
            storage.setOrganizationId(response.organizationId)

            await APIClient.shared.setAuthToken(response.token)
            await APIClient.shared.setOrganizationId(response.organizationId)

            currentUser = response.user
            isAuthenticated = true
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        storage.clearAuth()
        currentUser = nil
        isAuthenticated = false
        Task {
            await APIClient.shared.setAuthToken(nil)
            await APIClient.shared.setOrganizationId(nil)
        }
    }

    private func fetchCurrentUser() async {
        do {
            let user: User = try await APIClient.shared.request(endpoint: .me)
            currentUser = user
            isAuthenticated = true
        } catch {
            logout()
        }
    }
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let organizationId: String
    let user: User
}
