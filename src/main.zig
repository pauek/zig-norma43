const std = @import("std");
const util = @import("./util.zig");
const Movimiento = @import("./movimiento.zig").Movimiento;
const Cuenta = @import("./cuenta.zig").Cuenta;

pub const DatosBancarios = struct {
    cuentas: std.ArrayList(Cuenta),
    cuentaActual: ?*Cuenta,

    pub fn parseRegister(self: *DatosBancarios, line: *const [82]u8, allocator: std.mem.Allocator) !void {
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


pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("iber-caja-2022.aeb43", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    
    var datos: DatosBancarios = .{ 
        .cuentas = std.ArrayList(Cuenta).init(allocator),
        .cuentaActual = null,
    }; 
    
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [82]u8 = undefined;

    while (true) {
        var nread = try in_stream.read(&buf);
        if (nread == 0) {
            break;
        }
        if (nread == 82) {
            try datos.parseRegister(&buf, allocator);
        } else {
            unreachable;
        }
    }

    for (datos.cuentas.items) |cuenta| {
        cuenta.print();
        util.print("\n", .{});
    }
}
