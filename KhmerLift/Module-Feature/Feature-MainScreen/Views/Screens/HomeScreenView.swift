import SwiftUI

struct HomeScreenView: View {
    @State private var viewModel = HomeScreenViewModel()
    @FocusState private var focusedField: FormField?
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            headerView
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    formContentView
                        .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, newField in
                    scrollToFocusedField(newField, using: proxy)
                }
            }
        }
        .padding(.horizontal)
        .onSubmit(advanceFocus)
    }
    
    private var headerView: some View {
        HStack(spacing: 5) {
            Text(viewModel.title)
                .font(.nunito(26, weight: .heavy))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("\(viewModel.streak)")
                .font(.nunito(20, weight: .medium))
                .foregroundStyle(.gray)
            
            Image("active-fire-icon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundStyle(.gray)
        }
        .padding(.top, 10)
    }
    
    private var formContentView: some View {
        VStack(spacing: 16) {
            GlassTextFieldView(
                title: "Body Weight",
                placeholder: "kg",
                text: $viewModel.bodyWeightString,
                keyboardType: .decimalPad
            )
            .focused($focusedField, equals: .bodyWeight)
            .id(FormField.bodyWeight)
            .submitLabel(.next)
            
            GlassDropdownView(
                title: "Target Muscle",
                placeholder: "Select Muscle",
                selection: $viewModel.selectedMuscle,
                items: viewModel.categories,
                onAddNew: { print("Add custom muscle modal") }
            )
            
            GlassDropdownView(
                title: "Exercise",
                placeholder: viewModel.selectedMuscle == nil ? "Select Muscle First" : "Select Exercise",
                selection: $viewModel.selectedExercise,
                items: viewModel.filteredExercises,
                isDisabled: viewModel.selectedMuscle == nil,
                onAddNew: { print("Add custom exercise modal") }
            )
            
            GlassTextFieldView(
                title: "Weight",
                placeholder: "kg",
                text: $viewModel.weightString,
                keyboardType: .decimalPad
            )
            .focused($focusedField, equals: .weight)
            .id(FormField.weight)
            .submitLabel(.next)
            
            GlassTextFieldView(
                title: "Repetition",
                placeholder: "12",
                text: $viewModel.repetitionString,
                keyboardType: .numberPad
            )
            .focused($focusedField, equals: .repetition)
            .id(FormField.repetition)
            .submitLabel(.done)
        }
    }
        
    private func advanceFocus() {
        switch focusedField {
        case .bodyWeight:
            focusedField = .weight
        case .weight:
            focusedField = .repetition
        case .repetition, .none:
            focusedField = nil
        }
    }
    
    private func scrollToFocusedField(_ field: FormField?, using proxy: ScrollViewProxy) {
        guard let field else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo(field, anchor: .center)
            }
        }
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HomeScreenView()
    }
}
