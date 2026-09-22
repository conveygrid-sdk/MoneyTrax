import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let profile: UserProfile

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var mobileNumber: String = ""
    @State private var showSavedAlert = false

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case fullName
        case email
        case mobileNumber
    }

    private var isValid: Bool {
        Validators.isValidName(fullName) &&
        Validators.isValidEmail(email) &&
        Validators.isValidMobile(mobileNumber)
    }

    var body: some View {
        Form {
            Section("Personal Information") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Full Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Full Name", text: $fullName)
                        .textContentType(.name)
                        .focused($focusedField, equals: .fullName)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .email
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Email")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .mobileNumber
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Mobile Number")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Mobile", text: $mobileNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .mobileNumber)
                }
            }

            Section {
                LabeledContent("Member Since") {
                    Text(profile.createdAt.mediumDateString)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    focusedField = nil
                    saveProfile()
                }
                .disabled(!isValid)
                .fontWeight(.semibold)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
            }
        }
        .onAppear {
            fullName = profile.fullName
            email = profile.email
            mobileNumber = profile.mobileNumber
        }
        .alert("Profile Updated", isPresented: $showSavedAlert) {
            Button("OK") { dismiss() }
        }
    }

    private func saveProfile() {
        profile.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        profile.mobileNumber = mobileNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.updatedAt = Date()

        try? modelContext.save()
        showSavedAlert = true
    }
}
