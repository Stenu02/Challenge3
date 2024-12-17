//
//  ProfileView.swift
//  GymBro
//
//  Created by Stefano Nuzzo on 16/12/24.
//

import SwiftUI
import AVFoundation

struct ProfileView: View {
    // Variabili di stato per i dati utente
    @State private var firstName: String = UserDefaults.standard.string(forKey: "firstName") ?? ""
    @State private var lastName: String = UserDefaults.standard.string(forKey: "lastName") ?? ""
    @State private var birthDate: Date = UserDefaults.standard.object(forKey: "birthDate") as? Date ?? Date()
    @State private var weight: String = UserDefaults.standard.string(forKey: "weight") ?? ""
    @State private var notes: String = UserDefaults.standard.string(forKey: "notes") ?? ""
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    @State private var isEditing = false // Modalità modifica
    @State private var showAlert = false // Per visualizzare l'alert

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
                        if isEditing {
                            isPickerPresented = true
                        }
                    }
                    .accessibilityLabel(selectedImage == nil ? "Add profile photo" : "Edit profile photo")

                    // Nome
                    readOnlyTextField(label: "First Name", text: $firstName)

                    // Cognome
                    readOnlyTextField(label: "Last Name", text: $lastName)

                    // Data di nascita
                    if isEditing {
                        DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .accessibilityLabel("Birth Date")
                    } else {
                        HStack {
                            Text("Birth Date:")
                                .bold()
                            Spacer()
                            Text(formatDate(birthDate))
                                .foregroundColor(.gray)
                        }
                    }

                    // Peso
                    readOnlyTextField(label: "Weight (kg)", text: $weight)

                    // Note
                    if isEditing {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .accessibilityLabel("Notes")
                    } else {
                        VStack(alignment: .leading) {
                            Text("Notes:")
                                .bold()
                            Text(notes.isEmpty ? "No notes available." : notes)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }

                    // Pulsanti di azione
                    if isEditing {
                        Button(action: saveProfile) {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .accessibilityLabel("Save Changes")
                    } else {
                        Button(action: { isEditing.toggle() }) {
                            Text("Edit Profile")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .accessibilityLabel("Edit Profile")
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Profile Saved"),
                message: Text("Your profile has been successfully saved."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            loadProfile()
        }
    }
    

    private func saveProfile() {
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
        UserDefaults.standard.set(birthDate, forKey: "birthDate")
        UserDefaults.standard.set(weight, forKey: "weight")
        UserDefaults.standard.set(notes, forKey: "notes")
        
        // Converti l'immagine in Data e salvala
        if let selectedImage = selectedImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
        
        showAlert = true
        isEditing = false
    }

    private func loadProfile() {
        firstName = UserDefaults.standard.string(forKey: "firstName") ?? ""
        lastName = UserDefaults.standard.string(forKey: "lastName") ?? ""
        birthDate = UserDefaults.standard.object(forKey: "birthDate") as? Date ?? Date()
        weight = UserDefaults.standard.string(forKey: "weight") ?? ""
        notes = UserDefaults.standard.string(forKey: "notes") ?? ""
        
        // Recupera l'immagine dai dati salvati
        if let imageData = UserDefaults.standard.data(forKey: "profileImage") {
            selectedImage = UIImage(data: imageData)
        }
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

   
    @ViewBuilder
    private func readOnlyTextField(label: String, text: Binding<String>) -> some View {
        if isEditing {
            TextField(label, text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel(label)
        } else {
            HStack {
                Text("\(label):")
                    .bold()
                Spacer()
                Text(text.wrappedValue.isEmpty ? "Not provided" : text.wrappedValue)
                    .foregroundColor(.gray)
            }
        }
    }
}

// Picker per selezionare un'immagine
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

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
