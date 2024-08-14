import Foundation

private enum Constats {
    static let key = "KEY"
}

final class TableDataViewModel {
    
    var data: Dynamic<[String]> = Dynamic([])
    
    func upload() {
        if let content = UserDefaults.standard.array(forKey: Constats.key) as? [String] {
            data.value = content
            
        } else {
            data.value = ["Об приложении"]
        }
    }
        
    func saveData(with newData: [String]) {
        UserDefaults.standard.set(newData, forKey: Constats.key)
        data.value = newData
    }
    
    
    
}
