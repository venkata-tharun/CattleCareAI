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

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Sanitation")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Hygiene Score Card
                        VStack(spacing: 12) {
                            Text("Current Hygiene Score")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)

                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green)
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text("\(sanitationManager.score)")
                                        .font(.system(size: 52, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("/100")
                                        .font(.system(size: 22))
                                        .foregroundColor(.secondary)
                                }
                            }

                            Text(sanitationManager.conditionText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(sanitationManager.conditionColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.green, lineWidth: 3)
                                        .mask(
                                            VStack {
                                                Rectangle().frame(height: 3)
                                                Spacer()
                                            }
                                        )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                        // Daily Checklist Card
                        VStack(spacing: 16) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.12))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "checkmark.square.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.green)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Checklist")
                                        .font(.system(size: 17, weight: .bold))
                                    Text("Track cleaning tasks")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }

                            Button {
                                router.push(.sanitationChecklist)
                            } label: {
                                Text("Open Checklist")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.green)
                                    .cornerRadius(25)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
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

    private var completedCount: Int {
        [footbath, shedCleaning, equipmentWash, waterTroughs, wasteDisposal, feedingArea]
            .filter { $0 }.count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Daily Checklist")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                // Progress indicator
                HStack {
                    Text("\(completedCount)/6 tasks completed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(completedCount * 100 / 6)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)

                ProgressView(value: Double(completedCount), total: 6.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
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
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }

            // Save Button
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.green)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func checklistRow(label: String, binding: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
            Spacer()
            Toggle("", isOn: binding)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SanitationHubView()
            .environmentObject(NavigationRouter())
    }
}
