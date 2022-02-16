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
                HStack(spacing: 20)  {
                    Button("Credits", action: showCreditsAction)
                        .buttonStyle(.borderless)
                    Button("License", action: showLicenseAction)
                        .buttonStyle(.borderless)
                }
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
        openWindow(rootView: CreditsView(), title: "\(Bundle.main.displayName!) Credits")
    }

    func showLicenseAction() {
        OSLog.main.log("Showing license window.")
        openWindow(rootView: LicenseView(), title: "\(Bundle.main.displayName!) License")
    }

    func openWindow<Content>(rootView: Content, title: String) where Content : View {

        let hostingController = NSHostingController(rootView: rootView)

        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.closable, .titled]
        window.titlebarAppearsTransparent = true
        window.title = title

        let controller = NSWindowController(window: window)
        controller.showWindow(self)
    }

}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
