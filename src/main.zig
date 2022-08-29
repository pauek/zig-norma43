const std = @import("std");
const util = @import("./util.zig");
const cc = @import("./cabecera_cuenta.zig");
const mv = @import("./movimiento.zig");

pub fn parseRegister(line: *const [82]u8) !void {
    var code = util.code(line);
    if (code == 11) {
        var c = cc.parseCabeceraCuenta(line);
        c.print();
    } else if (code == 22) {
        var m = mv.parseMovimiento(line);
        m.print();
    } else {
        util.print("Line: {x}\n", .{std.fmt.fmtSliceHexLower(line)});
    }
}

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("iber-caja-2022.aeb43", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [82]u8 = undefined;

    var nread = try in_stream.read(&buf);
    while (nread > 0) {
        if (nread == 82) { 
            try parseRegister(&buf);
        }
        nread = try in_stream.read(&buf);
    }
}
