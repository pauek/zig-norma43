const std = @import("std");
const util = @import("./util.zig");
const ExtractoBancario = @import("./extracto.zig").ExtractoBancario;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var extracto = ExtractoBancario.init(allocator);
    try extracto.readFrom("iber-caja-2022.aeb43");
    try extracto.dump();
}
