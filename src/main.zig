const std = @import("std");
const util = @import("./util.zig");
const sqlite = @import("sqlite");
const ExtractoBancario = @import("./extracto.zig").ExtractoBancario;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var args = try std.process.argsAlloc(allocator);
    for (args) |filename, index| {
        if (index > 0) {
            std.debug.print("{s}:\n", .{ filename });
            var extracto = ExtractoBancario.init(allocator);
            try extracto.readFrom(filename);
            try extracto.dump();
        }
    }
}
