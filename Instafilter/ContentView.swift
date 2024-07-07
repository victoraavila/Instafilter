//
//  ContentView.swift
//  Instafilter
//
//  Created by Víctor Ávila on 03/07/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

// We will activate the Change Filter Button next (including using .confirmationDialog(), which is a list of Buttons that slides up from the bottom of the screen and you can add as many of these things as you want to. It can even scroll...)
// 1. We need a property inside our View that will store whether the Confirmation Dialog is currently showing or not.
// 2. Add our Buttons using the .confirmationDialog() modifier, which works identically to .alert(): give it a title and a condition to monitor, and as soon as the condition becomes true the confirmation dialog will be shown.

// New, we will add 2 more features:
// 1. A Button to share processedImage elsewhere on the device using ShareLink. It lets us share things like text, URLs and pictures very easily in one line of code and takes care of showing the system's share sheet with only the apps that can handle the content we are sending.
// 2. An encouragement for users to leave a review for the app when the user has really felt the benefit of your app. We will display it only when the user has changed filters for 20 times. (Remember to import StoreKit).

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilters = false
    
    // By doing the following, we get an object of the class CIFilter that conforms to a protocol called CISepiaTone. Internally, it maps the kCIInputIntensityKey key to the .intensity attribute we set in the code.
//    @State private var currentFilter = CIFilter.sepiaTone()
    
    // "I don't care it's setting a Sepia Tone filter. I just want some kind of CIFilter."
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    // One property to get the review request from SwiftUI's environment and one to track how many filter changes have taken place.
    // We will use @AppStorage for that so it's preserved between app runs.
    @Environment(\.requestReview) var requestReview
    @AppStorage("filterCount") var filterCount = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                }
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                    
                    Spacer()
                    
                    // Check to see if we actually have an image to share
                    if let processedImage {
                        // The processedImage is the content we are sharing and the preview of the content we are sharing
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                // We can create an Array of Buttons to show and an Optional Message
                // When users select a filter, it should be activated and immediately applied (apply the current intensity value to it).
                // To make this work, we will write a method that modifies currentFilter to a new value based on what they chose and then call loadImage() straight away.
                // The underlying CoreImage API is stringly typed: it uses strings to read and write values rather than fixed properties. This functionality helps us because we can write code that works across all filters very well. We just have to be careful to not send an invalid value in.
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
//        currentFilter.intensity = Float(filterIntensity)
        // When we don't specify a certain filter by setting the variable to be of type CIFilter, we lost access to the property. We have to call setValue() instead.
//        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        // The line above breaks when applying Gaussian Blur, because it does not have an internsity key attached to it. We will add more code to read the valid keys and only set the intensity key if it's actually supported by the current filter (for Gaussian Blur, it will set the radius instead). Make sure to scale the filter intensity by a number that makes sense (found by trial and error).
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter(_ filter: CIFilter) {
        // Loading the image is triggered every time a filter changes. You could change that by running the code responsible for loading the UIImage once and then storing beginImage in another @State property.
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        if filterCount >= 20 {
            // Swift can't guarantee this piece of UI code is going to run on the MainActor unless we specifically force that to be the case by adding @MainActor in front of the func.
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}
