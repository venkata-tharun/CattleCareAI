import SwiftUI

// MARK: - Transactions View
struct TransactionsView: View {
    @EnvironmentObject var transactionManager: TransactionDataManager
    @EnvironmentObject var router: NavigationRouter
    @State private var selectedSegment = "Income"

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { router.pop() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Text("Transaction")
                        .font(.system(size: 26, weight: .bold))
                        .padding(.leading, 12)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Segment
                HStack(spacing: 0) {
                    segmentBtn("Income")
                    segmentBtn("Expense")
                }
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                let filtered = transactionManager.transactions.filter { $0.category == selectedSegment }

                if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.teal.opacity(0.4))
                        Text("Click on the add button to add Transaction")
                            .font(.system(size: 16, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .padding(40)
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(24)
                    .padding(24)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filtered) { t in
                                TransactionRowCard(transaction: t)
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 80)
                    }
                }
            }

            // Floating + button
            Button {
                router.push(.newTransaction(selectedSegment))
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.teal)
                    .clipShape(Circle())
                    .shadow(color: Color.teal.opacity(0.35), radius: 10, x: 0, y: 6)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private func segmentBtn(_ title: String) -> some View {
        Button { withAnimation(.spring()) { selectedSegment = title } } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(selectedSegment == title ? .white : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(selectedSegment == title ? Color.teal : Color.clear)
                .cornerRadius(10)
        }
    }
}

// MARK: - New Transaction View
struct NewTransactionView: View {
    let category: String
    @EnvironmentObject var transactionManager: TransactionDataManager
    @EnvironmentObject var router: NavigationRouter

    @State private var date = Date()
    @State private var selectedType = ""
    @State private var customType = ""
    @State private var showTypeMenu = false
    @State private var amount = ""
    @State private var receiptNo = ""
    @State private var note = ""

    private var incomeTypes: [String] { ["Milk Sale", "Cattle Sale", "Category Income", "Other (Specify)"] }
    private var expenseTypes: [String] { ["Feed Purchase", "Medicine", "Labour", "Equipment", "Other (Specify)"] }
    private var typeOptions: [String] { category == "Income" ? incomeTypes : expenseTypes }

    private var finalType: String {
        if selectedType == "Other (Specify)" { return customType }
        return selectedType
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button { router.pop() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
                Text("New Transaction")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading, 12)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            ScrollView {
                VStack(spacing: 20) {
                    CustomDatePickerField(
                        icon: "calendar",
                        label: "Date of \(category)",
                        date: $date
                    )

                    VStack(spacing: 0) {
                        Button {
                            withAnimation(.spring()) { showTypeMenu.toggle() }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "tag")
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(category) Type*")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text(selectedType.isEmpty ? "- Select \(category) Type -" : selectedType)
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedType.isEmpty ? Color(.placeholderText) : .primary)
                                }
                                Spacer()
                                Image(systemName: showTypeMenu ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 64)
                        }
                        .buttonStyle(.plain)

                        if showTypeMenu {
                            Divider()
                            VStack(spacing: 0) {
                                ForEach(typeOptions, id: \.self) { option in
                                    Button {
                                        withAnimation { selectedType = option; showTypeMenu = false }
                                    } label: {
                                        HStack {
                                            Text(option)
                                                .font(.system(size: 15, weight: selectedType == option ? .semibold : .regular))
                                                .foregroundColor(selectedType == option ? .teal : .primary)
                                            Spacer()
                                            if selectedType == option {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.teal)
                                                    .font(.system(size: 13, weight: .semibold))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(.plain)
                                    if option != typeOptions.last {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if selectedType == "Other (Specify)" {
                        fieldCard(icon: "square.and.pencil", label: "Specify Type*") {
                            TextField("Enter custom type", text: $customType)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    fieldCard(icon: "indianrupeesign.circle", label: category == "Income" ? "Total Earn*" : "Total Spend*") {
                        TextField("0.0", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    fieldCard(icon: "doc.plaintext", label: "Receipt No") {
                        TextField("Receipt No", text: $receiptNo)
                    }

                    fieldCard(icon: "pencil", label: "Note") {
                        TextField("Note", text: $note)
                    }

                    Spacer(minLength: 20)
                }
                .padding(20)
            }

            Button {
                guard let amt = Double(amount), !finalType.isEmpty else { return }
                transactionManager.addTransaction(TransactionItem(
                    id: 0, // Backend assigns real ID
                    category: category, date: date, type: finalType,
                    amount: amt, receiptNo: receiptNo, note: note
                ))
                router.pop()
            } label: {
                Text("Save")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.teal)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .padding(.top, 8)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private func fieldCard<C: View>(icon: String, label: String, @ViewBuilder content: () -> C) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                content()
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Transaction Row Card
struct TransactionRowCard: View {
    let transaction: TransactionItem
    private let df: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; return f
    }()

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(transaction.category == "Income" ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.category == "Income" ? "arrow.down.left" : "arrow.up.right")
                    .foregroundColor(transaction.category == "Income" ? .green : .red)
                    .font(.system(size: 18, weight: .bold))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.type)
                    .font(.system(size: 16, weight: .semibold))
                Text(df.string(from: transaction.date))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(String(format: "%@₹%.2f", transaction.category == "Income" ? "+" : "-", transaction.amount))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(transaction.category == "Income" ? .green : .red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        )
    }
}
