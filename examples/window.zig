pub const std = @import("std");
pub const objc = @import("objc");

const AnyInstance = objc.AnyInstance;
const AutoReleasePool = objc.AutoReleasePool;

const foundation = objc.foundation;
const cocoa = objc.cocoa;

const NSString = foundation.NSString;
const NSStr = foundation.NSStr;
const NSApplication = cocoa.NSApplication;
const NSWindow = cocoa.NSWindow;
const NSAlert = cocoa.NSAlert;

pub fn main() noreturn {
    registerClasses();
    
    const autoreleasepool = AutoReleasePool.push();
    defer autoreleasepool.pop();
    
    const app = NSApplication.sharedApplication();
    _ = app.setActivationPolicy(.regular);
    app.setDelegate(SampleApplicationDelegate.alloc().autorelease().any);
    app.run();
}

const SampleApplicationDelegate = packed struct { usingnamespace objc.foundation.NSObjectDerive(Self); const Self = @This();
    any: AnyInstance,
    
    fn applicationShouldTerminateAfterLastWindowClosed(_: Self, _: objc.Selector, _: AnyInstance) callconv(.C) bool { return true; }
    
    fn applicationDidFinishLaunching(self: Self, _: objc.Selector, _: AnyInstance) callconv(.C) void {
        const window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer(
            .{ .x = 0, .y = 0, .w = 800, .h = 600 }, .{}, .buffered, false
        );
        window.setMinSize(.{ .w = 400, .h = 500 });
        window.setTitle(NSStr("Sample Application"));
        window.center();
        
        // const alert = NSAlert.alloc().init();
        // alert.runModal();
        
        // NSAlert *alert = [[NSAlert alloc] init];
        // [alert setMessageText:@"Message text."];
        // [alert setInformativeText:@"Informative text."];
        // [alert addButtonWithTitle:@"Cancel"];
        // [alert addButtonWithTitle:@"Ok"];
        // [alert runModal];
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true);
        window.makeKeyAndOrderFront(self.any);
    }
};

fn registerClasses() void {
    // Automatic registration is currently not implementable and does nothing
    // Blocked by https://github.com/ziglang/zig/issues/6709
    objc.autoRegisterClass(SampleApplicationDelegate);
    
    // Instead, custom classes need to be registered manually for now:
    const NSObject = objc.AnyClass.named("NSObject");
    const ImplSampleApplicationDelegate = objc.AnyClass.new("SampleApplicationDelegate", NSObject);
    defer ImplSampleApplicationDelegate.register();
    _ = ImplSampleApplicationDelegate.method("applicationDidFinishLaunching:", "@:@", SampleApplicationDelegate.applicationDidFinishLaunching);
    _ = ImplSampleApplicationDelegate.method("applicationShouldTerminateAfterLastWindowClosed:", "@:@", SampleApplicationDelegate.applicationShouldTerminateAfterLastWindowClosed);
}
