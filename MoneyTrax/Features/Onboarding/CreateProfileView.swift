import SwiftUI

struct CreateProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var isPresentedAsSheet: Bool = false
    var reasonMessage: String? = nil

    @StateObject private var viewModel = CreateProfileViewModel()
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case fullName
        case email
        case mobileNumber
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Limit Reached / Reason Callout Banner
                if let reason = reasonMessage {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Profile Required")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.primary)
                            Text(reason)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.3), lineWidth: 1)
                    )
                    .padding(.top, 16)
                }

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 52))
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                        .padding(.bottom, 4)

                    Text(reasonMessage != nil ? "Complete Your Profile" : "Create Your Profile")
                        .font(.title2.weight(.bold))

                    Text("Enter your details to enjoy unlimited tracking")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, reasonMessage == nil ? 24 : 8)

                // Form
                VStack(spacing: 20) {
                    // Full Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Full Name")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        TextField("Enter your full name", text: $viewModel.fullName)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .fullName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .email
                            }
                            .padding()
                            .background(Color.elevatedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(viewModel.fullNameError != nil ? Color.expenseRed : .clear, lineWidth: 1)
                            )
                            .accessibilityIdentifier("fullNameField")

                        if let error = viewModel.fullNameError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        TextField("Enter your email", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .mobileNumber
                            }
                            .padding()
                            .background(Color.elevatedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(viewModel.emailError != nil ? Color.expenseRed : .clear, lineWidth: 1)
                            )
                            .accessibilityIdentifier("emailField")

                        if let error = viewModel.emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    // Mobile Number
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mobile Number")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        HStack {
                            TextField("Enter your mobile number", text: $viewModel.mobileNumber)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                                .focused($focusedField, equals: .mobileNumber)
                                .accessibilityIdentifier("mobileField")

                            if focusedField == .mobileNumber {
                                Button {
                                    focusedField = nil
                                    hideKeyboard()
                                } label: {
                                    Text("Done")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.12))
                                        .clipShape(Capsule())
                                }
                                .accessibilityIdentifier("inlineDoneButton")
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding()
                        .background(Color.elevatedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(viewModel.mobileError != nil ? Color.expenseRed : .clear, lineWidth: 1)
                        )

                        if let error = viewModel.mobileError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                            hideKeyboard()
                        }
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                        .accessibilityIdentifier("keyboardDoneButton")
                    }
                }

                // Continue Button
                Button(action: {
                    focusedField = nil
                    hideKeyboard()
                    viewModel.createProfile(modelContext: modelContext) {
                        appState.showCreateProfileSheet = false
                        appState.selectedTab = .home
                        if isPresentedAsSheet {
                            dismiss()
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        viewModel.isFormValid ?
                            Color(red: 0.18, green: 0.34, blue: 0.96) :
                            Color.gray.opacity(0.4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .accessibilityIdentifier("continueButton")

                // Skip Button (Visible during onboarding)
                if !isPresentedAsSheet {
                    Button(action: {
                        focusedField = nil
                        hideKeyboard()
                        appState.skipProfileCreation()
                    }) {
                        Text("Skip for Now")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }
                    .accessibilityIdentifier("skipForNowButton")
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
                hideKeyboard()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Color(.systemBackground)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                    hideKeyboard()
                }
        )
        .toolbar {
            if isPresentedAsSheet {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.body)
                }
            }
        }
        .navigationBarBackButtonHidden(viewModel.isLoading)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
