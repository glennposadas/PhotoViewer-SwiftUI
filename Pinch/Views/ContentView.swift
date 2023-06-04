//
//  ContentView.swift
//  Pinch
//
//  Created by Glenn Posadas on 5/29/23.
//

import SwiftUI
import UIKit

struct ContentView: View {
  
  // MARK: -
  // MARK: Property
  
  @State private var scale: CGFloat = 1
  @State private var scaleAnchor: UnitPoint = .center
  @State private var maxScale: CGFloat = 5
  @State private var lastScale: CGFloat = 1
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero
  @State private var isAnimatingForEntry: Bool = false
  
  let image = UIImage(named: "magazine-front-cover")!
  
  // MARK: -
  // MARK: Functions
  
  func resetImageState() {
    return withAnimation(.spring()) {
      scale = 1
      offset = .zero
      lastScale = 1
    }
  }
  
  /// Source: https://gist.github.com/ricardo0100/4e04edae0c8b0dff68bc2fba6ef82bf5
  private func fixOffsetAndScale(geometry: GeometryProxy) {
    let newScale: CGFloat = .minimum(.maximum(scale, 1), maxScale)
    let screenSize = geometry.size
    
    let originalScale = image.size.width / image.size.height >= screenSize.width / screenSize.height ?
    geometry.size.width / image.size.width :
    geometry.size.height / image.size.height
    
    let imageWidth = (image.size.width * originalScale) * newScale
    
    var width: CGFloat = .zero
    if imageWidth > screenSize.width {
      let widthLimit: CGFloat = imageWidth > screenSize.width ?
      (imageWidth - screenSize.width) / 2
      : 0
      
      width = offset.width > 0 ?
        .minimum(widthLimit, offset.width) :
        .maximum(-widthLimit, offset.width)
    }
    
    let imageHeight = (image.size.height * originalScale) * newScale
    var height: CGFloat = .zero
    if imageHeight > screenSize.height {
      let heightLimit: CGFloat = imageHeight > screenSize.height ?
      (imageHeight - screenSize.height) / 2
      : 0
      
      height = offset.height > 0 ?
        .minimum(heightLimit, offset.height) :
        .maximum(-heightLimit, offset.height)
    }
    
    let newOffset = CGSize(width: width, height: height)
    lastScale = newScale
    lastOffset = newOffset
    withAnimation() {
      offset = newOffset
      scale = newScale
    }
  }
  
  // MARK: -
  // MARK: Content
  
  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        
        let magnificationGesture = MagnificationGesture()
          .onChanged{ gesture in
            scaleAnchor = .center
            scale = lastScale * gesture
          }
          .onEnded { _ in
            fixOffsetAndScale(geometry: geometry)
          }
        
        let dragGesture = DragGesture()
          .onChanged { gesture in
            var newOffset = lastOffset
            newOffset.width += gesture.translation.width
            newOffset.height += gesture.translation.height
            offset = newOffset
          }
          .onEnded { _ in
            fixOffsetAndScale(geometry: geometry)
          }
        
        let tapGesture = TapGesture(count: 2)
          .onEnded { _ in
            if scale == 1 {
              withAnimation(.spring()) {
                scale = maxScale
              }
            } else {
              resetImageState()
            }
          }
        
        ZStack {
          Color.clear
          
          // MARK: -
          // MARK: Page Image
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .cornerRadius(10)
            .padding()
            .shadow(color: .black.opacity(0.2), radius: 12, x: 2, y: 2)
            .opacity(isAnimatingForEntry ? 1 : 0)
            .position(x: geometry.size.width / 2,
                      y: geometry.size.height / 2)
            .scaleEffect(scale, anchor: scaleAnchor)
            .offset(offset)
            .gesture(dragGesture)
            .gesture(tapGesture)
            .gesture(magnificationGesture)
        }
      }
      .navigationTitle("Pinch & Zoom")
      .onAppear {
        withAnimation(.linear(duration: 1)) {
          isAnimatingForEntry = true
        }
      }
      
      // MARK: -
      // MARK: Info Panel
      
      .overlay(
        InfoPanelView(scale: scale, offset: offset)
          .padding(.horizontal)
          .padding(.top, 30)
        , alignment: .top
      )
      
      // MARK: -
      // MARK: Controls
      
      .overlay(
        Group {
          HStack {
            // Scale Down
            
            Button {
              withAnimation(.spring()) {
                if scale > 1 {
                  scale -= 1
                  
                  if scale <= 1 {
                    resetImageState()
                  }
                }
              }
            } label: {
              ControlImageView(icon: "minus.magnifyingglass")
            }
            
            // Reset
            
            Button {
              resetImageState()
            } label: {
              ControlImageView(icon: "arrow.up.left.and.down.right.magnifyingglass")
            }
            
            // Scale Up
            
            Button {
              withAnimation(.spring()) {
                if scale < maxScale {
                  scale += 1
                  
                  if scale > maxScale {
                    scale = maxScale
                  }
                }
              }
            } label: {
              ControlImageView(icon: "plus.magnifyingglass")
            }
          }
          .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
          .background(.ultraThinMaterial)
          .cornerRadius(12)
          .opacity(isAnimatingForEntry ? 1 : 0)
        }
          .padding(.bottom, 16)
        , alignment: .bottom
      )
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .preferredColorScheme(.dark)
  }
}
