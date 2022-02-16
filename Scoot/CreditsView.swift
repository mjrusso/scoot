import SwiftUI

struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text(loadCreditsText())
                    .font(.system(.body, design: .monospaced))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(minWidth: 680, minHeight: 520)
    }


    func loadCreditsText() -> String {
        guard let path = Bundle.main.path(forResource: "Credits", ofType: "md") else {
            return ""
        }
        return (try? String(contentsOfFile: path)) ?? ""
    }

}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
