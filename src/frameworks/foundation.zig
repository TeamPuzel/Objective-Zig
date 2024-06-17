const std = @import("std");
const objc = @import("../objc.zig");

const AnyClass = objc.AnyClass;
const AnyInstance = objc.AnyInstance;

pub const NSInteger = isize;
pub const NSUInteger = usize;

// pub const NSUTF8StringEncoding: NSUInteger = 4;

/// Logs an error message to the Apple System Log facility.
pub extern fn NSLog(format: NSString, ...) void;

pub const NSObject = packed struct { pub usingnamespace NSObjectDerive(Self); const Self = @This();
    any: AnyInstance
};

pub fn NSObjectDerive(comptime Self: type) type {
    comptime objc.assertClass(Self);
    return packed struct {
        pub fn super() type { return NSObject; }
        
        // Optimization:
        // - Cache this, no need to call into the runtime every time
        // Convenience:
        // - This should register the class if not registered automatically.
        pub fn class() AnyClass {
            const qualified = @typeName(Self);
            comptime var name_iter = std.mem.splitBackwardsScalar(u8, qualified, '.');
            const name = comptime name_iter.next() orelse @typeName(Self);
            comptime var cstr: [name.len:0]u8 = undefined;
            comptime std.mem.copyForwards(u8, &cstr, name);
            const cpy = cstr;
            return AnyClass.named(cpy[0..]);
        }
        
        // pub fn new() Self {
        //     return Self.alloc().init();
        // }
        
        pub fn alloc() Self {
            return class().msg("alloc", .{}, Self);
        }
        
        pub fn dealloc(self: Self) void {
            self.msg("dealloc", .{}, void);
        }
        
        pub fn init(self: Self) Self {
            return self.any.msg("init", .{}, Self);
        }
        
        pub fn copy(self: Self) Self {
            return self.any.msg("copy", .{}, Self);
        }
        
        pub fn mutableCopy(self: Self) Self {
            return self.any.msg("copy", .{}, Self);
        }
        
        pub fn autorelease(self: Self) Self {
            return self.any.msg("autorelease", .{}, Self);
        }
        
        pub fn retain(self: Self) Self {
            return self.any.msg("retain", .{}, Self);
        }
        
        pub fn release(self: Self) void {
            self.any.msg("release", .{}, void);
        }
        
        pub fn isSubclassOfClass(other_class: AnyClass) bool {
            return Self.class().msg("isSubclassOfClass:", .{ other_class }, bool);
        }
        
        pub fn as(self: Self, comptime Class: type) Class {
            comptime objc.assertClass(Class);
            if (!self.isSubclassOfClass(Class.class()))
                std.debug.panic("invalid cast of {s} to {s}", .{ @typeName(@TypeOf(self)), @typeName(Class) });
            return Class { .any = self.any };
        }
        
        // pub fn version() NSInteger {
        //     Self.class().msg("version", .{}, void);
        // }
        
        // pub fn setVersion(value: NSInteger) void {
        //     Self.class().msg("setVersion:", .{ value }, void);
        // }
    };
}

/// Convenience function to construct an NSString from a literal.
/// TODO(!): This should construct a static NSString, like the objc `@"str"` syntax.
pub fn NSStr(comptime str: [:0]const u8) NSString {
    return NSString.stringWithUTF8String(str);
}

pub const NSString = packed struct { pub usingnamespace NSObjectDerive(Self); const Self = @This();
    any: AnyInstance,
    
    /// Deprecated
    pub fn stringWithUTF8String(string: [*:0]const u8) @This() {
        return Self.class().msg("stringWithUTF8String:", .{ string }, @This());
    }
};

pub const NSNotification = packed struct { pub usingnamespace NSObjectDerive(Self); const Self = @This();
    any: AnyInstance,
    
    pub fn object(self: Self) AnyInstance {
        return self.any.msg("object", .{}, AnyInstance);
    }
};

pub const NSError = packed struct { pub usingnamespace NSObjectDerive(Self); const Self = @This();
    any: AnyInstance
};

pub fn NSArray(comptime T: type) type {
    return packed struct { pub usingnamespace NSArrayDerive(Self, T); const Self = @This();
        any: AnyInstance
    };
}

pub fn NSArrayDerive(comptime Self: type, comptime T: type) type {
    comptime objc.assertClass(T);
    return packed struct { pub usingnamespace NSObjectDerive(Self);
        
    };
}

pub fn NSMutableArray(comptime T: type) type {
    return packed struct { pub usingnamespace NSArrayDerive(Self, T); const Self = @This();
        any: AnyInstance
    };
}
