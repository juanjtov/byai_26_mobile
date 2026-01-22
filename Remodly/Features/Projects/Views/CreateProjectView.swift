import SwiftUI

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var address = ""
    @State private var homeownerName = ""
    @State private var homeownerEmail = ""
    @State private var homeownerPhone = ""
    @State private var notes = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Info") {
                    TextField("Project Name", text: $name)
                    TextField("Address", text: $address)
                }

                Section("Homeowner") {
                    TextField("Name", text: $homeownerName)
                    TextField("Email", text: $homeownerEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $homeownerPhone)
                        .keyboardType(.phonePad)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                if let error = error {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createProject()
                        }
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
        }
    }

    private func createProject() async {
        isLoading = true
        error = nil

        let request = CreateProjectRequest(
            name: name,
            address: address.isEmpty ? nil : address,
            homeownerName: homeownerName.isEmpty ? nil : homeownerName,
            homeownerEmail: homeownerEmail.isEmpty ? nil : homeownerEmail,
            homeownerPhone: homeownerPhone.isEmpty ? nil : homeownerPhone,
            notes: notes.isEmpty ? nil : notes
        )

        do {
            let _: Project = try await APIClient.shared.request(
                endpoint: .createProject,
                method: .post,
                body: request
            )
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}

struct CreateProjectRequest: Encodable {
    let name: String
    let address: String?
    let homeownerName: String?
    let homeownerEmail: String?
    let homeownerPhone: String?
    let notes: String?
}

#Preview {
    CreateProjectView()
}
