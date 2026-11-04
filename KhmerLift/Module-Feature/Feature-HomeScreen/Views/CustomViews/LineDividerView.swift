//
//  LineDividerView.swift
//  KhmerLift
//
//  Created by Panha on 3/11/26.
//

import SwiftUI

struct LineDividerView: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(height: 1)
            .padding(.vertical, 8)
    }
}
