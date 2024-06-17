const std = @import("std");
const objc = @import("../objc.zig");

const AnyInstance = objc.AnyInstance;

const foundation = objc.foundation;
const NSString = foundation.NSString;
const NSError = foundation.NSError;
const NSArray = foundation.NSArray;

pub const NSRect = extern struct { x: f64, y: f64, w: f64, h: f64 };
pub const NSSize = extern struct { w: f64, h: f64 };

pub const NSWindowStyleMask = packed struct (foundation.NSUInteger) {
    /// Contrary to the name this enables/disables all window decorations.
    titled: bool = true,
    closable: bool = true,
    minimizable: bool = true,
    resizable: bool = true,
    _unknown: u4 = 0,
    /// Deprecated
    textured_background: bool = false,
    _unknown2: u3 = 0,
    /// This does nothing, all toolbars are unified now.
    unified_title_and_toolbar: bool = true,
    _unknown3: u1 = 0,
    full_screen: bool = false,
    full_size_content_view: bool = false,
    
    _pad: u48 = 0,
    
    comptime {
        if (@bitOffsetOf(@This(), "titled") != 0) @compileError("invalid layout");
        if (@bitOffsetOf(@This(), "closable") != 1) @compileError("invalid layout");
        if (@bitOffsetOf(@This(), "minimizable") != 2) @compileError("invalid layout");
        if (@bitOffsetOf(@This(), "resizable") != 3) @compileError("invalid layout");
        if (@bitOffsetOf(@This(), "textured_background") != 8) @compileError("invalid layout");
        if (@bitOffsetOf(@This(), "unified_title_and_toolbar") != 12) @compileError("invalid layout");
        if (@bitOffsetOf(@This(), "full_screen") != 14) @compileError("invalid layout");
        if (@bitOffsetOf(@This(), "full_size_content_view") != 15) @compileError("invalid layout");
    }
};

pub const NSBackingStoreType = enum (foundation.NSUInteger) {
    /// Deprecated
    retained,
    /// Deprecated
    nonretained,
    buffered
};

pub const NSApplicationActivationPolicy = enum (foundation.NSUInteger) {
    /// The application is an ordinary app that appears in the Dock and may have a user interface.
    regular,
    /// The application doesn’t appear in the Dock and doesn’t have a menu bar,
    /// but it may be activated programmatically or by clicking on one of its windows.
    accessory,
    /// The application doesn’t appear in the Dock and may not create windows or be activated.
    prohibited
};

// MARK: - NSResponder -------------------------------------------------------------------------------------------------

pub const NSResponder = packed struct { pub usingnamespace NSResponderDerive(Self); const Self = @This();
    any: AnyInstance
};

pub fn NSResponderDerive(comptime Self: type) type {
    return packed struct { pub usingnamespace foundation.NSObjectDerive(Self);
        pub fn super() type { return NSResponder; }
        
        pub fn invalidateRestorableState(self: Self) void {
            self.any.msg("invalidateRestorableState", .{}, void);
        }
    };
}

// MARK: - NSApplication -----------------------------------------------------------------------------------------------

pub const NSApplication = packed struct { pub usingnamespace NSResponderDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn sharedApplication() Self {
        return Self.class().msg("sharedApplication", .{}, Self);
    }
    
    pub fn run(self: Self) noreturn {
        self.any.msg("run", .{}, noreturn);
    }
    
    pub fn setActivationPolicy(self: Self, policy: NSApplicationActivationPolicy) bool {
        return self.any.msg("setActivationPolicy:", .{ policy }, bool);
    }
    
    pub fn activate(self: Self) void {
        self.any.msg("activate", .{}, void);
    }
    
    pub fn activateIgnoringOtherApps(self: Self, ignore: bool) void {
        self.any.msg("activateIgnoringOtherApps:", .{ ignore }, void);
    }
    
    /// TODO: Correct the signature to use NSObject
    pub fn setDelegate(self: Self, delegate: AnyInstance) void {
        self.any.msg("setDelegate:", .{ delegate }, void);
    }
    
    pub fn mainMenu(self: Self) NSMenu {
        return self.any.msg("mainMenu", .{}, NSMenu);
    }
    
    pub fn setWindowsMenu(self: Self, menu: NSMenu) void {
        self.any.msg("setWindowsMenu:", .{ menu }, void);
    }
    
    pub fn setHelpMenu(self: Self, menu: NSMenu) void {
        self.any.msg("setHelpMenu:", .{ menu }, void);
    }
};

// MARK: - NSWindow ----------------------------------------------------------------------------------------------------

