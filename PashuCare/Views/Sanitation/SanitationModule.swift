//
//  SanitationModule.swift
//  PashuCare
//
//  Created by SAIL on 03/03/26.
//

import SwiftUI

// MARK: - Sanitation Hub View

struct SanitationHubView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var sanitationManager: SanitationDataManager
    @State private var appearAnimated = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .bottom) {
                    Color.white
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 50)
                    
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        Text("Sanitation")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.9))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .zIndex(1)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hygiene Score Card
                        VStack(spacing: 16) {
                            Text("Current Hygiene Score")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(white: 0.5))

                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.green)
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text("\(sanitationManager.score ?? 0)")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundColor(sanitationManager.score == nil ? .black.opacity(0.3) : .black.opacity(0.85))
                                    Text("/100")
                                        .font(.system(size: 24, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)

                            Text(sanitationManager.conditionText)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(sanitationManager.conditionColor)
                                .clipShape(Capsule())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 36)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.green.opacity(0.15), lineWidth: 4)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                        .offset(y: appearAnimated ? 0 : 20)
                        .opacity(appearAnimated ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0), value: appearAnimated)

                        // Daily Checklist Card
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "checkmark.square.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Checklist")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.black.opacity(0.85))
                                    Text("Track cleaning tasks")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(white: 0.5))
                                }

                                Spacer()
                            }

                            Button {
                                router.push(.sanitationChecklist)
                            } label: {
                                Text("Open Checklist")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.green)
                                    .cornerRadius(28)
                                    .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                        .offset(y: appearAnimated ? 0 : 20)
                        .opacity(appearAnimated ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: appearAnimated)
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimated = true
            }
        }
    }
}

// MARK: - Sanitation Checklist View

struct SanitationChecklistView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var sanitationManager: SanitationDataManager
    @State private var footbath = false
    @State private var shedCleaning = false
    @State private var equipmentWash = false
    @State private var waterTroughs = false
    @State private var wasteDisposal = false
    @State private var feedingArea = false
    @State private var appearAnimated = false

    private var completedCount: Int {
        [footbath, shedCleaning, equipmentWash, waterTroughs, wasteDisposal, feedingArea]
            .filter { $0 }.count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium Header
                ZStack(alignment: .bottom) {
                    Color.white
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 50)
                    
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        Text("Daily Checklist")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.9))

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .zIndex(1)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Progress Indicator Card
                        VStack(spacing: 12) {
                            HStack {
                                Text("\(completedCount)/6 tasks completed")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(white: 0.5))
                                Spacer()
                                Text("\(completedCount * 100 / 6)%")
                                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                                    .foregroundColor(.green)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 12)
                                    
                                    Capsule()
                                        .fill(Color.green)
                                        .frame(width: geo.size.width * CGFloat(completedCount) / 6.0, height: 12)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: completedCount)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                        .offset(y: appearAnimated ? 0 : 20)
                        .opacity(appearAnimated ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: appearAnimated)

                        // Checklist Options Card
                        VStack(spacing: 0) {
                            checklistRow(label: "Footbath Maintained", binding: $footbath)
                            Divider().padding(.leading, 16)
                            checklistRow(label: "Shed Cleaning Done", binding: $shedCleaning)
                            Divider().padding(.leading, 16)
                            checklistRow(label: "Equipment Washed", binding: $equipmentWash)
                            Divider().padding(.leading, 16)
                            checklistRow(label: "Water Troughs Cleaned", binding: $waterTroughs)
                            Divider().padding(.leading, 16)
                            checklistRow(label: "Waste Disposal Done", binding: $wasteDisposal)
                            Divider().padding(.leading, 16)
                            checklistRow(label: "Feeding Area Sanitized", binding: $feedingArea)
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                        .offset(y: appearAnimated ? 0 : 20)
                        .opacity(appearAnimated ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: appearAnimated)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(20)
                }
            }

            // Save Button Frame
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.96, blue: 0.98).opacity(0), Color(red: 0.95, green: 0.96, blue: 0.98)],
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(height: 40)
                .allowsHitTesting(false)

                Button {
                    let tasks = [
                        "Footbath": footbath,
                        "Shed Cleaning": shedCleaning,
                        "Equipment Wash": equipmentWash,
                        "Water Troughs": waterTroughs,
                        "Waste Disposal": wasteDisposal,
                        "Feeding Area": feedingArea
                    ]
                    sanitationManager.saveChecklist(tasks: tasks) { _ in
                        dismiss()
                    }
                } label: {
                    Text("Save Checklist")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.green)
                        .cornerRadius(29)
                        .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(Color(red: 0.95, green: 0.96, blue: 0.98))
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimated = true
            }
        }
    }

    @ViewBuilder
    private func checklistRow(label: String, binding: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(0.85))
            Spacer()
            Toggle("", isOn: binding)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                binding.wrappedValue.toggle()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SanitationHubView()
            .environmentObject(NavigationRouter())
    }
}
