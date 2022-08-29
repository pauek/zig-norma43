const std = @import("std");
const util = @import("./util.zig");
const pr = util.print;

pub const Movimiento = struct {
    oficina_origen: [4]u8,
    fecha_operacion: util.Fecha,
    fecha_valor: util.Fecha,
    concepto_comun: [2]u8,
    concepto_propio: [3]u8,
    debe_haber: util.DebeHaber,
    importe: f64,
    dni: [10]u8,
    ref1: [12]u8,
    ref2: [16]u8,

    pub fn print(self: *Movimiento) void {
        pr("Oficina Origen: {s}\n", .{self.oficina_origen});
    }
};

pub fn parseMovimiento(line: *const [82]u8) Movimiento {
  var m: Movimiento = .{
    .oficina_origen = [4]u8{ line[6] ,line[7], line[8], line[9]},
    .fecha_operacion = util.parseFecha(line[10..16]),
    .fecha_valor = util.parseFecha(line[16..22]),
    .concepto_comun = [2]u8{ line[22], line[23] },
    .concepto_propio = [3]u8{ line[24], line[25], line[26] },
    .debe_haber = util.debeHaberFromU8(line[27]),
    .importe = util.parseImporte(line[28..42]),
    .dni = std.mem.zeroes([10]u8),
    .ref1 = std.mem.zeroes([12]u8),
    .ref2 = std.mem.zeroes([16]u8),
  };
  std.mem.copy(u8, &m.dni, line[42..52]);
  std.mem.copy(u8, &m.ref1, line[52..64]);
  std.mem.copy(u8, &m.ref2, line[64..80]);
  return m;
}
