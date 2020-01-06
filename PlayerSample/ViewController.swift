//
//  ViewController.swift
//  PlayerSample
//
//  Created by Hajime Imamura on 2020/01/06.
//  Copyright © 2020 imamurh. All rights reserved.
//

import UIKit
import SwiftUI
import AVFoundation

let playerViewWidth: CGFloat = 320
let playerViewHeight: CGFloat = 180

// https://developer.apple.com/streaming/examples/
let videoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!

final class ViewController: UIViewController {
  enum Row: String, CaseIterable {
    case UIKit = "UIKit"
    case SwiftUI = "SwiftUI"
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Row.allCases.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
    cell.textLabel?.text = Row.allCases[indexPath.row].rawValue
    return cell
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let playerItem = AVPlayerItem(url: videoURL)
    let player = AVPlayer(playerItem: playerItem)

    switch Row.allCases[indexPath.row] {
    case .UIKit:
      present(PlayerViewController(player: player), animated: true)
    case .SwiftUI:
      present(UIHostingController(rootView: ContentView(player: player)), animated: true)
    }

    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: AVPlayer View

final class AVPlayerView: UIView {
  override class var layerClass: AnyClass { return AVPlayerLayer.self }
  var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
  func bind(to player: AVPlayer?) { playerLayer.player = player }
}

// MARK: - UIKit

final class PlayerViewController: UIViewController {
  let player: AVPlayer

  init(player: AVPlayer) {
    self.player = player
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = UIView()
    view.backgroundColor = .systemBackground
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.distribution = .equalSpacing
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    let label = UILabel()
    label.text = "UIKit"
    stackView.addArrangedSubview(label)

    let playerView = AVPlayerView()
    playerView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(playerView)
    playerView.widthAnchor.constraint(equalToConstant: playerViewWidth).isActive = true
    playerView.heightAnchor.constraint(equalToConstant: playerViewHeight).isActive = true
    playerView.bind(to: player)

    player.play()
  }
}

// MARK: - SwiftUI

struct PlayerView: UIViewRepresentable {
  let player: AVPlayer

  func makeUIView(context: Context) -> AVPlayerView {
    let playerView = AVPlayerView()
    playerView.bind(to: player)
    return playerView
  }

  func updateUIView(_ uiView: AVPlayerView, context: Context) {}
}

struct ContentView: View {
  let player: AVPlayer

  var body: some View {
    VStack(spacing: 20) {
      Text("SwiftUI")
      PlayerView(player: player)
        .frame(width: playerViewWidth, height: playerViewHeight, alignment: .center)
        .onAppear { self.player.play() }
    }
  }
}
