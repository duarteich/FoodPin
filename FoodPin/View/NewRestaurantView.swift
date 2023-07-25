//
//  NewRestaurantView.swift
//  FoodPin
//
//  Created by Christyan Duarte on 7/17/23.
//

import SwiftUI

struct NewRestaurantView: View {
    
    @ObservedObject private var restaurantFormViewModel: RestaurantFormViewModel
    
    @State var restaurantName = ""
    @State private var showPhotoOptions = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    
    enum PhotoSource: Identifiable {
        case photoLibrary
        case camera
        
        var id: Int {
            hashValue
        }
    }
    
    @State private var photoSource: PhotoSource?
    
    init() {
        let viewModel = RestaurantFormViewModel()
        viewModel.image = UIImage(named: "newphoto")!
        restaurantFormViewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image(uiImage: restaurantFormViewModel.image)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                        .padding(.bottom)
                        .onTapGesture {
                            self.showPhotoOptions.toggle()
                        }
                    FormTextField(label: "NAME", placeholder: "Fill in the restaurant name",
                                  value: $restaurantFormViewModel.name)
                    FormTextField(label: "TYPE", placeholder: "Fill in the restaurant type",
                                  value: $restaurantFormViewModel.type)
                    FormTextField(label: "ADDRESS", placeholder: "Fill in the restaurant address",
                                  value: $restaurantFormViewModel.location)
                    FormTextField(label: "PHONE", placeholder: "Fill in the restaurant phone",
                                  value: $restaurantFormViewModel.phone)
                    FormTextView(label: "DESCRIPTION", value: $restaurantFormViewModel.description, height: 100)
                }
                .padding()
            }
            .navigationTitle("New Restaurant")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }

                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        save()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(Color("NavigationBarTitle"))
                    }

                }
            }
        }
        .actionSheet(isPresented: $showPhotoOptions) {
            ActionSheet(title: Text("Choose your source"),
                        message: nil,
                        buttons: [
                            .default(Text("Camera")) {
                                self.photoSource = .camera
                            },
                            .default(Text("Photo Library")) {
                                self.photoSource = .photoLibrary
                            },
                            .cancel()
                        ])
        }
        .fullScreenCover(item: $photoSource) { source in
            switch source {
            case .photoLibrary:
                ImagePicker(sourceType: .photoLibrary, selectedImage: $restaurantFormViewModel.image)
                    .ignoresSafeArea()
            case .camera:
                ImagePicker(sourceType: .camera, selectedImage: $restaurantFormViewModel.image)
                    .ignoresSafeArea()
            }
        }
        .accentColor(.primary)
    }
    
    private func save() {
        let restaurant = Restaurant(context: context)
        restaurant.name = restaurantFormViewModel.name
        restaurant.type = restaurantFormViewModel.type
        restaurant.location = restaurantFormViewModel.location
        restaurant.phone = restaurantFormViewModel.phone
        restaurant.image = restaurantFormViewModel.image.pngData()!
        restaurant.summary = restaurantFormViewModel.description
        restaurant.isFavorite = false
        
        do {
            try context.save()
        } catch {
            print("Failed to save the record...")
            print(error.localizedDescription)
        }
    }
}

struct FormTextField: View {
    let label: String
    var placeholder: String = ""
    
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(.darkGray))
            TextField(placeholder, text: $value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            .padding(.vertical, 10)
        }
    }
}

struct FormTextView: View {
    let label: String
    
    @Binding var value: String
    
    var height: CGFloat = 200.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(.darkGray))
            TextEditor(text: $value)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .padding(.top, 10)
        }
    }
}

struct NewRestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        NewRestaurantView()
        FormTextField(label: "NAME", placeholder: "Fill in the restaurant name", value: .constant(""))
            .previewLayout(.fixed(width: 300, height: 300))
            .previewDisplayName("FormTextField")
        FormTextView(label: "Description", value: .constant(""))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("FormTextView")
    }
}
