//
//  GlassTextFieldView.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

struct GlassTextFieldView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(title)
                .font(.nunito(16, weight: .semibold))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundColor(.white)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                isFocused ? .cyan.opacity(0.8) : .white.opacity(0.3),
                                    .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isFocused ? 1.5 : 1.0
                    )
                    
            )
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var weightText = "75"
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                GlassTextFieldView(
                    title: "Input your bodyweight",
                    placeholder: "kg",
                    text: $weightText,
                    keyboardType: .decimalPad
                )
                .padding()
            }
        }
    }
    
    return PreviewContainer()
}
