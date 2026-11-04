//
//  SectionHeaderView.swift
//  KhmerLift
//
//  Created by Panha on 3/11/26.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.nunito(18, weight: .bold))
                .foregroundStyle(.white)
                .tracking(1)
            Spacer()
        }
    }
}
