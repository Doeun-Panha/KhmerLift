//
//  GlassSwitchButtonView.swift
//  KhmerLift
//
//  Created by Panha on 25/9/26.
//

import SwiftUI

struct GlassSwitchButtonView: View {
    let cornerRadius: CGFloat = 32.0
    let title: String
    let name: String
    
    @Binding var isOn: Bool
    
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.nunito(16, weight: .semibold))
                .fontWeight(.bold)
                .foregroundStyle(.white)

            HStack {
                Text(name)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(Color(red: 0.35, green: 0.65, blue: 1.0))
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

#Preview {
    struct GlassSwitchPreviewContainer: View {
        @State private var enableSound = true
        @State private var enableFaceID = false

        var body: some View {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    GlassSwitchButtonView(
                        title: "Audio Settings",
                        name: "Sound Effects",
                        isOn: $enableSound
                    )

                    GlassSwitchButtonView(
                        title: "Security",
                        name: "Biometric Face ID",
                        isOn: $enableFaceID
                    )
                }
                .padding()
            }
        }
    }

    return GlassSwitchPreviewContainer()
}
