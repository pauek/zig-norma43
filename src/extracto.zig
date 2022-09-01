const std = @import("std");
const util = @import("./util.zig");
const Movimiento = @import("./movimiento.zig").Movimiento;
const Cuenta = @import("./cuenta.zig").Cuenta;

pub const ExtractoBancario = struct {
    const Self = @This();

    cuentas: std.ArrayList(Cuenta),
    cuentaActual: ?*Cuenta,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .cuentas = std.ArrayList(Cuenta).init(allocator),
            .cuentaActual = null,
        };
    }

    pub fn parseRegister(self: *ExtractoBancario, line: *const [82]u8, allocator: std.mem.Allocator) !void {
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
};
