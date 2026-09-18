//
//  GlassTabBarView.swift
//  KhmerLift
//
//  Created by Panha on 18/9/26.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case progress
    case more
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .progress: return "Progress"
        case .more: return "More"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home: return "home-selected-icon"
        case .progress: return "progress-selected-icon"
        case .more: return "more-selected-icon"
        }
    }
    
    var unselectedIcon: String {
        switch self {
        case .home: return "home-unselected-icon"
        case .progress: return "progress-unselected-icon"
        case .more: return "more-unselected-icon"
        }
    }
}

struct GlassTabBarView: View {
    @Binding var selectedTab: TabItem
    var onAddTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 10) {
            HStack {
                ForEach(TabItem.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(selectedTab == tab ? tab.selectedIcon : tab.unselectedIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                            
                            Text(tab.title)
                                .font(.nunito(10, weight: .semibold))
                        }
                        .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Group {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                                        .fill(Color.white.opacity(0.15))
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 64, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            
            Button(action: {
                onAddTapped?()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 64, height: 64)
                    .background(Color(red: 0.35, green: 0.65, blue: 1.0))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    struct GlassTabBarPreviewContainer: View {
        @State private var selectedTab: TabItem = .home
        
        var body: some View {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                    .containerRelativeFrame([.horizontal, .vertical])
                
                VStack {
                    Spacer()
                    
                    GlassTabBarView(selectedTab: $selectedTab)
                }
                .padding(.bottom, 10)
            }
        }
    }
    
    return GlassTabBarPreviewContainer()
}
