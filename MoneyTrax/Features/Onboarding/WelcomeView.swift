import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void

    @State private var animateIcon = false
    @State private var animateText = false
    @State private var animateButton = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.22),
                    Color(red: 0.14, green: 0.20, blue: 0.50),
                    Color(red: 0.18, green: 0.34, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // App icon
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.12))
                            .frame(width: 140, height: 140)

                        Circle()
                            .fill(.white.opacity(0.18))
                            .frame(width: 110, height: 110)

                        Image(systemName: "indianrupeesign.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, options: .repeating, value: animateIcon)
                    }
                    .scaleEffect(animateIcon ? 1.0 : 0.6)
                    .opacity(animateIcon ? 1.0 : 0)

                    VStack(spacing: 12) {
                        Text("MoneyTrax")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(AppConstants.appTagline)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)
                }

                Spacer()

                // Features preview
                VStack(spacing: 16) {
                    featureRow(icon: "chart.pie.fill", text: "Track daily expenses effortlessly")
                    featureRow(icon: "arrow.up.arrow.down.circle.fill", text: "Monitor income and expenses")
                    featureRow(icon: "lock.shield.fill", text: "All data stored locally on device")
                }
                .opacity(animateText ? 1.0 : 0)

                Spacer()

                // Get Started button
                Button(action: onGetStarted) {
                    HStack(spacing: 10) {
                        Text("Get Started")
                            .font(.title3.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.title3.weight(.semibold))
                    }
                    .foregroundStyle(Color(red: 0.14, green: 0.20, blue: 0.50))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .white.opacity(0.3), radius: 20, y: 8)
                }
                .opacity(animateButton ? 1.0 : 0)
                .offset(y: animateButton ? 0 : 30)
                .padding(.horizontal, 4)
                .accessibilityIdentifier("getStartedButton")

                Spacer()
                    .frame(height: 20)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.4)) {
                animateText = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7)) {
                animateButton = true
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 32)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            Spacer()
        }
        .padding(.horizontal, 8)
    }
}
