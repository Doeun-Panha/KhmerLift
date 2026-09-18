//
//  GlassDropdownView.swift
//  KhmerLift
//
//  Created by Panha on 18/9/26.
//

import SwiftUI

enum DropdownItem: String, CaseIterable, Identifiable {
    case chest = "Chest"
    case shoulder = "Shoulder"
    case back = "Back"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearm = "Forearm"
    case abs = "Abs"
    case quads = "Quads"
    case glutes = "Glutes"
    case hamstring = "Hamstring"
    case calves = "Calves"
    
    var id: String { self.rawValue }
}

struct GlassDropdownView: View {
    let cornerRadius: CGFloat = 32.0
    let title: String
    let placeholder: String
    @Binding var selectedItem: DropdownItem?
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.nunito(16, weight: .semibold))
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Menu {
                ForEach(DropdownItem.allCases) { item in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedItem = item
                        }
                    }) {
                        HStack {
                            Text(item.rawValue)
                            if selectedItem == item {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedItem?.rawValue ?? placeholder)
                        .font(.nunito(16, weight: .semibold))
                        .foregroundStyle(selectedItem == nil ? .gray : .white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.black.opacity(0.10))
                        
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    isExpanded ? .cyan.opacity(0.8) : .white.opacity(0.3),
                                    .white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isExpanded ? 1.5 : 1.0
                        )
                )
            }
        }
    }
}

#Preview {
    ZStack {
        Image("background")
            .resizable()
            .ignoresSafeArea()
            
        GlassDropdownView(
            title: "Target Muscle",
            placeholder: "Select Muscle",
            selectedItem: .constant(.chest)
        )
        .padding()
    }
}
