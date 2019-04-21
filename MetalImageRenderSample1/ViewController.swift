//
//  ViewController.swift
//  MetalImageRenderSample1
//
//  Created by park kyung suk on 2019/04/21.
//  Copyright © 2019 park kyung suk. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    
    @IBOutlet weak var mtkView: MTKView!
    
    // 実機じゃないとクラッシュ
    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    private var texture: MTLTexture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Metalの初期化設定
        setupMetal()
        
        // 表示する画像をdeviceからテクスチャとしてロード
        loadTexture()
        
        
        // 今回の場合は 静止画、つまり１フレームのみdrawさせるので下の処理をすることで
        //drawが１回だけ呼ばれるようにする
        // これをすることで自動的に再描画をさせない
        mtkView.enableSetNeedsDisplay = true
      
        // ビューの更新以来　-> draw(in:)が呼ばれる
        mtkView.setNeedsDisplay()
    }
    
    private func setupMetal() {
        
        // MTLCommandQueueを初期化
        // deviceのcommandQueue
        commandQueue = device.makeCommandQueue()
        
        //MTKViewの設定
        mtkView.device = device
        mtkView.delegate = self
    }
    
    private func loadTexture() {
        // deviceからTextureをロードするため生成
        let textureLoader = MTKTextureLoader(device: device)
        
        // deviceの name"highsierra"のテクスチャをロードして textureに代入しておく
        texture = try! textureLoader.newTexture(name: "highsierra",
                                                scaleFactor: view.contentScaleFactor,
                                                bundle: nil)
        
        // pixelフォーマットを合わせる
        mtkView.colorPixelFormat = texture.pixelFormat
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("\(self.classForCoder)/" + #function)
    }
    
    func draw(in view: MTKView) {
        
        let drawable = view.currentDrawable!
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        //コピーするサイズを計算
        let w = min(texture.width, drawable.texture.width)
        let h = min(texture.height, drawable.texture.height)
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        
        blitEncoder?.copy(from: self.texture,
                          sourceSlice: 0,
                          sourceLevel: 0,
                          sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                          sourceSize: MTLSize(width: w, height: h, depth: texture.depth),
                          to: drawable.texture,
                          destinationSlice: 0,
                          destinationLevel: 0,
                          destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        
        // encoder完了
        blitEncoder?.endEncoding()
        
        // 表示するドロワーブルを登録
        commandBuffer.present(drawable)
        
        // コマンドバッファをコミット (エンキュー)
        commandBuffer.commit()
        
        //完了まで待つ
        commandBuffer.waitUntilCompleted()
    }

}
