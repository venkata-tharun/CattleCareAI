//
//  ContentView.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//
import SwiftUI

extension Notification.Name {
    static let logoutNotification = Notification.Name("logoutNotification")
    static let loginNotification  = Notification.Name("loginNotification")
}


enum AppRoute: Hashable {
    // Auth
    case welcome
    case login
    case createaccount
    case forgotpassword
    case otp(String, Bool) // (emailOrPhone, isRegistration)
    case reset(String, String)     // emailOrPhone, resetToken
    case home
    case mainTabs

    // Milk
    case milk
    case editMilk(MilkEntry)
    case milkRecordList
    case res(MilkEntry)

    // Animals
    case animalsList
    case animalDetail(Animal)
    case addAnimal
    case addHealthRecord(Animal)
    case editHealthRecord(Animal, HealthRecord)
    case addVaccineRecord(Animal)
    case editVaccineRecord(Animal, Vaccination)

    // Visitors
    case visitors
    case visitorList
    case addVisitor
    case visitorDetail(Visitor)
    case editVisitor(Visitor)

    // Feeding
    case feeding
    case feedingEntry
    case feedStock
    case feedingSchedule

    // Sanitation
    case sanitation
    case sanitationChecklist
    case biosecurityCheck

    // Reports
    case reportsList
    case reportDetail(ReportType)

    // Logs
    case logs
    case logDetail(FarmLog)
    case addLog
    case editLog(FarmLog)
    
    // Transactions
    case transactions
    case newTransaction(String) // category: "Income" or "Expense"

    // Settings
    case settings
    case profileSettings
    case notificationSettings
    case helpSupport

    // AI Disease Prediction
    case aiDiseasePrediction
    case aiImagePreview(UIImage)
    case aiPredictionResult(UIImage, DiseasePrediction)
    case addStock
    case updateSchedule(FeedingScheduleItem?)
    
    // Calving Tracker
    case calvingTrackerHome
    case addCalvingRecord
    case calvingRecordsList
    case calvingRecordDetail(CalvingRecord)
    case editCalvingRecord(CalvingRecord)
    
    // Machinery
    case equipments
    case chaffCutterDetail
    case milkingMachineDetail

