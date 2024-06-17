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
const NSMenu = cocoa.NSMenu;
const NSMenuItem = cocoa.NSMenuItem;
const NSVisualEffectView = cocoa.NSVisualEffectView;

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
        const app = NSApplication.sharedApplication();
        
        const main_menu = app.mainMenu();
        
        const window_menu_item = NSMenuItem.alloc().init().autorelease();
        window_menu_item.setTitle(NSStr("Window"));
        
        const window_menu = NSMenu.alloc().init().autorelease();
        window_menu_item.setSubmenu(window_menu);
        app.setWindowsMenu(window_menu);
        
        main_menu.addItem(window_menu_item);
        
        const help_menu_item = NSMenuItem.alloc().init().autorelease();
        help_menu_item.setTitle(NSStr("Help"));
        const help_menu = NSMenu.alloc().init().autorelease();
        help_menu_item.setSubmenu(help_menu);
        app.setHelpMenu(help_menu);
        
        main_menu.addItem(help_menu_item);
        
        const window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer(
            .{ .x = 0, .y = 0, .w = 400, .h = 400 },
            .{ .full_size_content_view = true },
            .buffered,
            false
        );
        window.setMinSize(.{ .w = 400, .h = 400 });
        window.setTitlebarAppearsTransparent(true);
        window.setRestorable(true);
        window.setIdentifier(NSStr("SampleWindow"));
        window.setDelegate(SampleWindowDelegate.alloc().any);
        window.setFrameAutosaveName(NSStr("SampleWindow"));
        if (!window.setFrameUsingName(NSStr("SampleWindow"))) window.center();
        
        const effect = NSVisualEffectView.alloc().init();
        effect.setBlendingMode(.behind_window);
        effect.setMaterial(.popover);
        window.setContentView(effect.any);
        
        app.activateIgnoringOtherApps(true);
        window.makeKeyAndOrderFront(self.any);
    }
};

const SampleWindowDelegate = packed struct { usingnamespace objc.foundation.NSObjectDerive(Self); const Self = @This();
    any: AnyInstance,
    
    fn windowWillClose(_: Self, _: objc.Selector, notification: foundation.NSNotification) callconv(.C) void {
        notification.object().as(NSWindow).saveFrameUsingName(NSStr("SampleWindow"));
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
    
    const ImplSampleWindowDelegate = objc.AnyClass.new("SampleWindowDelegate", NSObject);
    defer ImplSampleWindowDelegate.register();
    _ = ImplSampleWindowDelegate.method("windowWillClose:", "@:@", SampleWindowDelegate.windowWillClose);
}
