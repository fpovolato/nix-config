// Sets default apps for file extensions through NSWorkspace, which also
// accepts the dynamic types macOS assigns to extensions no app declares.
// Usage: swift set-default-apps.swift <extension> <bundle ID> [...]
import AppKit
import UniformTypeIdentifiers

let args = Array(CommandLine.arguments.dropFirst())
guard args.count % 2 == 0 else {
  FileHandle.standardError.write("expected <extension> <bundle ID> pairs\n".data(using: .utf8)!)
  exit(2)
}

var failed = false
for i in stride(from: 0, to: args.count, by: 2) {
  let (ext, bundleId) = (args[i], args[i + 1])
  func fail(_ message: String) {
    FileHandle.standardError.write("failed to set \(bundleId) for .\(ext): \(message)\n".data(using: .utf8)!)
    failed = true
  }
  guard let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
    fail("app not found"); continue
  }
  guard let type = UTType(filenameExtension: ext) else {
    fail("no type for extension"); continue
  }
  let done = DispatchSemaphore(value: 0)
  var error: Error?
  NSWorkspace.shared.setDefaultApplication(at: app, toOpen: type) { error = $0; done.signal() }
  done.wait()
  if let error { fail(error.localizedDescription) }
}
exit(failed ? 1 : 0)
