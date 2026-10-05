//
//  MoreScreenView.swift
//  KhmerLift
//
//  Created by Panha on 25/9/26.
//

import SwiftUI

struct MoreScreenView: View {
    @State private var enableFaceID = false
    @State private var navigateToFaceID = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 16) {
                headerView
                
                formContentView
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.leading, 10)
            .navigationDestination(isPresented: $navigateToFaceID) {
                FaceIDScreenView(
                    timer: .constant(10),
                    status: .constant("Looking for face...")
                )
            }
            .onChange(of: enableFaceID) { _, newValue in
                guard newValue else { return }
                
                Task {
                    try? await Task.sleep(for: .milliseconds(250))
                    navigateToFaceID = true
                }
            }
            .onChange(of: navigateToFaceID) { _, isPresented in
                if !isPresented {
                    enableFaceID = false
                }
            }
        }
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
        ScrollView {
            VStack(spacing: 16) {
                GlassSwitchButtonView(
                    title: "Security",
                    name: "Biometric Face ID",
                    isOn: $enableFaceID
                )
            }
        }
    }
}

#Preview {
    MoreScreenView()
}
