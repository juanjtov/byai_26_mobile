import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.obsidian
                    .ignoresSafeArea()

                VStack(spacing: RemodlySpacing.lg) {
                    Spacer()

                    // Logo
                    VStack(spacing: RemodlySpacing.sm) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.copper)
                            .copperGlow()

                        Text("Remodly")
                            .font(.remodlyLargeTitle)
                            .foregroundColor(.ivory)

                        Text("On-site remodeling estimates")
                            .font(.remodlySubhead)
                            .foregroundColor(.bodyText)
                    }

                    Spacer()

                    // Form
                    VStack(spacing: RemodlySpacing.md) {
                        RemodlyTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        RemodlySecureField(
                            placeholder: "Password",
                            text: $password
                        )

                        if let error = authService.error {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                Text(error)
                            }
                            .font(.remodlyCaption)
                            .foregroundColor(.errorText)
                        }

                        RemodlyButton(
                            title: "Sign In",
                            isLoading: authService.isLoading,
                            isDisabled: email.isEmpty || password.isEmpty
                        ) {
                            login()
                        }
                        .copperGlow(intensity: 0.3)
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Footer
                    Text("Version 1.0.0")
                        .font(.remodlyCaption)
                        .foregroundColor(.bodyText)
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func login() {
        Task {
            await authService.login(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
