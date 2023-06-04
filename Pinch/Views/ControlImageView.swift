//
//  ControlImageView.swift
//  Pinch
//
//  Created by Glenn Posadas on 6/4/23.
//

import SwiftUI

struct ControlImageView: View {
  
  let icon: String
  
  var body: some View {
    Image(systemName: icon)
      .font(.system(size: 24))
  }
}

struct ControlImageView_Previews: PreviewProvider {
  static var previews: some View {
    ControlImageView(icon: "minus.magnifyingglass")
      .preferredColorScheme(.dark)
      .previewLayout(.sizeThatFits)
      .padding()
  }
}
