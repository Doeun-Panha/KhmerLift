//
//  GlassDropdownView.swift
//  KhmerLift
//
//  Created by Panha on 18/9/26.
//
import SwiftUI

struct GlassDropdownView<T: SelectableItem>: View {
    let title: String
    @Binding var selection: T?
    let items: [T]
    let placeholder: String
    let isDisabled: Bool
    
    let onAddNew: () -> Void
    
    @State private var isShowingSheet: Bool = false
    
    init(
        title: String,
        placeholder: String,
        selection: Binding<T?>,
        items: [T],
        isDisabled: Bool = false,
        onAddNew: @escaping () -> Void
    ) {
        self.title = title
        self.placeholder = placeholder
        self._selection = selection
        self.items = items
        self.isDisabled = isDisabled
        self.onAddNew = onAddNew
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.nunito(16, weight: .semibold))
                .foregroundStyle(.white)
            
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                isShowingSheet = true
            }) {
                HStack {
                    Text(selection?.displayName ?? placeholder)
                        .font(.nunito(16, weight: .semibold))
                        .foregroundStyle(selection == nil ? .gray : .white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.nunito(16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.black.opacity(0.10))
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                )
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .sheet(isPresented: $isShowingSheet) {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Text("Select \(title)")
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
                        ForEach(items) { item in
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
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(selection == item ? Color.white.opacity(0.12) : Color.clear)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                
                VStack {
                    Button(action: {
                        isShowingSheet = false
                        onAddNew()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Add New \(title)")
                        }
                        .font(.nunito(16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.cyan))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .presentationDetents([.medium, .fraction(0.7)])
            .presentationCornerRadius(36)
            .presentationBackground {
                ZStack {
                    Color.black.opacity(0.4)
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                }
                .ignoresSafeArea()
            }
        }
    }
}
