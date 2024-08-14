import Foundation

struct PersonModel {
    let name: String
    let surname: String
    
    var fullName: String {
        "\(name) \(surname)"
    }
    
    static func getInformationAboutPerson() -> PersonModel {
        PersonModel(name: "Алина",
               surname: "Саковская")
    }
}
