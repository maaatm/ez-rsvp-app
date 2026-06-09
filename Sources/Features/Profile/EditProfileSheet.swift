import SwiftUI
import PhotosUI

/// Lets the signed-in user edit the basics: profile photo, display name,
/// @username, and a short bio. Photo is picked via PhotosPicker and persisted
/// locally by the session.
struct EditProfileSheet: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var username = ""
    @State private var bio = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?   // freshly chosen, not yet saved

    private let bioLimit = 150

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Space.lg) {
                    photoPicker
                    fields
                    saveButton
                }
                .padding(Theme.Space.lg)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(GradientBackground())
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear(perform: loadCurrent)
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    pickedImage = image
                    Haptics.selection()
                }
            }
        }
    }

    // MARK: Photo

    private var photoPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
            ZStack(alignment: .bottomTrailing) {
                avatarPreview
                Image(systemName: "camera.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Theme.brandGradient, in: Circle())
                    .overlay(Circle().strokeBorder(Theme.background, lineWidth: 3))
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var avatarPreview: some View {
        if let pickedImage {
            Image(uiImage: pickedImage)
                .resizable().scaledToFill()
                .frame(width: 104, height: 104)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
        } else if let user = session.currentUser {
            AvatarView(user: user, size: 104)
        } else {
            Circle().fill(Theme.surfaceSunken).frame(width: 104, height: 104)
        }
    }

    // MARK: Fields

    private var fields: some View {
        VStack(spacing: Theme.Space.md) {
            field(title: "Name") {
                TextField("Your name", text: $name)
                    .textContentType(.name)
            }
            field(title: "Username") {
                HStack(spacing: 2) {
                    Text("@").foregroundStyle(.secondary)
                    TextField("username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: username) { _, new in
                            username = AppUser.sanitizeUsername(new) ?? ""
                        }
                }
            }
            field(title: "Bio") {
                VStack(alignment: .trailing, spacing: 4) {
                    TextField("Say something about yourself…", text: $bio, axis: .vertical)
                        .lineLimit(2...4)
                        .onChange(of: bio) { _, new in
                            if new.count > bioLimit { bio = String(new.prefix(bioLimit)) }
                        }
                    Text("\(bio.count)/\(bioLimit)")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold)).tracking(1).foregroundStyle(.secondary)
            content()
                .font(.body)
                .padding(.horizontal, 16).padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glass(cornerRadius: Theme.Radius.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var saveButton: some View {
        Button {
            if let pickedImage, let data = pickedImage.jpegData(compressionQuality: 0.85) {
                session.setProfilePhoto(data)
            }
            session.updateProfile(name: name, username: username, bio: bio)
            Haptics.notify(.success)
            dismiss()
        } label: {
            Label("Save profile", systemImage: "checkmark")
        }
        .buttonStyle(.primary)
        .disabled(!canSave)
        .padding(.top, 4)
    }

    private func loadCurrent() {
        guard let user = session.currentUser else { return }
        name = user.name
        username = user.username ?? ""
        bio = user.bio ?? ""
    }
}
