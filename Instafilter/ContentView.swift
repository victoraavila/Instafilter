//
//  ContentView.swift
//  Instafilter
//
//  Created by Víctor Ávila on 03/07/24.
//

import SwiftUI

// The first step in this project is going to be to build a basic UI, i.e., a NavigationStack to show the app's name across the top, a box in the middle asking users to import a picture, an intensity slider that affects how strongly we apply our CoreImage filters (0 to 1) and then a sharing Button to export the processed image somewhere outside our app.

struct ContentView: View {
    // Using Image? because the user hasn't selected any image at initialization
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5 // The slider value
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Image selection area, with spaces up and below
                // 1. If we have an image already selected, then we should show it
                // 2. Otherwise, we'll display a simple ContentUnavailableView (so users know the space isn't accidentally blank)
                // Unwrapping optionals right here let us make only one of two possibilities visible (depending whether we have an Image or not), which is nice
                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                }
                
                Spacer() // This is used to ensure the controls at the bottom will stay at the bottom
                
                HStack {
                    // Our intensity slider
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                }
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                    
                    Spacer()
                    
                    // Share the picture
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
        }
    }
    
    // Instead of putting the logic directly inside the Button, Paul prefers to create this separated method to clean up the code
    func changeFilter() {
        
    }
}

#Preview {
    ContentView()
}
