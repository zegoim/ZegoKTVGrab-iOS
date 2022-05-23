//
//  GBLottieView.swift
//  KTVGrab
//
//  Created by Vic on 2022/4/1.
//

import Foundation
import Lottie

open class GBLottieView: UIView {
  
  let bundle: Bundle
  let view: AnimationView = AnimationView()
  
  @objc public init(imageProvideBundle: Bundle?) {
    self.bundle = imageProvideBundle ?? Bundle.main;
    self.view.imageProvider = BundleImageProvider(bundle: self.bundle, searchPath: nil)
    super.init(frame: CGRect())
    setup()
  }
  
  @objc public init() {
    self.bundle = Bundle.main;
    super.init(frame: CGRect())
    setup()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    view.loopMode = .loop
    self.addSubview(view)
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    view.frame = self.bounds
  }
  
  @objc public func named(name: String, bundle: Bundle) {
    let animation = Animation.named(name, bundle: bundle)
    view.animation = animation
  }
  
  @objc public func play() {
    view.play()
  }
  
  @objc public func stop() {
    view.stop()
  }
}
