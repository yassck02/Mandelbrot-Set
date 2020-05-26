//
//  MandelbrotView.swift
//  Mandelbrot-Set
//
//  Created by Connor yass on 5/25/20.
//  Copyright © 2020 Chinaberry Tech, LLC. All rights reserved.
//

import MetalKit
import SwiftUI
import CBTLogger

// MARK: -

class MandelbrotMTKView: MTKView {
    
    // MARK: Properties
    
    var parameters: Parameters
    
    // MARK: Variables
    
    var commandQueue: MTLCommandQueue!
    
    var pipelineState: MTLRenderPipelineState!
    
    // MARK: Lifecycle
    
    init(parameters: Parameters) {
        self.parameters = parameters
        
        super.init(frame: .zero, device: nil)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        device = MTLCreateSystemDefaultDevice()
        isPaused = true
        enableSetNeedsDisplay = true
        
        let library = device!.makeDefaultLibrary()
        let fragmentProgram = library!.makeFunction(name: "fragment_shader")
        let vertexProgram = library!.makeFunction(name: "vertex_shader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction   = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        backgroundColor = .clear
        clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        
        do {
            pipelineState = try device!.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error as NSError {
            Log.error(error);
        }
        
        commandQueue = device!.makeCommandQueue()
    }
    
    // MARK: Functions
    
    override func draw(_ rect: CGRect) {
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            Log.error("commandQueue.makeCommandBuffer() failed"); return;
        }
        
        guard let renderPassDescriptor = currentRenderPassDescriptor else {
            Log.error("get currentRenderPassDescriptor failed"); return;
        }
        
        renderPassDescriptor.depthAttachment = .none
        
        guard let drawable = currentDrawable else {
            Log.error("get currentDrawable failed"); return;
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            Log.error("commandBuffer.makeRenderCommandEncoder(...) failed"); return;
        }
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBytes(&parameters,    length: MemoryLayout<Parameters>.stride,                           index: 3)

        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: Int(parameters.vertexCount), instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: -

struct MandelbrotView: UIViewRepresentable {
    typealias UIViewType = MandelbrotMTKView
    
    @Binding var parameters: Parameters
        
    func makeCoordinator() -> MandelbrotView.Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MandelbrotView>) -> MandelbrotMTKView {
        let parent = context.coordinator.parent
        return MandelbrotMTKView(
            parameters: parent.parameters
        )
    }
    
    func updateUIView(_ uiView: MandelbrotMTKView, context: UIViewRepresentableContext<MandelbrotView>) {
        uiView.parameters = parameters
        uiView.setNeedsDisplay()
    }
    
    class Coordinator: NSObject {
        var parent: MandelbrotView
        
        init(_ parent: MandelbrotView) {
            self.parent = parent
        }
    }
}

#if DEBUG
struct MandelbrotView_Previews: PreviewProvider {
    
    static var previews: some View {
        MandelbrotView()
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
#endif
