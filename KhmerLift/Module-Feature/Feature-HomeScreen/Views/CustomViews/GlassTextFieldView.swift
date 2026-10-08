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
    var maxLength: Int = 6
    var maxDecimalPlaces: Int = 2
    var allowedRange: ClosedRange<Double>? = nil
    
    var onExceedLimit: (() -> Void)? = nil
    var onOutOfRange: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onChange(of: text) { oldValue, newValue in
                validateInput(oldValue: oldValue, newValue: newValue)
            }
        }
    }
    
    private func validateInput(oldValue: String, newValue: String) {
        guard !newValue.isEmpty else { return }
        
        let isNumberPad = keyboardType == .numberPad
        
        let allowedSet = isNumberPad ? "0123456789" : "0123456789."
        var filtered = newValue.filter { allowedSet.contains($0) }
        
        if filtered.filter({ $0 == "." }).count > 1 {
            filtered = oldValue
        }
        
        if filtered.hasPrefix(".") {
            filtered = "0" + filtered
        }
        
        while filtered.hasPrefix("0") && filtered.count > 1 && !filtered.hasPrefix("0.") {
            filtered.removeFirst()
        }
        
        let allowedDecimals = isNumberPad ? 0 : maxDecimalPlaces
        if let dotIndex = filtered.firstIndex(of: ".") {
            let decimalDigits = filtered[filtered.index(after: dotIndex)...]
            if decimalDigits.count > allowedDecimals {
                filtered = oldValue
            }
        }
        
        if filtered.count > maxLength {
            filtered = String(filtered.prefix(maxLength))
            onExceedLimit?()
        }
        
        if let range = allowedRange {
            let cleanNumberString = filtered.trimmingCharacters(in: CharacterSet(charactersIn: "."))
            if let doubleVal = Double(cleanNumberString), doubleVal > range.upperBound {
                filtered = oldValue
                onOutOfRange?()
            }
        }
        
        if text != filtered {
            text = filtered
        }
    }
}
