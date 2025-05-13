import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "clock.fill")
                }

            FriendsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                }

            SavedView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                }
        }
    }
}

