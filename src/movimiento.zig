const std = @import("std");
const util = @import("./util.zig");
const pr = util.print;

pub const Movimiento = struct {
    oficina_origen: [4]u8,
    fecha_operacion: util.Fecha,
    fecha_valor: util.Fecha,
    concepto_comun: [2]u8,
    concepto_propio: [3]u8,
    importe: f64,
    dni: [10]u8,
    ref1: [12]u8,
    ref2: [16]u8,

    pub fn print(self: *const Movimiento) void {
        pr("---- Movimiento ----------------------------------------\n", .{});
        pr("Oficina Origen: {s}\n", .{self.oficina_origen});
        var fecha1: [10:0]u8 = std.mem.zeroes([10:0]u8);
        var fecha2: [10:0]u8 = std.mem.zeroes([10:0]u8);
        self.fecha_operacion.printTo(&fecha1);
        self.fecha_valor.printTo(&fecha2);
        pr("Fecha Operación -> Valor: {s} -> {s}\n", .{ fecha1, fecha2 });
        pr("Concepto Común: {s}\n", .{self.concepto_comun});
        pr("Concepto Propio: {s}\n", .{self.concepto_propio});
        pr("Importe: {d: >15.2}\n", .{self.importe});
        pr("DNI: {s}\n", .{self.dni});
        pr("Ref: {s}{s}\n", .{ self.ref1, self.ref2 });
        pr("\n", .{});
    }

    pub fn printOneLine(self: *const Movimiento) void {
        var fecha: [10:0]u8 = std.mem.zeroes([10:0]u8);
        self.fecha_valor.printTo(&fecha);
        pr("{s}.{s}.{s} {s} {d: >9.2}  {s}{s}\n", .{
            self.oficina_origen,
            self.concepto_comun,
            self.concepto_propio,
            fecha,
            self.importe,
            self.ref1,
            self.ref2,
        });
    }

    pub fn parseMovimiento(self: *Movimiento, line: *const [82]u8) void {
        self.oficina_origen = [4]u8{ line[6], line[7], line[8], line[9] };
        self.fecha_operacion = util.parseFecha(line[10..16]);
        self.fecha_valor = util.parseFecha(line[16..22]);
        self.concepto_comun = [2]u8{ line[22], line[23] };
        self.concepto_propio = [3]u8{ line[24], line[25], line[26] };
        self.importe = util.signoFromDebeHaberU8(line[27]) * util.parseImporte(line[28..42]);
        self.dni = std.mem.zeroes([10]u8);
        self.ref1 = std.mem.zeroes([12]u8);
        self.ref2 = std.mem.zeroes([16]u8);
        std.mem.copy(u8, &self.dni, line[42..52]);
        std.mem.copy(u8, &self.ref1, line[52..64]);
        std.mem.copy(u8, &self.ref2, line[64..80]);
    }
};
