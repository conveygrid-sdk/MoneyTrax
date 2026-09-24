import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        Group {
            if profiles.isEmpty && !appState.hasSkippedProfileCreation {
                OnboardingFlow()
                    .onAppear {
                        appState.selectedTab = .home
                    }
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: profiles.isEmpty)
        .animation(.easeInOut(duration: 0.3), value: appState.hasSkippedProfileCreation)
        .onChange(of: profiles.isEmpty) { _, isEmpty in
            if isEmpty {
                appState.selectedTab = .home
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var previousTab: AppState.AppTab = .home
    @Query private var profiles: [UserProfile]
    @Query private var expenses: [Expense]
    @Query private var incomes: [Income]

    private var isGuest: Bool { profiles.isEmpty }
    private var totalTransactions: Int { expenses.count + incomes.count }
    private var isLimitReached: Bool { isGuest && totalTransactions >= AppState.guestTransactionLimit }

    var body: some View {
        @Bindable var state = appState

        ZStack(alignment: .bottom) {
            TabView(selection: $state.selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(AppState.AppTab.home)

                TransactionsView()
                    .tabItem {
                        Label("Transactions", systemImage: "list.bullet.rectangle.fill")
                    }
                    .tag(AppState.AppTab.transactions)

                // Placeholder for center tab - actual action handled by onChange
                Color.clear
                    .tabItem {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .tag(AppState.AppTab.add)

                ReportsView()
                    .tabItem {
                        Label("Reports", systemImage: "chart.bar.fill")
                    }
                    .tag(AppState.AppTab.reports)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(AppState.AppTab.settings)
            }
            .tint(Color.appPrimary)
            .onChange(of: appState.selectedTab) { oldValue, newValue in
                if newValue == .add {
                    previousTab = oldValue
                    appState.selectedTab = previousTab
                    if isLimitReached {
                        appState.showCreateProfileSheet = true
                    } else {
                        appState.showAddActionSheet = true
                    }
                } else {
                    previousTab = newValue
                }
            }
        }
        .confirmationDialog("Add New", isPresented: Bindable(appState).showAddActionSheet) {
            Button("Add Expense") {
                if isLimitReached {
                    appState.showCreateProfileSheet = true
                } else {
                    appState.showAddExpenseSheet = true
                }
            }
            Button("Add Income") {
                if isLimitReached {
                    appState.showCreateProfileSheet = true
                } else {
                    appState.showAddIncomeSheet = true
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: Bindable(appState).showAddExpenseSheet) {
            AddExpenseView()
        }
        .sheet(isPresented: Bindable(appState).showAddIncomeSheet) {
            AddIncomeView()
        }
        .sheet(isPresented: Bindable(appState).showCreateProfileSheet) {
            NavigationStack {
                CreateProfileView(
                    isPresentedAsSheet: true,
                    reasonMessage: isLimitReached ? "Guest mode allows up to 3 transactions. Create your profile to enjoy unlimited expense and income tracking." : nil
                )
            }
        }
    }
}

// MARK: - Onboarding Flow

struct OnboardingFlow: View {
    @State private var showCreateProfile = false

    var body: some View {
        NavigationStack {
            if showCreateProfile {
                CreateProfileView()
            } else {
                WelcomeView(onGetStarted: {
                    withAnimation(.spring(response: 0.5)) {
                        showCreateProfile = true
                    }
                })
            }
        }
    }
}
