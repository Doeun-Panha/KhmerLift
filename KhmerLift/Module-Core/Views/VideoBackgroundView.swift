//
//  VideoBackgroundView.swift
//  KhmerLift
//
//  Created by Panha on 2/10/26.
//

import SwiftUI
import AVFoundation

struct VideoBackgroundView: UIViewRepresentable {
    let videoName: String
    let videoType: String
    
    init(name: String, type: String = "mp4") {
        self.videoName = name
        self.videoType = type
    }

    func makeUIView(context: Context) -> LoopingVideoUIView {
        return LoopingVideoUIView(videoName: videoName, videoType: videoType)
    }

    func updateUIView(_ uiView: LoopingVideoUIView, context: Context) {
        uiView.updateVideo(videoName: videoName, videoType: videoType)
    }
}

class LoopingVideoUIView: UIView {
    private var activePlayerLayer: AVPlayerLayer?
    private var activeQueuePlayer: AVQueuePlayer?
    private var activePlayerLooper: AVPlayerLooper?
    private var currentVideoName: String?
    
    private var readyObserver: NSKeyValueObservation?

    init(videoName: String, videoType: String) {
        super.init(frame: .zero)
        backgroundColor = .black
        setupPlayer(videoName: videoName, videoType: videoType)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateVideo(videoName: String, videoType: String) {
        guard currentVideoName != videoName else { return }
        setupPlayer(videoName: videoName, videoType: videoType)
    }

    private func setupPlayer(videoName: String, videoType: String) {
        guard let path = Bundle.main.path(forResource: videoName, ofType: videoType) else {
            print("Video file '\(videoName).\(videoType)' not found.")
            return
        }

        currentVideoName = videoName
        let url = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: url)

        let newPlayer = AVQueuePlayer(playerItem: item)
        newPlayer.isMuted = true
        let newLooper = AVPlayerLooper(player: newPlayer, templateItem: item)

        let newLayer = AVPlayerLayer(player: newPlayer)
        newLayer.videoGravity = .resizeAspectFill
        newLayer.frame = bounds
        newLayer.opacity = 0 // Hidden initially while buffering
        layer.addSublayer(newLayer)

        newPlayer.play()

        let oldLayer = activePlayerLayer
        let oldPlayer = activeQueuePlayer
        let oldLooper = activePlayerLooper

        self.activePlayerLayer = newLayer
        self.activeQueuePlayer = newPlayer
        self.activePlayerLooper = newLooper

        readyObserver?.invalidate()
        readyObserver = newLayer.observe(\.isReadyForDisplay, options: [.new]) { layer, _ in
            if layer.isReadyForDisplay {
                DispatchQueue.main.async {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(0.3)
                    CATransaction.setCompletionBlock {
                        oldLayer?.removeFromSuperlayer()
                        oldPlayer?.pause()
                        _ = oldLooper
                    }
                    layer.opacity = 1.0
                    CATransaction.commit()
                }
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure all active and fading layers match view bounds
        layer.sublayers?.forEach { sublayer in
            sublayer.frame = bounds
        }
    }

    deinit {
        readyObserver?.invalidate()
    }
}
