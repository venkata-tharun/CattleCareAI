import SwiftUI

struct BiosecurityChecklistView: View {
    @EnvironmentObject var router: NavigationRouter
    @State private var workerName: String = ""
    @State private var answers: [Bool?] = Array(repeating: nil, count: 10)
    @State private var showResult: Bool = false
    
    let questions = [
        "Do visitors wear clean boots before entering?",
        "Is there a footbath with disinfectant at entrance?",
        "Are new animals kept separate for 14 days?",
        "Are sick animals separated from healthy ones?",
        "Is cattle shed cleaned daily?",
        "Are water troughs cleaned daily?",
        "Are all cattle vaccinated on time?",
        "Is milking area cleaned daily?",
        "Is feed stored in closed containers?",
        "Do workers wash hands before and after?"
    ]
    
    // Formatting date as "10 Mar 2026"
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: Date())
    }
    
    var yesCount: Int {
        answers.compactMap { $0 }.filter { $0 == true }.count
    }
    
    var isSafe: Bool { yesCount >= 8 }
    var isModerate: Bool { yesCount >= 5 && yesCount <= 7 }
    var isRisk: Bool { yesCount <= 4 }
    
    var missingQuestions: [(Int, String)] {
        var issues: [(Int, String)] = []
        for (index, answer) in answers.enumerated() {
            if answer == false {
                issues.append((index + 1, formatNegativeReason(for: index)))
            }
        }
        return issues
    }

    private func formatNegativeReason(for index: Int) -> String {
        switch index {
        case 0: return "Visitors not wearing clean boots"
        case 1: return "No footbath at entrance"
        case 2: return "New animals not separated"
        case 3: return "Sick animals mixed with healthy"
        case 4: return "Shed not cleaned daily"
        case 5: return "Water troughs not cleaned daily"
        case 6: return "Vaccinations missed"
        case 7: return "Milking area not cleaned daily"
        case 8: return "Feed not in closed containers"
        case 9: return "Workers not washing hands"
        default: return "Requirement not met"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.pop() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text(showResult ? "YOUR SCORE" : "BIO SECURITY CHECK")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(.label))
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Divider().padding(.top, 10)
            
            if showResult {
                resultView
            } else {
                checklistView
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
    
    // MARK: - Checklist View
    private var checklistView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Info block
                VStack(spacing: 12) {
                    HStack {
                        Text("📅 Date: ")
                            .font(.system(size: 16, weight: .semibold))
                        Text(currentDateString)
                            .font(.system(size: 16))
                        Spacer()
                    }
                    HStack {
                        Text("👨‍🌾 Worker: ")
                            .font(.system(size: 16, weight: .semibold))
                        TextField("Enter name", text: $workerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("ANSWER YES OR NO TO EACH QUESTION")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                
                // Questions
                VStack(spacing: 16) {
                    ForEach(0..<questions.count, id: \.self) { index in
                        QuestionRow(
                            index: index + 1,
                            question: questions[index],
                            answer: $answers[index]
                        )
                    }
                }
                .padding(.horizontal)
                
                // Submit Button
                Button(action: {
                    guard answers.allSatisfy({ $0 != nil }) else { return }
                    withAnimation { showResult = true }
                }) {
                    Text("CHECK SCORE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(answers.contains(nil) ? Color.gray : Color.blue)
                        .cornerRadius(16)
                }
                .disabled(answers.contains(nil))
                .padding()
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Score Box
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    
                    VStack(spacing: 12) {
                        Text("🐄")
                            .font(.system(size: 50))
                        Text("\(yesCount)/10")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(resultColor)
                    }
                    .padding(.vertical, 30)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Status Description
                VStack(spacing: 8) {
                    if isSafe {
                        Text("✅ SAFE (8-10 YES)")
                            .font(.title2.bold())
                            .foregroundColor(Color(hex: "22c55e"))
                        Text("Your farm is doing well!")
                            .foregroundColor(.gray)
                    } else if isModerate {
                        Text("⚠️ MODERATE (5-7 YES)")
                            .font(.title2.bold())
                            .foregroundColor(Color(hex: "f97316"))
                        Text("Needs improvement!")
                            .foregroundColor(.gray)
                    } else {
                        Text("❌ RISK (0-4 YES)")
                            .font(.title2.bold())
                            .foregroundColor(Color(hex: "ef4444"))
                        Text("Take action now!")
                            .foregroundColor(.gray)
                    }
                }
                
                // Failed Questions
                if !missingQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUESTIONS WITH \"NO\":")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Divider()
                        
                        ForEach(missingQuestions, id: \.0) { num, reason in
                            HStack(alignment: .top) {
                                Text("❌")
                                Text("Q\(num): \(reason)")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation { showResult = false }
                    }) {
                        Text("BACK TO CHECKLIST")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        // Normally save logic here. We can just pop back for now.
                        router.pop()
                    }) {
                        Text("SAVE")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.bottom, 30)
        }
    }
    
    private var resultColor: Color {
        if isSafe { return Color(hex: "22c55e") }
        if isModerate { return Color(hex: "f97316") }
        return Color(hex: "ef4444")
    }
}

private struct QuestionRow: View {
    let index: Int
    let question: String
    @Binding var answer: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(index). \(question)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(.darkText))
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 16) {
                // YES Button
                Button(action: { answer = true }) {
                    Text("YES")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(answer == true ? .white : Color(.darkGray))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(answer == true ? Color(hex: "22c55e") : Color(.systemGray5))
                        .cornerRadius(12)
                }
                
                // NO Button
                Button(action: { answer = false }) {
                    Text("NO")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(answer == false ? .white : Color(.darkGray))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(answer == false ? Color(hex: "ef4444") : Color(.systemGray5))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
    }
}

// Simple color hex extension for UI components
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    BiosecurityChecklistView()
        .environmentObject(NavigationRouter())
}
