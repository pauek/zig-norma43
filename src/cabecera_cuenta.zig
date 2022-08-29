const std = @import("std");
const util = @import("./util.zig");

pub const CabeceraCuenta = struct {
    entidad: [4]u8,
    oficina: [4]u8,
    numero: [10]u8,
    fecha_inicial: util.Fecha,
    fecha_final: util.Fecha,
    debe_haber: u8,
    saldo: f64,
    divisa: []const u8,
    modalidad: u8,
    nombre_abrev: [26]u8,

    pub fn print(self: *CabeceraCuenta) void {
        util.print("Entidad: {s}\nOficina: {s}\n", .{ self.entidad, self.oficina });
        util.print("Cuenta: {s}\nFecha Inicial: {any}\nFecha Final: {any}\n", .{ self.numero, self.fecha_inicial, self.fecha_final });
        util.print("Debe/Haber: {d}\n", .{self.debe_haber});
        util.print("Saldo: {d}\n", .{self.saldo});
        util.print("Divisa: {s}\n", .{self.divisa});
        util.print("Modalidad: {d}\n", .{self.modalidad});
        util.print("Nombre: {s}\n", .{self.nombre_abrev});
    }
};

pub fn parseCabeceraCuenta(line: *const [82]u8) CabeceraCuenta {
    var cc: CabeceraCuenta = .{
        .entidad = [4]u8{ line[2], line[3], line[4], line[5] },
        .oficina = [4]u8{ line[6], line[7], line[8], line[9] },
        .numero = [10]u8{ line[10], line[11], line[12], line[13], line[14], line[15], line[16], line[17], line[18], line[19] }, // line[10..20],
        .fecha_inicial = util.parseFecha(line[20..26]),
        .fecha_final = util.parseFecha(line[26..32]),
        .debe_haber = line[32] - 48,
        .saldo = util.parseSaldo(line[33..47]),
        .divisa = util.parseDivisa(line[47..50]),
        .modalidad = line[50] - 48, // Quito ASCII '0',
        .nombre_abrev = std.mem.zeroes([26]u8),
    };
    std.mem.copy(u8, &cc.nombre_abrev, line[51..77]);
    return cc;
}