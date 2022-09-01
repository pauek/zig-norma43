const std = @import("std");
const util = @import("./util.zig");
const Movimiento = @import("./movimiento.zig").Movimiento;
const Cuenta = @import("./cuenta.zig").Cuenta;

pub const ExtractoBancario = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    cuentas: std.ArrayList(Cuenta),
    cuentaActual: ?*Cuenta,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .cuentas = std.ArrayList(Cuenta).init(allocator),
            .cuentaActual = null,
        };
    }

    pub fn readFrom(self: *Self, filename: []const u8) !void {
        var file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

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
            try self.parseRegister(&buf, self.allocator);
        }
    }

    pub fn parseRegister(self: *Self, line: *const [82]u8, allocator: std.mem.Allocator) !void {
        var code = util.code(line);
        if (code == 11) {
            var nueva: *Cuenta = try self.cuentas.addOne();
            nueva.parse(line, allocator);
            self.cuentaActual = nueva;
        } else if (code == 22) {
            if (self.cuentaActual) |actual| {
                var mov: *Movimiento = try actual.movimientos.addOne();
                mov.parseMovimiento(line);
                // mov.printOneLine();
            } else {
                util.print("No hay cuenta actual!\n", .{});
            }
        } else {
            // util.print("Line: {x}\n", .{std.fmt.fmtSliceHexLower(line)});
        }
    }

    pub fn dump(self: *const Self) !void {
        for (self.cuentas.items) |cuenta| {
            cuenta.print();
            util.print("\n", .{});
        }
    }
};
