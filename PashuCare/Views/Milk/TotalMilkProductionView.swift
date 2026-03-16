import SwiftUI

// NOTE:
// This file uses MilkEntry + MilkType model.
// Keep the SAME model in your project (either in Entry file or in a separate file).

struct TotalMilkProductionView: View {

    let entry: MilkEntry
    var onAddNew: (() -> Void)? = nil

    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {

            // Top bar
            HStack(spacing: 12) {

                Text("Total Milk Production")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    // Big teal card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.95))
                            Text("Total Milk Product")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.95))
                            Spacer()
                        }

                        Text(String(format: "%.1f", entry.totalMilkProduced))
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)

                        Text("Litres")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.95))
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.05, green: 0.75, blue: 0.72))
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 6)

                    // Date + Milk Type cards
                    HStack(spacing: 12) {
                        SmallInfoCard(icon: "calendar",
                                      title: "Date",
                                      value: Self.df.string(from: entry.date))

                        SmallInfoCard(icon: "drop",
                                      title: "Milk Type",
                                      value: entry.milkType.rawValue)
                    }

                    // Session Production
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Production")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)

                        HStack(spacing: 0) {
                            SessionItem(title: "Morning", value: entry.am)
                            Divider()
                            SessionItem(title: "Noon", value: entry.noon)
                            Divider()
                            SessionItem(title: "Evening", value: entry.pm)
                        }
                        .frame(height: 60)
                    }
                    .cardStyle()

                    // Total Used + Remaining
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "drop")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text("Total Used")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(String(format: "%.2f", entry.totalUsed))
                                    .font(.system(size: 22, weight: .bold))
                                Text("L")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("Remaining")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)

                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(String(format: "%.1f", entry.remaining))
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(red: 0.05, green: 0.75, blue: 0.72))
                                Text("L")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .cardStyle()

                    // Cattle Tag
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "tag")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("Cattle Tag No.")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }

                        Text(entry.cattleTag.isEmpty ? "-" : entry.cattleTag)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .cardStyle()

                    // Note
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("Note")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }

                        Text(entry.note.isEmpty ? "-" : entry.note)
                            .font(.system(size: 15))
                            .foregroundColor(.primary.opacity(0.85))
                    }
                    .cardStyle()

                    Spacer().frame(height: 90)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
            .background(Color(.systemGroupedBackground))
            .overlay(alignment: .bottom) {

                Button { onAddNew?() } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                        Text("Add New Entry")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0.05, green: 0.75, blue: 0.72))
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.14), radius: 10, x: 0, y: 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Small Components

private struct SmallInfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
        }
        .cardStyle()
    }
}

private struct SessionItem: View {
    let title: String
    let value: Double

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.05, green: 0.75, blue: 0.72))

                Text(value == 0 ? "0.0" : String(format: "%.1f", value))
                    .font(.system(size: 16, weight: .bold))
            }

            Text("L")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .offset(y: -2)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    TotalMilkProductionView(entry: MilkEntry(milkType: .bulk, cattleTag: "COW-10", am: 10, noon: 5, pm: 7, totalUsed: 3, note: "Sample note"))
}
