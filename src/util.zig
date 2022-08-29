const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn print(comptime fmt: []const u8, args: anytype) void {
    std.fmt.format(stdout, fmt, args) catch unreachable;
}

pub fn code(line: *const [82]u8) usize {
    return std.fmt.parseInt(usize, line[0..2], 10) catch 0;
}

pub fn parseFecha(f: *const [6]u8) Fecha {
    var fecha = .{
        .dia = 10 * (f[0] - 48) + f[1] - 48,
        .mes = 10 * (f[2] - 48) + f[3] - 48,
        .anyo = 2000 + 10 * (@as(usize, f[4]) - 48) + @as(usize, f[5]) - 48,
    };
    return fecha;
}

pub fn parseImporte(s: []const u8) f64 {
    var n = std.fmt.parseInt(usize, s, 10) catch 0;
    return @intToFloat(f64, n) / 100.0;
}

pub fn parseDivisa(str: *const [3]u8) []const u8 {
    var c = std.fmt.parseInt(usize, str, 10) catch 0;
    if (c == 978) {
        return "€";
    } else {
        return str;
    }
}

pub const Fecha = struct {
    dia: u8,
    mes: u8,
    anyo: usize,
};

pub const DebeHaber = enum {
    deudor,
    acreedor,
};

pub fn debeHaberFromU8(x: u8) DebeHaber {
    if (x - 48 == 1) {
        return DebeHaber.deudor;
    } else if (x - 48 == 2) {
        return DebeHaber.acreedor;
    } else unreachable;
}
