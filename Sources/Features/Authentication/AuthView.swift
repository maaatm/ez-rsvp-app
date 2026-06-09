import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(SessionStore.self) private var session

    @State private var email = ""
    @State private var loading: String? = nil
    @State private var error: String?
    @State private var currentNonce: String?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.xl) {
                Spacer(minLength: 40)

                VStack(spacing: Theme.Space.lg) {
                    MysteryBox(size: 120)
                    VStack(spacing: 6) {
                        Text("Say yes first.")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                        Text("Sign in to claim your mystery experience.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: 12) {
                    if AppConfig.useFirebase {
                        // Production: native Sign in with Apple → ASAuthorization →
                        // Firebase credential (with a secure nonce).
                        SignInWithAppleButton(.signIn) { request in
                            let nonce = AppleSignIn.newNonce()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = AppleSignIn.sha256(nonce)
                        } onCompletion: { result in
                            handleAppleCompletion(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 52)
                        .clipShape(Capsule())
                    } else {
                        // Demo: reliable custom Apple-styled button.
                        Button {
                            signIn(.apple, label: "apple", name: "Apple User")
                        } label: {
                            HStack {
                                if loading == "apple" { ProgressView().tint(.white) }
                                else { Image(systemName: "apple.logo") }
                                Text("Sign in with Apple").fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Theme.ink, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(loading != nil)
                    }

                    authButton("Continue with Google", systemImage: "g.circle.fill", id: "google") {
                        signIn(.google, label: "google", name: "Alex Rivera")
                    }

                    HStack {
                        line; Text("or").font(.caption).foregroundStyle(.secondary); line
                    }

                    VStack(spacing: 10) {
                        TextField("you@email.com", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 16).frame(height: 52)
                            .glass(cornerRadius: Theme.Radius.pill)

                        Button {
                            signIn(.email(email), label: "email", name: nil)
                        } label: {
                            if loading == "email" {
                                ProgressView().tint(.white)
                            } else {
                                Text("Continue with Email")
                            }
                        }
                        .buttonStyle(.primary)
                        .disabled(!email.contains("@") || loading != nil)
                    }
                }
                .padding(Theme.Space.lg)
                .glass(cornerRadius: Theme.Radius.lg, strong: true)

                if AppConfig.useFirebase == false {
                    Label("Demo mode — any sign-in drops you into a live account.",
                          systemImage: "sparkles")
                        .font(.caption).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, Theme.Space.lg)
        }
        .scrollBounceBehavior(.basedOnSize)
        .alert("Sign-in failed", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: { Text(error ?? "") }
    }

    private var line: some View {
        Rectangle().fill(Theme.hairline).frame(height: 1)
    }

    private func authButton(_ title: String, systemImage: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                if loading == id { ProgressView().tint(Theme.ink) }
                else { Image(systemName: systemImage).font(.title3) }
                Text(title)
            }
        }
        .buttonStyle(.secondary)
        .disabled(loading != nil)
    }

    private func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let err):
            // User cancellation isn't an error worth surfacing.
            if (err as? ASAuthorizationError)?.code != .canceled {
                error = err.localizedDescription
            }
        case .success(let auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                error = "Couldn't read your Apple credentials. Please try again."
                return
            }
            let name = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }.joined(separator: " ")
            loading = "apple"
            Task {
                do {
                    try await session.signInWithApple(
                        idTokenString: idToken,
                        rawNonce: nonce,
                        fullName: name.isEmpty ? nil : name
                    )
                    Haptics.notify(.success)
                } catch {
                    self.error = error.localizedDescription
                    Haptics.notify(.error)
                }
                loading = nil
            }
        }
    }

    private func signIn(_ provider: AuthProvider, label: String, name: String?) {
        guard loading == nil else { return }
        loading = label
        Haptics.impact(.light)
        Task {
            do {
                try await session.signIn(with: provider, displayName: name)
                Haptics.notify(.success)
            } catch {
                self.error = error.localizedDescription
                Haptics.notify(.error)
            }
            loading = nil
        }
    }
}
