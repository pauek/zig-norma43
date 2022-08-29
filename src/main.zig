const std = @import("std");

pub fn parseRegister(buf: [82]u8) !void {
    try std.fmt.format(std.io.getStdOut().writer(), "Line: {x}\n", .{ std.fmt.fmtSliceHexLower(&buf) });
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
            try parseRegister(buf);
        }
        nread = try in_stream.read(&buf);
    }
}
