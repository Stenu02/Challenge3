import SwiftUI

struct ProfileView: View {
    @State private var firstName: String = UserDefaults.standard.string(forKey: "firstName") ?? ""
    @State private var lastName: String = UserDefaults.standard.string(forKey: "lastName") ?? ""
    @State private var birthDate: Date = UserDefaults.standard.object(forKey: "birthDate") as? Date ?? Date()
    @State private var weight: String = UserDefaults.standard.string(forKey: "weight") ?? ""
    @State private var notes: String = UserDefaults.standard.string(forKey: "notes") ?? ""
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Immagine del profilo
                    ZStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                .shadow(radius: 5)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(Text("Add Photo").foregroundColor(.blue))
                        }
                    }
                    .onTapGesture {
                        isPickerPresented = true
                    }
                    .accessibilityLabel(selectedImage == nil ? "Add profile photo" : "Edit profile photo")
                    
                    // Nome
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("First Name")
                    
                    // Cognome
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Last Name")
                    
                    // Data di nascita
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accessibilityLabel("Birth Date")
                    
                    // Peso
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Weight in kilograms")
                    
                    // Note
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .accessibilityLabel("Notes")
                    
                    // Salva dati
                    Button(action: saveProfile) {
                        Text("Save Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    .accessibilityLabel("Save Profile")
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func saveProfile() {
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
        UserDefaults.standard.set(birthDate, forKey: "birthDate")
        UserDefaults.standard.set(weight, forKey: "weight")
        UserDefaults.standard.set(notes, forKey: "notes")
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ProfileView()
}