//
//  MoreScreenView.swift
//  KhmerLift
//
//  Created by Panha on 25/9/26.
//

import SwiftUI

struct MoreScreenView: View {
    @State private var enableFaceID = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            headerView
            
            formContentView
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.leading, 10)
    }
    
    private var headerView: some View {
        HStack(spacing: 5) {
            Text("Settings")
                .font(.nunito(26, weight: .heavy))
                .foregroundStyle(.white)
            
            Spacer()
        }
        .padding(.top, 30)
    }
    
    private var formContentView: some View {
        VStack(spacing: 16) {
            GlassSwitchButtonView(
                title: "Security",
                name: "Biometric Face ID",
                isOn: $enableFaceID
            )
        }
    }
}

#Preview {
    MoreScreenView()
}