    // Hashable conformance for associated value types
    func hash(into hasher: inout Hasher) {
        switch self {
        case .welcome: hasher.combine(0)
        case .login: hasher.combine(1)
        case .createaccount: hasher.combine(2)
        case .forgotpassword: hasher.combine(3)
        case .otp(let email, let isReg):
            hasher.combine(43)
            hasher.combine(email)
            hasher.combine(isReg)
        case .reset(let email, let token):
            hasher.combine(4)
            hasher.combine(email)
            hasher.combine(token)
        case .home: hasher.combine(5)
        case .mainTabs: hasher.combine(6)
        case .milk:
            hasher.combine(7)
        case .editMilk(let entry):
            hasher.combine(71)
            hasher.combine(entry.id)
        case .milkRecordList:
            hasher.combine(8)
        case .res(let e): hasher.combine(9); hasher.combine(e)
        case .animalsList: hasher.combine(10)
        case .animalDetail(let a): hasher.combine(11); hasher.combine(a)
        case .addAnimal: hasher.combine(12)
        case .addHealthRecord(let a): hasher.combine(13); hasher.combine(a)
        case .editHealthRecord(let a, let r): hasher.combine(131); hasher.combine(a); hasher.combine(r)
        case .addVaccineRecord(let a): hasher.combine(14); hasher.combine(a)
        case .editVaccineRecord(let a, let v): hasher.combine(141); hasher.combine(a); hasher.combine(v)
        case .visitors: hasher.combine(15)
        case .visitorList: hasher.combine(45)
        case .addVisitor: hasher.combine(16)
        case .visitorDetail(let v): hasher.combine(17); hasher.combine(v.id)
        case .editVisitor(let v): hasher.combine(44); hasher.combine(v.id)
        case .feeding: hasher.combine(18)
        case .feedingEntry: hasher.combine(19)
        case .feedStock: hasher.combine(20)
        case .feedingSchedule: hasher.combine(21)
        case .sanitation: hasher.combine(22)
        case .sanitationChecklist: hasher.combine(23)
        case .biosecurityCheck: hasher.combine(60)
        case .reportsList: hasher.combine(27)
        case .reportDetail(let r): hasher.combine(28); hasher.combine(r.rawValue)
        case .logs: hasher.combine(29)
        case .logDetail(let l): hasher.combine(30); hasher.combine(l.id)
        case .addLog: hasher.combine(31)
        case .editLog(let l): hasher.combine(32); hasher.combine(l.id)
        case .settings: hasher.combine(33)
        case .profileSettings: hasher.combine(34)
        case .notificationSettings: hasher.combine(35)
        case .helpSupport: hasher.combine(36)
        case .aiDiseasePrediction: hasher.combine(37)
        case .aiImagePreview(let img):
            hasher.combine(38)
            hasher.combine(ObjectIdentifier(img))
        case .aiPredictionResult(let img, let pred):
            hasher.combine(39)
            hasher.combine(ObjectIdentifier(img))
            hasher.combine(pred)
        case .addStock: hasher.combine(40)
        case .updateSchedule(let item):
            hasher.combine(41)
            hasher.combine(item?.id)
        case .transactions: hasher.combine(42)
        case .newTransaction(let cat): hasher.combine(41); hasher.combine(cat)
        
        case .calvingTrackerHome: hasher.combine(50)
        case .addCalvingRecord: hasher.combine(51)
        case .calvingRecordsList: hasher.combine(52)
        case .calvingRecordDetail(let r): hasher.combine(53); hasher.combine(r.id)
        case .editCalvingRecord(let r): hasher.combine(54); hasher.combine(r.id)
        
        case .equipments: hasher.combine(57)
        case .chaffCutterDetail: hasher.combine(55)
        case .milkingMachineDetail: hasher.combine(56)
        }
    }

    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.welcome, .welcome), (.login, .login), (.createaccount, .createaccount),
             (.forgotpassword, .forgotpassword), (.home, .home),
             (.milk, .milk), (.milkRecordList, .milkRecordList),
             (.animalsList, .animalsList), (.addAnimal, .addAnimal),
             (.visitors, .visitors), (.visitorList, .visitorList), (.addVisitor, .addVisitor),
             (.feeding, .feeding), (.feedingEntry, .feedingEntry),
             (.feedStock, .feedStock), (.feedingSchedule, .feedingSchedule),
             (.sanitation, .sanitation), (.sanitationChecklist, .sanitationChecklist),
             (.biosecurityCheck, .biosecurityCheck),
             (.reportsList, .reportsList),
             (.logs, .logs), (.addLog, .addLog),
             (.settings, .settings), (.profileSettings, .profileSettings),
             (.notificationSettings, .notificationSettings), (.helpSupport, .helpSupport),
             (.aiDiseasePrediction, .aiDiseasePrediction):
            return true
        case (.editMilk(let a), .editMilk(let b)): return a.id == b.id
        case (.res(let a), .res(let b)): return a == b
        case (.animalDetail(let a), .animalDetail(let b)): return a == b
        case (.otp(let e1, let r1), .otp(let e2, let r2)): return e1 == e2 && r1 == r2
        case (.reset(let e1, let t1), .reset(let e2, let t2)): return e1 == e2 && t1 == t2
        case (.addHealthRecord(let a), .addHealthRecord(let b)): return a == b
        case (.editHealthRecord(let a1, let r1), .editHealthRecord(let a2, let r2)): return a1 == a2 && r1 == r2
        case (.addVaccineRecord(let a), .addVaccineRecord(let b)): return a == b
        case (.editVaccineRecord(let a1, let v1), .editVaccineRecord(let a2, let v2)): return a1 == a2 && v1 == v2
        case (.visitorDetail(let a), .visitorDetail(let b)): return a.id == b.id
        case (.editVisitor(let a), .editVisitor(let b)): return a.id == b.id
        case (.reportDetail(let a), .reportDetail(let b)): return a == b
        case (.logDetail(let a), .logDetail(let b)): return a.id == b.id
        case (.editLog(let a), .editLog(let b)): return a.id == b.id
        case (.aiImagePreview(let a), .aiImagePreview(let b)): return a === b
        case (.aiPredictionResult(let i1, let p1), .aiPredictionResult(let i2, let p2)): return i1 === i2 && p1 == p2
        case (.addStock, .addStock): return true
        case (.updateSchedule(let a), .updateSchedule(let b)): return a?.id == b?.id
        case (.transactions, .transactions): return true
        case (.newTransaction(let a), .newTransaction(let b)): return a == b
            
        case (.calvingTrackerHome, .calvingTrackerHome), (.addCalvingRecord, .addCalvingRecord), (.calvingRecordsList, .calvingRecordsList): return true
        case (.calvingRecordDetail(let a), .calvingRecordDetail(let b)): return a.id == b.id
        case (.editCalvingRecord(let a), .editCalvingRecord(let b)): return a.id == b.id
            
        case (.equipments, .equipments), (.chaffCutterDetail, .chaffCutterDetail), (.milkingMachineDetail, .milkingMachineDetail): return true
            
        default: return false
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var tabRouter = TabRouter()
    @State private var isLoggedIn = false

    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                GetStartedView()
                    .environmentObject(router)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else if isLoggedIn {
                FarmAppRootTabs()
                    .environmentObject(tabRouter)
                    .transition(.opacity)
            } else {
                NavigationStack(path: $router.path) {
                    WelcomeView()
                        .environmentObject(router)
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .welcome:
                                WelcomeView()
                                    .environmentObject(router)
                            case .login:
                                LoginView(isLoggedIn: $isLoggedIn)
                                    .environmentObject(router)
                            case .createaccount:
                                SignupView()
                                    .environmentObject(router)
                            case .forgotpassword:
                                ForgotPasswordView()
                                    .environmentObject(router)
                            case .otp(let email, let isReg):
                                OTPVerificationView(emailOrPhone: email, isRegistration: isReg)
                                    .environmentObject(router)
                            case .reset(let email, let token):
                                ForgotPasswordResetView(emailOrPhone: email, resetToken: token)
                                    .environmentObject(router)
                            case .home, .mainTabs:
                                Color.clear
                                    .onAppear {
                                        isLoggedIn = true
                                    }
                            case .equipments:
                                EquipmentsHomeView()
                                    .environmentObject(router)
                            case .reportsList:
                                ReportsListView()
                                    .environmentObject(router)
                            case .chaffCutterDetail:
                                ChaffCutterDetailView()
                                    .environmentObject(router)
                            case .milkingMachineDetail:
                                MilkingMachineDetailView()
                                    .environmentObject(router)
                            default:
                                EmptyView()
                            }
                        }
                }
            }
        }
        .animation(.default, value: isLoggedIn)
        .onAppear {
            checkSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: .logoutNotification)) { _ in
            isLoggedIn = false
            router.popToRoot()
            tabRouter.selectedTab = .home
        }
        .onReceive(NotificationCenter.default.publisher(for: .loginNotification)) { _ in
            withAnimation {
                isLoggedIn = true
            }
        }
    }

    private func checkSession() {
        NetworkManager.shared.me { user in
            if user != nil {
                withAnimation { isLoggedIn = true }
            }
        }
    }
}
