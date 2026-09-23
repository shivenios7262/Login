import Foundation
import Observation

// MARK: - Tab

enum AgentProfileTab: String, CaseIterable, Identifiable {
    case agentProfile = "Agent Profile"
    case traveller    = "Traveller"
    case gst          = "GST"
    var id: String { rawValue }
}

// MARK: - Traveller Display Model

struct TravellerListItem: Identifiable, Sendable {
    let id: String          // travel_id
    let title: String
    let firstName: String
    let lastName: String
    let paxType: String
    let dob: String
    let nationality: String
    let passportNo: String
    let issueCountry: String
    let expiryDate: String
    let age: String
    let gender: String

    var fullName: String {
        [title, firstName, lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

// MARK: - GST Display Model

struct GSTListItem: Identifiable, Sendable {
    let id: String
    let gstin: String
    let company: String
    let mobileNo: String
    let email: String
    let address: String
}

// MARK: - ViewModel

@Observable
@MainActor
final class AgentProfileEditViewModel {

    // MARK: Tab
    var selectedTab: AgentProfileTab = .agentProfile

    // MARK: Profile — editable fields
    var title       = "Mr."
    var firstName   = ""
    var lastName    = ""
    var designation = ""
    var website     = ""
    var officePhone = ""
    var address     = ""
    var city        = ""
    var state       = ""
    var country     = "India"
    var pinCode     = ""

    // MARK: Profile — read-only identity fields (from server, shown for reference)
    var panNo       = ""
    var namePanCard = ""
    var aadharNo    = ""
    var agencyName  = ""
    var contactNo   = ""

    // MARK: Profile update state
    var isLoadingProfile  = false
    var isUpdatingProfile = false
    var profileMessage: String? = nil
    var profileMessageIsError  = false

    // MARK: Password reset
    var currentPassword = ""
    var newPassword     = ""
    var confirmPassword = ""
    var isChangingPassword = false
    var passwordMessage: String? = nil
    var passwordMessageIsError  = false

    // MARK: Traveller form
    var travellerPaxType      = "Adult"
    var travellerTitle        = ""
    var travellerFirstName    = ""
    var travellerLastName     = ""
    var travellerDOBDate: Date = Date()
    var travellerNationality  = ""
    var travellerPassport     = ""
    var travellerIssueCountry = ""
    var travellerExpiryDateObj: Date = Calendar.current.date(byAdding: .year, value: 5, to: Date()) ?? Date()
    var travellerAge          = ""
    var travellerGender       = "Male"
    var editingTravellerId: String? = nil
    var isAddingTraveller     = false
    var travellerMessage: String? = nil
    var travellerMessageIsError   = false

    // MARK: Traveller list
    var travellerList: [TravellerListItem] = []
    var travellerSearchQuery  = ""
    var isDeletingTravellerId: String? = nil

    // MARK: Traveller multi-select
    var isTravellerMultiSelectMode  = false
    var selectedTravellerIds: Set<String> = []
    var isDeletingMultipleTravellers = false

    // MARK: GST form
    var gstNumber   = ""
    var gstCompany  = ""
    var gstMobile   = ""
    var gstEmail    = ""
    var gstAddress  = ""
    var editingGSTId: String? = nil
    var isSubmittingGST   = false
    var gstFormMessage: String? = nil
    var gstFormMessageIsError   = false

    // MARK: GST list
    var gstList: [GSTListItem] = []
    var gstSearchQuery = ""
    var isDeletingGSTId: String? = nil

    // MARK: GST multi-select
    var isGSTMultiSelectMode      = false
    var selectedGSTIds: Set<String> = []
    var isDeletingMultipleGSTs    = false

    // MARK: Options
    let titleOptions   = ["Mr.", "Mrs.", "Ms."/*, "Dr.", "Prof.", "Master", "Miss"*/]
    let paxTypeOptions = ["Adult", "Child", "Infant"]
    let genderOptions  = ["Male", "Female"]
    var countryOptions: [String] = []

    // MARK: Agent logo
    var agentLogoURL: URL? = nil
    var selectedLogoData: Data? = nil

    private static let dobFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MMM-yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private var formattedTravellerDOB: String {
        Self.dobFormatter.string(from: travellerDOBDate)
    }

    var formattedTravellerExpiry: String {
        Self.dobFormatter.string(from: travellerExpiryDateObj)
    }

    // MARK: Certificate (derived from session)
    var agentNo: String { authManager.currentUser?.agentNo ?? "" }
    var agentEmail: String { authManager.currentUser?.agentEmail ?? "" }
    var memberSince: String { authManager.currentUser?.registerDate ?? "" }

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Load Profile

    func loadProfile() async {
        isLoadingProfile = true
        defer { isLoadingProfile = false }
        do {
            let response = try await authManager.fetchProfile()
            guard response.status, let data = response.data else { return }

            // Agent info
            if let info = data.agentInfo {
                title        = info.title?.trimmingCharacters(in: .whitespaces) ?? "Mr."
                firstName    = info.firstName ?? ""
                lastName     = info.lastName ?? ""
                designation  = info.designation ?? ""
                website      = info.website ?? ""
                officePhone  = info.officePhoneNo ?? ""
                address      = info.address ?? ""
                city         = info.city ?? ""
                state        = info.state ?? ""
                country      = info.country ?? "India"
                pinCode      = info.pinCode ?? ""
                panNo        = info.panNo ?? ""
                namePanCard  = info.namePanCard ?? ""
                aadharNo     = info.aadharNo ?? ""
                agencyName   = info.agencyName ?? ""
                contactNo    = info.mobileNo ?? ""
                agentLogoURL = FTDImageURL.agentLogo(info.agentLogo)
            }

            // Country list for dropdowns — India first, rest alphabetically
            let sorted = data.countryList.map { $0.name }.sorted()
            countryOptions = sorted.filter { $0.caseInsensitiveCompare("India") == .orderedSame }
                           + sorted.filter { $0.caseInsensitiveCompare("India") != .orderedSame }

            // Traveller list
            travellerList = data.travellersList.map { item in
                TravellerListItem(
                    id:           item.travelId,
                    title:        item.title ?? "",
                    firstName:    item.firstName ?? "",
                    lastName:     item.lastName ?? "",
                    paxType:      item.paxType ?? "Adult",
                    dob:          item.dob ?? "",
                    nationality:  item.nationality ?? "",
                    passportNo:   item.passportNo ?? "",
                    issueCountry: item.issueCountry ?? "",
                    expiryDate:   item.expiryDate ?? "",
                    age:          item.age ?? "",
                    gender:       item.sex ?? ""
                )
            }

            // GST list
            gstList = data.gstList.map { item in
                GSTListItem(
                    id:       item.gstId,
                    gstin:    item.gstNumber ?? "",
                    company:  item.gstCompany ?? "",
                    mobileNo: item.gstMobileNo ?? "",
                    email:    item.gstEmail ?? "",
                    address:  item.gstAddress ?? ""
                )
            }
        } catch {}
    }

    // MARK: - Update Profile

    func updateProfile() async {
        isUpdatingProfile = true
        profileMessage = nil
        defer { isUpdatingProfile = false }
        let req = UpdateAgentProfileRequest(
            title:         title.nilIfEmpty,
            firstName:     firstName.nilIfEmpty,
            lastName:      lastName.nilIfEmpty,
            designation:   designation.nilIfEmpty,
            website:       website.nilIfEmpty,
            officePhoneNo: officePhone.nilIfEmpty,
            address:       address.nilIfEmpty,
            city:          city.nilIfEmpty,
            state:         state.nilIfEmpty,
            country:       country.nilIfEmpty,
            pinCode:       pinCode.nilIfEmpty,
            logoData:      selectedLogoData
        )
        do {
            try await authManager.updateProfile(req)
            profileMessage = "Profile updated successfully."
            profileMessageIsError = false
            selectedLogoData = nil
            await authManager.refreshBalance()
        } catch let e as NetworkError {
            profileMessage = e.errorDescription
            profileMessageIsError = true
        } catch {
            profileMessage = error.localizedDescription
            profileMessageIsError = true
        }
    }

    // MARK: - Change Password

    func changePassword() async {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, newPassword == confirmPassword else {
            passwordMessage = "Please ensure all fields are filled and passwords match."
            passwordMessageIsError = true
            return
        }
        isChangingPassword = true
        passwordMessage = nil
        defer { isChangingPassword = false }
        let req = ChangeAgentPasswordRequest(
            currentPassword: currentPassword,
            password:        newPassword,
            passconf:        confirmPassword
        )
        do {
            try await authManager.changePassword(req)
            passwordMessage = "Password changed successfully."
            passwordMessageIsError = false
            currentPassword = ""
            newPassword     = ""
            confirmPassword = ""
        } catch let e as NetworkError {
            passwordMessage = e.errorDescription
            passwordMessageIsError = true
        } catch {
            passwordMessage = error.localizedDescription
            passwordMessageIsError = true
        }
    }

    // MARK: - Traveller CRUD

    func submitTraveller() async {
        guard !travellerTitle.isEmpty else {
            travellerMessage = "Title is required."
            travellerMessageIsError = true
            return
        }
        guard !travellerFirstName.isEmpty else {
            travellerMessage = "First Name is required."
            travellerMessageIsError = true
            return
        }
        isAddingTraveller = true
        travellerMessage = nil
        defer { isAddingTraveller = false }

        if let editId = editingTravellerId {
            let req = AgentUpdateTravellerRequest(
                travelId:     editId,
                paxType:      travellerPaxType,
                title:        travellerTitle,
                firstName:    travellerFirstName,
                lastName:     travellerLastName,
                dob:          formattedTravellerDOB,
                nationality:  travellerNationality.isEmpty ? "Indian" : travellerNationality,
                number:       travellerPassport,
                issueCountry: travellerIssueCountry.isEmpty ? "India" : travellerIssueCountry,
                expiryDate:   formattedTravellerExpiry,
                age:          travellerAge.isEmpty ? "0" : travellerAge,
                gender:       travellerGender
            )
            do {
                try await authManager.updateTraveller(req)
                if let idx = travellerList.firstIndex(where: { $0.id == editId }) {
                    travellerList[idx] = makeTravellerItem(id: editId)
                }
                travellerMessage = "Traveller updated successfully."
                travellerMessageIsError = false
                resetTravellerForm()
            } catch let e as NetworkError {
                travellerMessage = e.errorDescription
                travellerMessageIsError = true
            } catch {
                travellerMessage = error.localizedDescription
                travellerMessageIsError = true
            }
        } else {
            let req = AgentAddTravellerRequest(
                paxType:      travellerPaxType,
                title:        travellerTitle,
                firstName:    travellerFirstName,
                lastName:     travellerLastName,
                dob:          formattedTravellerDOB,
                nationality:  travellerNationality.isEmpty ? "Indian" : travellerNationality,
                number:       travellerPassport,
                issueCountry: travellerIssueCountry.isEmpty ? "India" : travellerIssueCountry,
                expiryDate:   formattedTravellerExpiry,
                age:          travellerAge.isEmpty ? "0" : travellerAge,
                gender:       travellerGender
            )
            do {
                try await authManager.addTraveller(req)
                travellerList.insert(makeTravellerItem(id: UUID().uuidString), at: 0)
                travellerMessage = "Traveller added successfully."
                travellerMessageIsError = false
                resetTravellerForm()
            } catch let e as NetworkError {
                travellerMessage = e.errorDescription
                travellerMessageIsError = true
            } catch {
                travellerMessage = error.localizedDescription
                travellerMessageIsError = true
            }
        }
    }

    func editTraveller(_ item: TravellerListItem) {
        editingTravellerId    = item.id
        travellerPaxType      = item.paxType
        travellerTitle        = item.title
        travellerFirstName    = item.firstName
        travellerLastName     = item.lastName
        travellerDOBDate = Self.dobFormatter.date(from: item.dob) ?? Date()
        travellerNationality  = item.nationality
        travellerPassport     = item.passportNo
        travellerIssueCountry = item.issueCountry
        travellerExpiryDateObj = Self.dobFormatter.date(from: item.expiryDate) ?? (Calendar.current.date(byAdding: .year, value: 5, to: Date()) ?? Date())
        travellerAge          = item.age
        travellerGender       = item.gender
    }

    func cancelTravellerEdit() {
        resetTravellerForm()
    }

    func deleteTraveller(_ item: TravellerListItem) async {
        isDeletingTravellerId = item.id
        defer { isDeletingTravellerId = nil }
        let req = AgentDeleteTravellerRequest(travelId: item.id)
        do {
            try await authManager.deleteTraveller(req)
            travellerList.removeAll { $0.id == item.id }
        } catch {}
    }

    var filteredTravellerList: [TravellerListItem] {
        let q = travellerSearchQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return travellerList }
        return travellerList.filter {
            $0.firstName.lowercased().contains(q) ||
            $0.lastName.lowercased().contains(q)  ||
            $0.passportNo.lowercased().contains(q)
        }
    }

    func toggleTravellerMultiSelect() {
        isTravellerMultiSelectMode.toggle()
        if !isTravellerMultiSelectMode { selectedTravellerIds.removeAll() }
    }

    func toggleTravellerSelection(id: String) {
        if selectedTravellerIds.contains(id) { selectedTravellerIds.remove(id) }
        else { selectedTravellerIds.insert(id) }
    }

    func deleteSelectedTravellers() async {
        guard !selectedTravellerIds.isEmpty else { return }
        isDeletingMultipleTravellers = true
        defer { isDeletingMultipleTravellers = false }
        let ids = Array(selectedTravellerIds)
        for id in ids {
            let req = AgentDeleteTravellerRequest(travelId: id)
            try? await authManager.deleteTraveller(req)
            travellerList.removeAll { $0.id == id }
            selectedTravellerIds.remove(id)
        }
        isTravellerMultiSelectMode = false
    }

    private func makeTravellerItem(id: String) -> TravellerListItem {
        TravellerListItem(
            id:           id,
            title:        travellerTitle,
            firstName:    travellerFirstName,
            lastName:     travellerLastName,
            paxType:      travellerPaxType,
            dob:          formattedTravellerDOB,
            nationality:  travellerNationality,
            passportNo:   travellerPassport,
            issueCountry: travellerIssueCountry,
            expiryDate:   formattedTravellerExpiry,
            age:          travellerAge,
            gender:       travellerGender
        )
    }

    // MARK: - GST

    func submitGST() async {
        guard !gstNumber.isEmpty, !gstCompany.isEmpty, !gstAddress.isEmpty else {
            gstFormMessage = "All fields are required."
            gstFormMessageIsError = true
            return
        }
        if let phoneError = Validator.phone(gstMobile) {
            gstFormMessage = phoneError
            gstFormMessageIsError = true
            return
        }
        if let emailError = Validator.email(gstEmail) {
            gstFormMessage = emailError
            gstFormMessageIsError = true
            return
        }
        isSubmittingGST = true
        gstFormMessage = nil
        defer { isSubmittingGST = false }

        if let editId = editingGSTId {
            let req = AgentUpdateGSTRequest(
                gstId: editId, gstNumber: gstNumber, gstCompany: gstCompany,
                gstMobileNo: gstMobile, gstEmail: gstEmail, gstAddress: gstAddress
            )
            do {
                try await authManager.updateGST(req)
                if let idx = gstList.firstIndex(where: { $0.id == editId }) {
                    gstList[idx] = GSTListItem(
                        id: editId, gstin: gstNumber, company: gstCompany,
                        mobileNo: gstMobile, email: gstEmail, address: gstAddress
                    )
                }
                gstFormMessage = "GST updated successfully."
                gstFormMessageIsError = false
                resetGSTForm()
            } catch let e as NetworkError {
                gstFormMessage = e.errorDescription
                gstFormMessageIsError = true
            } catch {
                gstFormMessage = error.localizedDescription
                gstFormMessageIsError = true
            }
        } else {
            let req = AgentAddGSTRequest(
                gstNumber: gstNumber, gstCompany: gstCompany,
                gstMobileNo: gstMobile, gstEmail: gstEmail, gstAddress: gstAddress
            )
            do {
                try await authManager.addGST(req)
                let item = GSTListItem(
                    id: UUID().uuidString, gstin: gstNumber, company: gstCompany,
                    mobileNo: gstMobile, email: gstEmail, address: gstAddress
                )
                gstList.insert(item, at: 0)
                gstFormMessage = "GST added successfully."
                gstFormMessageIsError = false
                resetGSTForm()
            } catch let e as NetworkError {
                gstFormMessage = e.errorDescription
                gstFormMessageIsError = true
            } catch {
                gstFormMessage = error.localizedDescription
                gstFormMessageIsError = true
            }
        }
    }

    func editGST(_ item: GSTListItem) {
        editingGSTId = item.id
        gstNumber    = item.gstin
        gstCompany   = item.company
        gstMobile    = item.mobileNo
        gstEmail     = item.email
        gstAddress   = item.address
    }

    func cancelGSTEdit() {
        resetGSTForm()
    }

    func deleteGST(_ item: GSTListItem) async {
        isDeletingGSTId = item.id
        defer { isDeletingGSTId = nil }
        let req = AgentDeleteGSTRequest(gstId: item.id)
        do {
            try await authManager.deleteGST(req)
            gstList.removeAll { $0.id == item.id }
        } catch {}
    }

    func toggleGSTMultiSelect() {
        isGSTMultiSelectMode.toggle()
        if !isGSTMultiSelectMode { selectedGSTIds.removeAll() }
    }

    func toggleGSTSelection(id: String) {
        if selectedGSTIds.contains(id) { selectedGSTIds.remove(id) }
        else { selectedGSTIds.insert(id) }
    }

    func deleteSelectedGSTs() async {
        guard !selectedGSTIds.isEmpty else { return }
        isDeletingMultipleGSTs = true
        defer { isDeletingMultipleGSTs = false }
        let ids = Array(selectedGSTIds)
        for id in ids {
            let req = AgentDeleteGSTRequest(gstId: id)
            try? await authManager.deleteGST(req)
            gstList.removeAll { $0.id == id }
            selectedGSTIds.remove(id)
        }
        isGSTMultiSelectMode = false
    }

    var filteredGSTList: [GSTListItem] {
        let q = gstSearchQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return gstList }
        return gstList.filter {
            $0.gstin.lowercased().contains(q) || $0.company.lowercased().contains(q)
        }
    }

    // MARK: - Private

    private func resetTravellerForm() {
        editingTravellerId    = nil
        travellerPaxType      = "Adult"
        travellerTitle        = ""
        travellerFirstName    = ""
        travellerLastName     = ""
        travellerDOBDate      = Date()
        travellerNationality  = ""
        travellerPassport     = ""
        travellerIssueCountry  = ""
        travellerExpiryDateObj = Calendar.current.date(byAdding: .year, value: 5, to: Date()) ?? Date()
        travellerAge          = ""
        travellerGender       = "Male"
        travellerMessage      = nil
    }

    private func resetGSTForm() {
        editingGSTId = nil
        gstNumber    = ""
        gstCompany   = ""
        gstMobile    = ""
        gstEmail     = ""
        gstAddress   = ""
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
