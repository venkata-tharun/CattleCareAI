import Foundation

// MARK: - NetworkManager
// Central place for all API calls.
// Base URL points to the local Flask server.
// Session cookies are automatically handled by URLSession.shared.

class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

    // Change this to your machine's local IP when running on a real device
    // e.g. "http://192.168.1.100:5000"
    let baseURL = "http://127.0.0.1:5002"
    // ── Generic request helper ─────────────────────────────────────
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + path) else { return }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpShouldHandleCookies = true   // keep session cookie

        if let body = body {
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        URLSession.shared.dataTask(with: req) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                print("⚠️ NetworkManager: Session expired or unauthorized (401)")
                // Don't trigger logout if we are on the login screen - we want to show "Invalid credentials"
                if let path = req.url?.path, path != "/api/auth/login" {
                    NotificationCenter.default.post(name: .logoutNotification, object: nil)
                }
                // Continue to process the response so the error message is decoded
            }
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                
                // If it's a message response, check for backend errors
                if let msgRes = decoded as? SimpleMessageResponse, let errMsg = msgRes.error {
                    print("❌ API Error: \(errMsg)")
                }
                
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                print("❌ Decoding Error: \(error.localizedDescription) Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // ── Auth ────────────────────────────────────────────────────────

    func login(
        emailOrPhone: String,
        password: String,
        completion: @escaping (Result<AuthResponse, Error>) -> Void
    ) {
        request(
            path: "/api/auth/login",
            method: "POST",
            body: ["email_or_phone": emailOrPhone, "password": password],
            completion: completion
        )
    }

    func register(
        fullName: String,
        emailOrPhone: String,
        farmName: String,
        password: String,
        completion: @escaping (Result<SimpleMessageResponse, Error>) -> Void
    ) {
        request(
            path: "/api/auth/register",
            method: "POST",
            body: [
                "full_name": fullName,
                "email_or_phone": emailOrPhone,
                "farm_name": farmName,
                "password": password,
            ],
            completion: completion
        )
    }

    func verifyRegistration(emailOrPhone: String, otp: String, completion: @escaping (Result<SimpleMessageResponse, Error>) -> Void) {
        request(
            path: "/api/auth/register/verify",
            method: "POST",
            body: ["email_or_phone": emailOrPhone, "otp": otp],
            completion: completion
        )
    }

    func forgotPassword(emailOrPhone: String, completion: @escaping (Result<SimpleMessageResponse, Error>) -> Void) {
        request(
            path: "/api/auth/forgot-password",
            method: "POST",
            body: ["email_or_phone": emailOrPhone],
            completion: completion
        )
    }

    func verifyForgotPassword(emailOrPhone: String, otp: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        request(
            path: "/api/auth/forgot-password/verify",
            method: "POST",
            body: ["email_or_phone": emailOrPhone, "otp": otp],
            completion: completion
        )
    }

    func resetPassword(emailOrPhone: String, newPassword: String, resetToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        request(
            path: "/api/auth/reset-password",
            method: "POST",
            body: ["email_or_phone": emailOrPhone, "new_password": newPassword, "reset_token": resetToken],
            completion: completion
        )
    }

    func resendOTP(emailOrPhone: String, context: String, completion: @escaping (Result<SimpleMessageResponse, Error>) -> Void) {
        request(
            path: "/api/auth/resend-otp",
            method: "POST",
            body: ["email_or_phone": emailOrPhone, "context": context],
            completion: completion
        )
    }

    func logout(completion: @escaping (Bool) -> Void) {
        request(path: "/api/auth/logout", method: "POST") { (result: Result<SimpleMessageResponse, Error>) in
            switch result {
            case .success: completion(true)
            case .failure: completion(false)
            }
        }
    }

    /// Returns current session user or nil if not logged in
    func me(completion: @escaping (UserProfile?) -> Void) {
        request(path: "/api/auth/me") { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let r): completion(r.user)
            case .failure:       completion(nil)
            }
        }
    }

    func updateProfile(fullName: String, farmName: String, email: String, phone: String, completion: @escaping (Bool) -> Void) {
        request(
            path: "/api/auth/profile/update",
            method: "POST",
            body: [
                "full_name": fullName,
                "farm_name": farmName,
                "email": email,
                "phone": phone
            ],
            completion: { (result: Result<SimpleMessageResponse, Error>) in
                switch result {
                case .success: completion(true)
                case .failure: completion(false)
                }
            }
        )
    }

    // ── Animals ─────────────────────────────────────────────────────
    func getAnimals(completion: @escaping ([Animal]) -> Void) {
        request(path: "/api/animals", method: "GET") { (r: Result<[Animal], Error>) in
            completion((try? r.get()) ?? [])
        }
    }

    func addAnimal(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: "/api/animals", method: "POST", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    func deleteAnimal(id: Int, completion: @escaping (Bool) -> Void) {
        request(path: "/api/animals/\(id)", method: "DELETE") { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    func updateAnimal(id: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: "/api/animals/\(id)", method: "PUT", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    // ── Animal Records ──────────────────────────────────────────────
    func getHealthRecords(animalId: Int, completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/animals/\(animalId)/health-records", completion: completion)
    }

    func addHealthRecord(animalId: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/animals/\(animalId)/health-records", body: body, completion: completion)
    }
    
    func updateHealthRecord(animalId: Int, recordId: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        putItem(path: "/api/animals/\(animalId)/health-records/\(recordId)", body: body, completion: completion)
    }
    
    func deleteHealthRecord(animalId: Int, recordId: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/animals/\(animalId)/health-records/\(recordId)", completion: completion)
    }

    func getVaccinations(animalId: Int, completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/animals/\(animalId)/vaccinations", completion: completion)
    }

    func addVaccination(animalId: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/animals/\(animalId)/vaccinations", body: body, completion: completion)
    }
    
    func updateVaccination(animalId: Int, vaccinationId: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        putItem(path: "/api/animals/\(animalId)/vaccinations/\(vaccinationId)", body: body, completion: completion)
    }
    
    func deleteVaccination(animalId: Int, vaccinationId: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/animals/\(animalId)/vaccinations/\(vaccinationId)", completion: completion)
    }

    // ── Milk ────────────────────────────────────────────────────────
    func getMilkEntries(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/milk", completion: completion)
    }

    /// Returns [{id, name, tag}] for animals owned by the current user.
    func getAnimalTags(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/milk/animal-tags", completion: completion)
    }

    func addMilkEntry(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/milk", body: body, completion: completion)
    }

    func deleteMilkEntry(id: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/milk/\(id)", completion: completion)
    }

    func updateMilkEntry(id: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: "/api/milk/\(id)", method: "PUT", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    // ── Transactions ────────────────────────────────────────────────
    func getTransactions(category: String? = nil, completion: @escaping ([[String: Any]]) -> Void) {
        let path = category != nil ? "/api/transactions?category=\(category!)" : "/api/transactions"
        fetchList(path: path, completion: completion)
    }

    func addTransaction(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/transactions", body: body, completion: completion)
    }

    func deleteTransaction(id: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/transactions/\(id)", completion: completion)
    }


    // ── Visitors ────────────────────────────────────────────────────
    func getVisitors(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/visitors", completion: completion)
    }

    func addVisitor(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/visitors", body: body, completion: completion)
    }

    func updateVisitor(id: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: "/api/visitors/\(id)", method: "PUT", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    func deleteVisitor(id: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/visitors/\(id)", completion: completion)
    }

    // ── Calving ─────────────────────────────────────────────────────
    func getCalvingRecords(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/calving", completion: completion)
    }

    func addCalvingRecord(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/calving", body: body, completion: completion)
    }

    func deleteCalvingRecord(id: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/calving/\(id)", completion: completion)
    }

    func updateCalvingRecord(id: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: "/api/calving/\(id)", method: "PUT", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    // ── Feed ────────────────────────────────────────────────────────
    func getFeedStock(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/feed/stock", completion: completion)
    }

    func addFeedStock(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/feed/stock", body: body, completion: completion)
    }

    func getFeedActivity(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/feed/activity", completion: completion)
    }

    func getFeedEntries(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/feed/entries", completion: completion)
    }

    func addFeedEntry(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/feed/entries", body: body, completion: completion)
    }

    // ── Feeding Schedules ──────────────────────────────────────────
    func getFeedingSchedules(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/feed/schedules", completion: completion)
    }

    func addFeedingSchedule(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/feed/schedules", body: body, completion: completion)
    }

    func updateFeedingSchedule(id: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        putItem(path: "/api/feed/schedules/\(id)", body: body, completion: completion)
    }

    func deleteFeedingSchedule(id: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/feed/schedules/\(id)", completion: completion)
    }

    // ── Logs ────────────────────────────────────────────────────────
    func getLogs(type: String? = nil, completion: @escaping ([[String: Any]]) -> Void) {
        let path = type != nil ? "/api/logs?type=\(type!)" : "/api/logs"
        fetchList(path: path, completion: completion)
    }

    func addLog(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/logs", body: body, completion: completion)
    }

    func updateLog(id: Int, body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: "/api/logs/\(id)", method: "PUT", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    func deleteLog(id: Int, completion: @escaping (Bool) -> Void) {
        deleteItem(path: "/api/logs/\(id)", completion: completion)
    }

    // ── Sanitation ──────────────────────────────────────────────────
    func getSanitationScore(completion: @escaping (Int) -> Void) {
        request(path: "/api/sanitation/score") { (r: Result<[String: Int], Error>) in
            completion((try? r.get())?["score"] ?? 85)
        }
    }

    func saveSanitationChecklist(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        postItem(path: "/api/sanitation/checklist", body: body, completion: completion)
    }

    // ── AI ──────────────────────────────────────────────────────────
    func getAIPredictions(completion: @escaping ([[String: Any]]) -> Void) {
        fetchList(path: "/api/ai/predictions", completion: completion)
    }

    func uploadAIPrediction(
        image: Data,
        diseaseName: String,
        confidence: String,
        status: String,
        symptoms: [String],
        precautions: [String],
        animalId: Int? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: baseURL + "/api/ai/predictions") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = true
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        // Add fields
        let fields = [
            "diseaseName": diseaseName,
            "confidence": confidence,
            "status": status,
            "symptoms": (try? JSONSerialization.data(withJSONObject: symptoms).base64EncodedString()) ?? "[]",
            "precautions": (try? JSONSerialization.data(withJSONObject: precautions).base64EncodedString()) ?? "[]"
        ]
        
        // Wait, I should probably pass them as strings or JSON strings in the form
        var textFields: [String: String] = [
            "diseaseName": diseaseName,
            "confidence": confidence,
            "status": status,
            "symptoms": symptoms.description,
            "precautions": precautions.description
        ]
        
        if let aid = animalId {
            textFields["animal_id"] = "\(aid)"
        }

        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"prediction.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let str = String(data: data, encoding: .utf8) {
                print("🛠 NetworkManager: AI Upload Result: \(str)")
            }
            DispatchQueue.main.async { completion(error == nil) }
        }.resume()
    }

    // ── Dashboard ───────────────────────────────────────────────────
    func fetchDashboardStats(completion: @escaping (DashboardStats?) -> Void) {
        request(path: "/api/dashboard/stats") { (r: Result<DashboardStats, Error>) in
            completion(try? r.get())
        }
    }

    // ── Reports Export ──────────────────────────────────────────────
    func getReportExportURL(type: String) -> URL? {
        return URL(string: baseURL + "/api/reports/export/\(type)")
    }

    // ── Helpers ─────────────────────────────────────────────────────
    private func fetchList(path: String, completion: @escaping ([[String: Any]]) -> Void) {
        guard let url = URL(string: baseURL + path) else { return }
        var req = URLRequest(url: url)
        req.httpShouldHandleCookies = true
        URLSession.shared.dataTask(with: req) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                DispatchQueue.main.async { completion(json) }
            } else {
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }

    private func postItem(path: String, body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: path, method: "POST", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }

    private func deleteItem(path: String, completion: @escaping (Bool) -> Void) {
        request(path: path, method: "DELETE") { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }
    
    private func putItem(path: String, body: [String: Any], completion: @escaping (Bool) -> Void) {
        request(path: path, method: "PUT", body: body) { (r: Result<SimpleMessageResponse, Error>) in
            completion((try? r.get()) != nil)
        }
    }
}

// MARK: - Response Models

struct SimpleMessageResponse: Decodable {
    let message: String?
    let error: String?
}

struct AuthResponse: Decodable {
    let message: String?
    let user: UserProfile?
    let error: String?
    let reset_token: String?
}

struct UserProfile: Decodable {
    let id: Int
    let full_name: String
    let email_or_phone: String
    let phone: String?
    let farm_name: String
}

struct AnimalResponse: Decodable, Identifiable {
    let id: Int
    let user_id: Int
    let name: String
    let tag: String
    let breed: String
    let status: String
}

struct DashboardStats: Decodable {
    let totalAnimals: Int
    let milkToday: String
    // We can add recentLogs if needed later
}