pub const NSWindow = packed struct { pub usingnamespace NSResponderDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn initWithContentRect_styleMask_backing_defer(
        self: Self, rect: NSRect, style: NSWindowStyleMask, backing: NSBackingStoreType, deferred: bool
    ) Self {
        return self.any.msg("initWithContentRect:styleMask:backing:defer:", .{ rect, style, backing, deferred }, Self);
    }
    
    pub fn title(self: Self) NSString {
        return self.any.msg("title", .{}, NSString);
    }
    
    pub fn setTitle(self: Self, string: NSString) void {
        self.any.msg("setTitle:", .{ string }, void);
    }
    
    pub fn minSize(self: Self) NSSize {
        return self.any.msg("minSize", .{}, NSSize);
    }
    
    pub fn setMinSize(self: Self, size: NSSize) void {
        self.any.msg("setMinSize:", .{ size }, void);
    }
    
    pub fn maxSize(self: Self) NSSize {
        return self.any.msg("maxSize", .{}, NSSize);
    }
    
    pub fn setMaxSize(self: Self, size: NSSize) void {
        self.any.msg("setMaxSize:", .{ size }, void);
    }
    
    pub fn makeKeyAndOrderFront(self: Self, sender: AnyInstance) void {
        self.any.msg("makeKeyAndOrderFront:", .{ sender }, void);
    }
    
    /// TODO: Correct the signature to use NSObject
    pub fn setDelegate(self: Self, delegate: AnyInstance) void {
        self.any.msg("setDelegate:", .{ delegate }, void);
    }
    
    pub fn center(self: Self) void {
        self.any.msg("center", .{}, void);
    }
    
    pub fn canHide(self: Self) bool {
        return self.any.msg("canHide", .{}, bool);
    }
    
    pub fn setCanHide(self: Self, value: bool) void {
        self.any.msg("setCanHide:", .{ value }, void);
    }
    
    pub fn movableByWindowBackground(self: Self) bool {
        // NOTE: Custom getter.
        return self.any.msg("isMovableByWindowBackground", .{}, bool);
    }
    
    pub fn setMovableByWindowBackground(self: Self, value: bool) void {
        self.any.msg("setMovableByWindowBackground:", .{ value }, void);
    }
    
    pub fn titlebarAppearsTransparent(self: Self) bool {
        return self.any.msg("titlebarAppearsTransparent", .{}, bool);
    }
    
    pub fn setTitlebarAppearsTransparent(self: Self, value: bool) void {
        self.any.msg("setTitlebarAppearsTransparent:", .{ value }, void);
    }
    
    pub fn contentView(self: Self) AnyInstance {
        return self.any.msg("contentView", .{}, AnyInstance);
    }
    
    pub fn setContentView(self: Self, value: AnyInstance) void {
        self.any.msg("setContentView:", .{ value }, void);
    }
    
    pub fn restorable(self: Self) bool {
        // NOTE: Custom getter.
        return self.any.msg("isRestorable", .{}, bool);
    }
    
    pub fn setRestorable(self: Self, value: bool) void {
        self.any.msg("setRestorable:", .{ value }, void);
    }
    
    pub fn identifier(self: Self) NSString {
        // NOTE: Custom getter.
        return self.any.msg("identifier", .{}, NSString);
    }
    
    pub fn setIdentifier(self: Self, string: NSString) void {
        self.any.msg("setIdentifier:", .{ string }, void);
    }
    
    pub fn setFrameUsingName(self: Self, name: NSString) bool {
        return self.any.msg("setFrameUsingName:", .{ name }, bool);
    }
    
    pub fn setFrameAutosaveName(self: Self, name: NSString) void {
        self.any.msg("setFrameAutosaveName:", .{ name }, void);
    }
    
    pub fn saveFrameUsingName(self: Self, name: NSString) void {
        self.any.msg("saveFrameUsingName:", .{ name }, void);
    }
};

// MARK: - NSMenu ------------------------------------------------------------------------------------------------------

pub const NSMenu = packed struct { pub usingnamespace foundation.NSObjectDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn addItem(self: Self, item: NSMenuItem) void {
        self.any.msg("addItem:", .{ item }, void);
    }
};

// MARK: - NSMenuItem --------------------------------------------------------------------------------------------------

pub const NSMenuItem = packed struct { pub usingnamespace foundation.NSObjectDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn setTitle(self: Self, string: NSString) void {
        self.any.msg("setTitle:", .{ string }, void);
    }
    
    pub fn setSubmenu(self: Self, submenu: NSMenu) void {
        self.any.msg("setSubmenu:", .{ submenu }, void);
    }
};

// MARK: - NSView ------------------------------------------------------------------------------------------------------

pub const NSView = packed struct { pub usingnamespace NSViewDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub const AutoresizingMask = packed struct (foundation.NSUInteger) {
        /// The view cannot be resized.
        not_sizable: bool = false,
        /// The left margin between the view and its superview is flexible.
        min_x_margin: bool = false,
        /// The view’s width is flexible.
        width_sizable: bool = false,
        /// The right margin between the view and its superview is flexible.
        max_x_margin: bool = false,
        /// The bottom margin between the view and its superview is flexible.
        min_y_margin: bool = false,
        /// The view’s height is flexible.
        height_sizable: bool = false,
        /// The top margin between the view and its superview is flexible.
        max_y_margin: bool = false,
        
        _pad: u57 = 0
    };
};

pub fn NSViewDerive(comptime Self: type) type {
    return packed struct { pub usingnamespace NSResponderDerive(Self);
        pub fn super() type { return NSView; }
        
        pub fn autoresizingMask(self: Self) NSView.AutoresizingMask {
            return self.any.msg("autoresizingMask", .{}, NSView.AutoresizingMask);
        }
        
        pub fn setAutoresizingMask(self: Self, mask: NSView.AutoresizingMask) void {
            return self.any.msg("setAutoresizingMask:", .{ mask }, void);
        }
    };
}

