//
//  GlassTabBarView.swift
//  KhmerLift
//
//  Created by Panha on 18/9/26.
//

import SwiftUI

struct GlassTabBarView: View {
    @Binding var selectedTab: TabItem
    var onAddTapped: (() -> Void)? = nil
    
    @State private var touchX: CGFloat? = nil
    @State private var isDragging: Bool = false
    
    private let tabs = TabItem.allCases
    
    var body: some View {
        HStack(spacing: 10) {
            GeometryReader { proxy in
                let totalWidth = proxy.size.width
                let totalHeight = proxy.size.height
                let tabCount = max(1, CGFloat(tabs.count))
                let tabWidth = totalWidth / tabCount
                let currentIndex = tabs.firstIndex(of: selectedTab) ?? 0
                
                let pillWidth = max(0, tabWidth - 8)
                let pillHeight = max(0, totalHeight - 8)
                
                let idleOffset = CGFloat(currentIndex) * tabWidth
                
                let activeOffset: CGFloat = {
                    guard let touchX = touchX else { return idleOffset }
                    let centered = touchX - (tabWidth / 2)
                    let maxOffset = max(0, totalWidth - tabWidth)
                    return max(0, min(maxOffset, centered))
                }()
                
                let currentPillOffset = isDragging ? activeOffset : idleOffset
                
                let hoveredIndex = isDragging && touchX != nil
                    ? clampedIndex(for: touchX!, tabWidth: tabWidth)
                    : currentIndex
                
                ZStack(alignment: .leading) {
                    LiquidGlassPill()
                        .frame(width: pillWidth, height: pillHeight)
                        .scaleEffect(
                            x: isDragging ? 1.06 : 1.0,
                            y: isDragging ? 0.94 : 1.0
                        )
                        .offset(x: currentPillOffset + 4)
                        .animation(isDragging ? .interactiveSpring() : .spring(response: 0.35, dampingFraction: 0.72), value: currentPillOffset)
                        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: selectedTab)
                    
                    HStack(spacing: 0) {
                        ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
                            let isHighlighted = isDragging ? (hoveredIndex == index) : (selectedTab == tab)
                            
                            VStack(spacing: 4) {
                                Image(isHighlighted ? tab.selectedIcon : tab.unselectedIcon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                
                                Text(tab.title)
                                    .font(.nunito(10, weight: .semibold))
                            }
                            .foregroundStyle(isHighlighted ? .white : .white.opacity(0.5))
                            .frame(width: tabWidth, height: proxy.size.height)
                            .contentShape(Rectangle())
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            dismissKeyboard()
                            isDragging = true
                            touchX = value.location.x
                        }
                        .onEnded { value in
                            let targetIndex = clampedIndex(for: value.location.x, tabWidth: tabWidth)
                            
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                selectedTab = tabs[targetIndex]
                                touchX = nil
                                isDragging = false
                            }
                        }
                )
            }
            .frame(height: 68)
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 64, style: .continuous))
            
//            Button(action: {
//                onAddTapped?()
//            }) {
//                Image(systemName: "plus")
//                    .font(.system(size: 24, weight: .medium))
//                    .foregroundColor(.white)
//                    .frame(width: 68, height: 68)
//                    .contentShape(Circle())
//            }
//            .buttonStyle(.plain)
//            .glassEffect(.clear, in: Circle())
        }
        .padding(.horizontal)
    }
    
    private func clampedIndex(for xPosition: CGFloat, tabWidth: CGFloat) -> Int {
        guard tabWidth > 0 else { return 0 }
        let index = Int(xPosition / tabWidth)
        return max(0, min(tabs.count - 1, index))
    }
}

struct LiquidGlassPill: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0.35),
                        .white.opacity(0.14),
                        .white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.75),
                                .white.opacity(0.25),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.20), radius: 8, x: 0, y: 4)
    }
}
