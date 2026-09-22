import SwiftUI
import UIKit

extension View {
    /// Resigns the current first responder, dismissing the software keyboard.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
