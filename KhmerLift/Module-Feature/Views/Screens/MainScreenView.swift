//
//  MainScreenView.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

// Model
struct MainScreenModel {
    let title: String
    let streak: Int
    let weight: Double
}

// ViewModel
@Observable
final class MainScreenViewModel {
    var title: String = "KhmerLift"
    var streak: Int = 0
    var weight: String = "75.0"
}

// View
struct MainScreenView: View {
    @State private var viewModel = MainScreenViewModel()
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .containerRelativeFrame([.horizontal, .vertical])
            
            VStack(alignment: .center, spacing: 5) {
                HStack(spacing: 5) {
                    Text(viewModel.title)
                        .font(.nunito(26, weight: .heavy))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(viewModel.streak)")
                        .font(.nunito(20, weight: .medium))
                        .foregroundColor(.gray)
                    Image("active-fire-icon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                }
                
                GlassTextFieldView(title: "Weight", placeholder: "kg", text: $viewModel.weight, keyboardType: .decimalPad)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }
}

#Preview {
    MainScreenView()
}
