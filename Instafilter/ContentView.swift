//
//  ContentView.swift
//  Instafilter
//
//  Created by Víctor Ávila on 03/07/24.
//

import PhotosUI
import SwiftUI

// The first step in this project is going to be to build a basic UI, i.e., a NavigationStack to show the app's name across the top, a box in the middle asking users to import a picture, an intensity slider that affects how strongly we apply our CoreImage filters (0 to 1) and then a sharing Button to export the processed image somewhere outside our app.

struct ContentView: View {
    // Using Image? because the user hasn't selected any image at initialization
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5 // The slider value
    
    // We need to let users select photos from their Photo Library to import
    // 1. import SwiftUI
    // 2. Add an @State property to track which photo the user selected (Optional because there isn't one by default)
    // 3. Place a PhotosPickerView whenever we want to trigger photo selection (we will wrap the if let-else and use it as a label)
    // 4. Have a method that will be called when an Image is selected: we're gonna load a binary blob of data from PhotosPickerItem? and feed that into UIImage.
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // The blue coloring indicates the PhotosPicker works
                PhotosPicker(selection: $selectedItem) {
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
                }
                .buttonStyle(.plain) // To disable the blue coloring
                .onChange(of: selectedItem, loadImage)
                
                
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
    
    func loadImage() {
        Task { // To work asynchronously
            // Give me the pure binary data from this thing
            // We can't use Image here because we can't feed an Image into the module CoreImage
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return } // If it fails, return
            guard let inputImage = UIImage(data: imageData) else { return } // If it fails, return
            
            // more code to come
            
            // This will run whenever selectedItem changes (we will do this by attaching the .onChange())
        }
    }
}

#Preview {
    ContentView()
}
