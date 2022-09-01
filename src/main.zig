const std = @import("std");
const util = @import("./util.zig");
const ExtractoBancario = @import("./extracto.zig").ExtractoBancario;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("iber-caja-2022.aeb43", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var extracto = ExtractoBancario.init(allocator);

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [82]u8 = undefined;

    while (true) {
        var nread = try in_stream.read(&buf);
        if (nread == 0) {
            break;
        } else if (nread != 82) {
            unreachable;
        }
        try extracto.parseRegister(&buf, allocator);
    }

    for (extracto.cuentas.items) |cuenta| {
        cuenta.print();
        util.print("\n", .{});
    }
}
