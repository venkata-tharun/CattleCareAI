import SwiftUI

// MARK: - Equipments Home View
struct EquipmentsHomeView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Equipments")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "info.circle.fill").foregroundColor(.purple)
                        Text("Saves to Equipment Report.").font(.system(size: 13, weight: .medium)).foregroundColor(.purple)
                        Spacer()
                    }
                    .padding(12).background(Color.purple.opacity(0.1)).cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    EquipmentMenuCard(
                        title: "Chaff Cutter",
                        description: "Fast cutting for all types of fodder",
                        emoji: "⚡",
                        color: .green,
                        action: { router.push(.chaffCutterDetail) }
                    )
                    
                    EquipmentMenuCard(
                        title: "Milking Machine",
                        description: "Hygienic and fast milking process",
                        emoji: "🐄",
                        color: .cyan,
                        action: { router.push(.milkingMachineDetail) }
                    )
                }
                .padding(16)
            }
        }
        .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct EquipmentMenuCard: View {
    let title: String
    let description: String
    let emoji: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 32))
                    .frame(width: 64, height: 64)
                    .background(color.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Chaff Cutter Detail View
struct ChaffCutterDetailView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Chaff Cutter")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Option A: One-line Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Feature: Cuts Fast | Feature: Safe to Use | Feature: Strong Build")
                            .font(.system(size: 16, weight: .medium))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Option B: 4 Key Features (Bullet points)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detailed Features")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            EquipmentFeatureRow(emoji: "⚡", label: "Fast Cutting", explanation: "Cuts 400 to 2,100 kg of fodder in just 1 hour")
                            EquipmentFeatureRow(emoji: "🌾", label: "Works on All Fodder", explanation: "Use for both dry hay and green grass")
                            EquipmentFeatureRow(emoji: "🔌", label: "3 Power Options", explanation: "Run by hand, electricity, or tractor")
                            EquipmentFeatureRow(emoji: "🔪", label: "Strong Blades", explanation: "Made of hard steel, lasts long")
                            EquipmentFeatureRow(emoji: "📏", label: "Adjustable Size", explanation: "Cut small or big pieces as you need")
                            EquipmentFeatureRow(emoji: "🛞", label: "Easy to Move", explanation: "Comes with wheels, push anywhere")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    
                    // Option C: Badge Style
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Info")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        BadgeGrid(badges: [
                            ("⚡", "Electric/Manual"),
                            ("🛡️", "Safety Guard"),
                            ("🚜", "Very Strong"),
                            ("📦", "Easy to Store"),
                            ("🔧", "Low Service")
                        ])
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Milking Machine Detail View
struct MilkingMachineDetailView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Milking Machine")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Option A: One-line Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Feature: Clean Milk | Feature: Saves Time | Feature: Happy Cows")
                            .font(.system(size: 16, weight: .medium))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.cyan.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Option B: 4 Key Features (Bullet points)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detailed Features")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            EquipmentFeatureRow(emoji: "🐄", label: "Fast Milking", explanation: "Milk 10 to 25 cows in just 1 hour")
                            EquipmentFeatureRow(emoji: "🥛", label: "Clean Milk", explanation: "Goes directly into 20-25 liter steel container")
                            EquipmentFeatureRow(emoji: "🐮", label: "Gentle on Animals", explanation: "Soft cups and light suction, cows feel comfortable")
                            EquipmentFeatureRow(emoji: "🛞", label: "Easy to Move", explanation: "Has wheels and handle, roll it anywhere")
                            EquipmentFeatureRow(emoji: "🧼", label: "Clean & Safe", explanation: "Fully sealed, no dirt or germs enter milk")
                            EquipmentFeatureRow(emoji: "⚡", label: "Runs on Electricity", explanation: "Works with normal power supply")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    
                    // Option C: Badge Style
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Info")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        BadgeGrid(badges: [
                            ("🐄", "25 Cows/hr"),
                            ("🥛", "Clean Flow"),
                            ("🔇", "No Noise"),
                            ("🧼", "Easy Wash"),
                            ("🔋", "Battery Power")
                        ])
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Views
struct EquipmentFeatureRow: View {
    let emoji: String
    let label: String
    let explanation: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 20))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                Text(explanation)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct HeaderView: View {
    let title: String
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        HStack {
            Button { router.pop() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
            }
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 12)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
}

struct FeatureBullet: View {
    let label: String
    let explanation: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 18))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                Text(explanation)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct BadgeView: View {
    let emoji: String
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(emoji)
            Text(label)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

struct BadgeGrid: View {
    let badges: [(String, String)]
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
        
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(badges, id: \.0) { badge in
                BadgeView(emoji: badge.0, label: badge.1)
            }
        }
    }
}
