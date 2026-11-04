//
//  GlassDropdownView.swift
//  KhmerLift
//
//  Created by Panha on 18/9/26.
//

import SwiftUI

struct GlassDropdownConfig<T: SelectableItem> {
    let title: String
    let placeholder: String
    let items: [T]
    var isDisabled: Bool = false
    let onAddNew: () -> Void
}

struct GlassDropdownView<T: SelectableItem>: View {
    let config: GlassDropdownConfig<T>
    @Binding var selection: T?
        
    @State private var isShowingSheet: Bool = false
    
    var body: some View {
        containerView
    }
}

extension GlassDropdownView {
    private var containerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(config.title)
                .font(.nunito(16, weight: .semibold))
                .foregroundStyle(.white)
            
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                isShowingSheet = true
            }) {
                HStack {
                    Text(selection?.displayName ?? config.placeholder)
                        .font(.nunito(16, weight: .semibold))
                        .foregroundStyle(selection == nil ? .white.opacity(0.5) : .white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.nunito(16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding()
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
            .disabled(config.isDisabled)
            .opacity(config.isDisabled ? 0.5 : 1.0)
        }
        
        .sheet(isPresented: $isShowingSheet) {
            sheet
        }
    }
    
    private var sheet: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Text("Select \(config.title)")
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding([.top, .horizontal], 20)
            
            Divider()
                .background(.white.opacity(0.4))
                .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(config.items) { item in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selection = item
                                isShowingSheet = false
                            }
                        }) {
                            HStack {
                                Text(item.displayName)
                                    .font(.nunito(16, weight: .medium))
                                    .foregroundStyle(.white)
                                Spacer()
                                if selection == item {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.cyan)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            
            VStack {
                Button(action: {
                    isShowingSheet = false
                    config.onAddNew()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add New \(config.title)")
                    }
                    .font(.nunito(16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.all, edges: .horizontal)
        .presentationDetents([.medium, .fraction(0.7)])
    }
}
