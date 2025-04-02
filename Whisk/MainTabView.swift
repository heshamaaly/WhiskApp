//
//  MainTabView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/28/25.
//
//
//  MainTabView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/28/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            RecipesView()
                .tabItem {
                    Label("My Recipes", systemImage: "list.bullet")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
