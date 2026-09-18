//
//  GlassTextFieldView.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

struct GlassTextFieldView: View {
    let cornerRadius: CGFloat = 32.0
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
                .foregroundStyle(.white)
            
            HStack {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .font(.nunito(16, weight: .semibold))
                        .foregroundStyle(.gray)
                )
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundStyle(.white)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        if let textField = obj.object as? UITextField {
                            textField.selectAll(nil)
                        }
                    }
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding()
            .background(
                ZStack {
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
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                    .containerRelativeFrame([.horizontal, .vertical])
                
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
