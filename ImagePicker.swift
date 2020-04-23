// IMPORTANT INFORMATION
// For this to work is required to add this
// <key>NSPhotoLibraryUsageDescription</key>
// <string>(description of why you want access)</string>

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var image: UIImage?
    @State var allowsEditing: Bool
    @State var previewImage: Image?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = allowsEditing
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
            }
            else if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
        
    }
    
}

// Helper Class to help with the access authorization 

class PhotoLibraryAccess {
typealias Request = (_ result: AuthorizationInfo) -> ()

enum AuthorizationInfo {
    case Authorized, Denied, PreviouslyDenied, Unknown
}

init() { }

    func checkPhotoLibraryReadAccess() -> AuthorizationInfo {
        var authorized: AuthorizationInfo = .PreviouslyDenied

        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.denied {
            authorized = .PreviouslyDenied
        } else if status == PHAuthorizationStatus.notDetermined {
            authorized = .Unknown
        } else if status == PHAuthorizationStatus.authorized {
            authorized = .Authorized
        }
        return authorized
    }

    func requestAuthorization(completion: @escaping Request) {
        PHPhotoLibrary.requestAuthorization({ (newStatus) in
            if newStatus == PHAuthorizationStatus.authorized {
                completion(.Authorized)
            } else {
                completion(.Denied)
            }
        })
    }
}

// Example Usage

struct ContentView: View {
    @State var showingImagePicker: Bool = false
    @State var selectedImage: UIImage?
    @State var allowsEdinting: Bool = false
    
    var body: some View {
        Button(action: {
            self.requestAuthorization()
        }) {
            Text("Pick Image")
        }
        .sheet(isPresented: self.$showingImagePicker, onDismiss: self.initPicLoad) {
            ImagePicker(image: self.$selectedImage, allowsEditing: self.allowsEdinting)
        }
    }
    
    func loadImage() {
        guard let img = self.image else { return }
        self.previewImage = Image(uiImage: img)
    }
    
    // Uses the helper class to check for authorization if it's unknown (it hasn't request authorization)
    // it requests the autorization and waits for the user response
    func requestAuthorization() {
        let photoLibraryAccess = PhotoLibraryAccess()
        let authorized = photoLibraryAccess.checkPhotoLibraryReadAccess()
        if authorized == .Authorized {
            self.showingImagePicker.toggle()
        } else if authorized == .PreviouslyDenied {
            // The access was previously denied, it can be unlocked in the privacy settings
        } else if authorized == .Unknown {
            photoLibraryAccess.requestAuthorization { result in
                if result == .Authorized {
                    self.showingImagePicker.toggle()
                } else {
                    // The access was denied
                }
            }
        }
    }
}
