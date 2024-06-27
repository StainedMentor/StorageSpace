import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)


    let finderChannel = FlutterMethodChannel(
      name: "samples.flutter.dev/finder",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    finderChannel.setMethodCallHandler { (call, result) in

      if let args = call.arguments as? Dictionary<String, Any>,
        let path = args["path"] as? String {
        self.revealInFileSystem(path: path)
      }
    }




    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

    private func revealInFileSystem(path: String) {
NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
  }
}
