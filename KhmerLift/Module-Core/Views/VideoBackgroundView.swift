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

    func makeUIView(context: Context) -> UIView {
        return LoopingVideoUIView(videoName: videoName, videoType: videoType)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private class LoopingVideoUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    init(videoName: String, videoType: String) {
        super.init(frame: .zero)

        guard let path = Bundle.main.path(forResource: videoName, ofType: videoType) else {
            print("Video file '\(videoName).\(videoType)' not found.")
            return
        }

        let url = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: url)

        let player = AVQueuePlayer(playerItem: item)
        player.isMuted = true
        
        self.queuePlayer = player
        self.playerLooper = AVPlayerLooper(player: player, templateItem: item)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        player.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
