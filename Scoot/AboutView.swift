import SwiftUI
import OSLog

struct AboutView: View {

    var body: some View {
        VStack(spacing: 4) {
            Group {
                Image(nsImage: NSImage(named: "AppIcon")!)
                Text(Bundle.main.displayName!)
                    .font(.system(size: 26, weight: .heavy))
                Text("MacOS Cursor Actuator")
                    .font(.system(size: 20, weight: .light)).italic()
                Text("Version \(Bundle.main.version)")
                    .font(.system(size: 16, weight: .light))
                Spacer()
            }
            Group {
                Spacer()
                Text("Scoot helps you efficiently move your mouse cursor, using keyboard shortcuts.\n\nFor updates, follow [@mjrusso](https://twitter.com/mjrusso) on Twitter.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            Group {
                Spacer()
                Link("github.com/mjrusso/scoot", destination: URL(string: "https://github.com/mjrusso/scoot")! )
                Link("mjrusso.com", destination: URL(string: "https://mjrusso.com")! )
                Spacer()
            }
            Group {
                Spacer()
                Button("Credits", action: showCreditsAction)
                    .buttonStyle(.borderless)
                Spacer()
                Text(Bundle.main.copyright!)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(minWidth: 360)
    }

    func showCreditsAction() {
        OSLog.main.log("Showing credits window.")

        let hostingController = NSHostingController(rootView: CreditsView())

        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.closable, .titled]
        window.titlebarAppearsTransparent = true
        window.title = "Scoot Credits"

        window.center()

        let controller = NSWindowController(window: window)
        controller.showWindow(self)
    }

}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