// MARK: - NSControl ---------------------------------------------------------------------------------------------------

pub const NSControl = packed struct { pub usingnamespace NSControlDerive(Self); const Self = @This();
    any: AnyInstance
};

pub fn NSControlDerive(comptime Self: type) type {
    return packed struct { pub usingnamespace NSViewDerive(Self);
        pub fn super() type { return NSControl; }
    };
}

// MARK: - NSButton ----------------------------------------------------------------------------------------------------

pub const NSButton = packed struct { pub usingnamespace NSButtonDerive(Self); const Self = @This();
    any: AnyInstance
};

pub fn NSButtonDerive(comptime Self: type) type {
    return packed struct { pub usingnamespace NSControlDerive(Self);
        pub fn super() type { return NSButton; }
    };
}

// MARK: - NSVisualEffectView ------------------------------------------------------------------------------------------

pub const NSVisualEffectView = packed struct { pub usingnamespace NSViewDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn material(self: Self) Material {
        return self.any.msg("material", .{}, Material);
    }
    
    pub fn setMaterial(self: Self, value: Material) void {
        self.any.msg("setMaterial:", .{ value }, void);
    }
    
    pub fn blendingMode(self: Self) BlendingMode {
        return self.any.msg("blendingMode", .{}, BlendingMode);
    }
    
    pub fn setBlendingMode(self: Self, value: BlendingMode) void {
        self.any.msg("setBlendingMode:", .{ value }, void);
    }
    
    pub fn state(self: Self) State {
        return self.any.msg("state", .{}, State);
    }
    
    pub fn setState(self: Self, value: State) void {
        self.any.msg("setState:", .{ value }, void);
    }
    
    pub const Material = enum (foundation.NSInteger) {
        /// The default, yet deprecated for some reason.
        appearance_based = 0,
        titlebar = 3,
        selection = 4,
        menu = 5,
        popover = 6,
        sidebar = 7,
        header_view = 10,
        sheet = 11,
        window_background = 12,
        hud_window = 13,
        full_screen_ui = 15,
        tool_tip = 17,
        content_background = 18,
        under_window_background = 21,
        under_page_background = 22
    };
    
    pub const BlendingMode = enum (foundation.NSInteger) {
        behind_window, within_window
    };
    
    pub const State = enum (foundation.NSInteger) {
        follows_window_active_state,
        active,
        inactive
    };
};

// MARK: - NSAlert -----------------------------------------------------------------------------------------------------

pub const NSAlert = packed struct { pub usingnamespace foundation.NSObjectDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn alertWithError(err: NSError) Self {
        return Self.object().msg("alertWithError:", .{ err }, Self);
    }
    
    pub fn showsHelp(self: Self) bool {
        return self.any.msg("showsHelp", .{}, bool);
    }
    
    pub fn setShowsHelp(self: Self, value: bool) void {
        return self.any.msg("setShowsHelp:", .{ value }, void);
    }
    
    pub fn delegate(self: Self) AnyInstance {
        return self.any.msg("delegate", .{}, AnyInstance);
    }
    
    pub fn setDelegate(self: Self, value: AnyInstance) void {
        self.any.msg("setDelegate:", .{ value }, void);
    }
    
    /// NOTE: The return type is not completely defined?
    pub fn runModal(self: Self) foundation.NSInteger {
        return self.any.msg("runModal", .{}, foundation.NSInteger);
    }
    
    /// NOTE: The return type is not completely defined?
    pub fn beginSheetModalForWindow_completionHandler(
        self: Self, win: NSWindow, handler: objc.Block(.{ foundation.NSUInteger }, void)
    ) void {
        self.any.msg("beginSheetModalForWindow:completionHandler:", .{ win, handler }, void);
    }
    
    pub fn buttons(self: Self) NSArray(NSButton) {
        return self.any.msg("buttons", .{}, NSArray(NSButton));
    }
    
    pub fn addButtonWithTitle(self: Self, title: NSString) NSButton {
        return self.any.msg("addButtonWithTitle:", .{ title }, NSButton);
    }
    
    pub fn window(self: Self) NSWindow {
        return self.any.msg("window", .{}, NSWindow);
    }
    
    pub fn icon(self: Self) NSImage {
        return self.any.msg("icon", .{}, NSImage);
    }
    
    pub fn setIcon(self: Self, value: NSImage) void {
        return self.any.msg("setIcon:", .{ value }, void);
    }
    
    pub const Style = enum (foundation.NSUInteger) {
        /// An alert style to inform someone about a critical event.
        critical = 2,
        /// An alert style to warn someone about a current or impending event.
        warning = 0,
        /// An alert style to inform someone about a current or impending event.
        informational = 1
    };
};

// MARK: - NSImage -----------------------------------------------------------------------------------------------------

pub const NSImage = packed struct { pub usingnamespace foundation.NSObjectDerive(Self); const Self = @This();
    any: AnyInstance
};
