


import Foundation
import Combine

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var errorMessage: String?

    private let apiKey = "a16cfd5f47mshbf0ebc47980134ap1ab4fdjsn7522a0af3413"
    private let apiHost = "exercisedb.p.rapidapi.com"
    
    func fetchExercises(limit: Int = 800, offset: Int = 0) {
        guard let url = URL(string: "https://\(apiHost)/exercises?limit=\(limit)&offset=\(offset)") else {
            errorMessage = "URL non valida."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Errore: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Nessun dato ricevuto."
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode([Exercise].self, from: data)
                    self?.exercises = decodedData
                } catch {
                    self?.errorMessage = "Errore di decodifica: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}


