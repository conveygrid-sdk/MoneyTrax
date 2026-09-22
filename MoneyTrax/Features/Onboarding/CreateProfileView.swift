import SwiftUI

struct CreateProfileView: View {
    @Environment(\.modelContext) private var modelContext
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
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 52))
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                        .padding(.bottom, 4)

                    Text("Create Your Profile")
                        .font(.title2.weight(.bold))

                    Text("Enter your details to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

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

                        TextField("Enter your mobile number", text: $viewModel.mobileNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .mobileNumber)
                            .padding()
                            .background(Color.elevatedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(viewModel.mobileError != nil ? Color.expenseRed : .clear, lineWidth: 1)
                            )
                            .accessibilityIdentifier("mobileField")

                        if let error = viewModel.mobileError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal, 4)

                // Continue Button
                Button(action: {
                    focusedField = nil
                    viewModel.createProfile(modelContext: modelContext)
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

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(
            Color(.systemBackground)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }
        )
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
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
