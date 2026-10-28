//
//  FaceIDScreenView.swift
//  KhmerLift
//
//  Created by Panha on 25/9/26.
//

import SwiftUI

struct FaceIDScreenView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FaceIDViewModel

    init(
        timer: Int = 19,
        status: String = "No face detected",
        onSuccess: (() -> Void)? = nil,
        onFailure: (() -> Void)? = nil
    ) {
        _viewModel = State(wrappedValue: FaceIDViewModel(
            initialTimer: timer,
            initialStatus: status,
            onSuccess: onSuccess,
            onFailure: onFailure
        ))
    }

    var body: some View {
        containerView
    }
}

extension FaceIDScreenView {
    private var containerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: cancelAndDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect(.clear)

                Text("Face ID")
                    .font(.nunito(22, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button(action: cancelAndDismiss) {
                    Image("logo-icon")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 30) {
                ZStack {
                    CameraPreview(session: viewModel.cameraManager.session)
                        .frame(width: 275, height: 275)
                        .clipShape(Circle())

                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 275, height: 275)
                }
                .padding(.top, 30)
                .padding(.bottom, 20)

                Text("\(viewModel.timer) s")
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)

                Text(viewModel.status)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 20) {
                    instructionIcon(named: "no-glasses-icon")
                    instructionIcon(named: "no-mask-icon")
                    instructionIcon(named: "no-hat-icon")
                }

                Button(action: { viewModel.toggleMute() }) {
                    Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.top, 30)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        
        .onAppear {
            viewModel.onViewAppear()
        }
        .onDisappear {
            viewModel.onViewDisappear()
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        
        .appBackground()
    }

    private func instructionIcon(named name: String) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(.white)
            .scaledToFit()
            .frame(width: 50, height: 50)
    }

    private func cancelAndDismiss() {
        viewModel.handleUserCancel()
        dismiss()
    }
}

#Preview {
    FaceIDScreenView(
        timer: 19,
        status: "No face detected"
    )
}
