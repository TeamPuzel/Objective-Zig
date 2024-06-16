### Objective-Zig

Abusing comptime inheritance for fun and profit.

This is an experimental library providing a mostly idiomatic (as much as classes can be anyway)
way to define classes and inheritance hierarchies. The idea is not inherently tied to the Objective-C runtime
and could be implemented for other runtimes, like GObject.

It allows implementing native UI for Zig applications without having to use any other languages.


### Examples

You can run examples with:

```sh
zig build run                  # Default example (window)
zig build run -Dexample=window # Any example from the examples directory
```

Everything is abstracted to standard Zig syntax with the usual Smalltalk style message chaining:

```zig
const file_menu_item = NSMenuItem.alloc().init().autorelease();
file_menu_item.setTitle(NSStr("File"));
```

```zig
fn windowWillClose(_: AnyInstance, _: objc.Selector, notification: NSNotification) callconv(.C) void {
    notification
        .object()
        .as(NSWindow)
        .saveFrameUsingName(NSStr("MyApplicationWindow"));
}
```

An example Cocoa window:

```zig

pub fn main() void {
    registerClasses();
    
    const autoreleasepool = AutoReleasePool.push();
    defer autoreleasepool.pop();
    
    const app = NSApplication.sharedApplication();
    _ = app.activationPolicy(.regular);
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
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true);
        window.makeKeyAndOrderFront(self.any);
    }
};

```

Framework classes are very easily defined using opaque class/instance abstractions:

```zig
pub const NSWindow = packed struct { pub usingnamespace NSResponderDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn initWithContentRect_styleMask_backing_defer(
        self: Self, rect: NSRect, style: NSWindowStyleMask, backing: NSBackingStoreType, deferred: bool
    ) Self {
        return self.any.msg("initWithContentRect:styleMask:backing:defer:", .{ rect, style, backing, deferred }, Self);
    }
    
    pub fn setTitle(self: Self, string: NSString) void {
        self.any.msg("setTitle:", .{ string }, void);
    }
    
    pub fn setMinSize(self: Self, size: NSSize) void {
        self.any.msg("setMinSize:", .{ size }, void);
    }
    
    // And so on...
}
```

There is one currently unsolvable inconvenience due to a limitation of comptime reflection:

```zig
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
    _ = ImplSampleApplicationDelegate.method("applicationWillTerminate:", "@:@", SampleApplicationDelegate.applicationWillTerminate);
}
```
