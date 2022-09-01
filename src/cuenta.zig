const std = @import("std");
const util = @import("./util.zig");
const Movimiento = @import("./movimiento.zig").Movimiento;
const pr = util.print;

pub const Cuenta = struct {
    entidad: [4]u8,
    oficina: [4]u8,
    numero: [10]u8,
    fecha_inicial: util.Fecha,
    fecha_final: util.Fecha,
    saldo: f64,
    divisa: []const u8,
    modalidad: u8,
    nombre_abrev: [26]u8,
    movimientos: std.ArrayList(Movimiento),

    pub fn print(self: *const Cuenta) void {
        pr("----- Cuenta ----------------------------------------\n", .{});
        pr("Cuenta:    {s}-{s}-__-{s}\n", .{ self.entidad, self.oficina, self.numero });
        pr("Saldo:     {d}{s}\n", .{ self.saldo, self.divisa });
        pr("Modalidad: {d}\n", .{self.modalidad});
        pr("Nombre:    {s}\n\n", .{self.nombre_abrev});
        var fini: [10:0]u8 = std.mem.zeroes([10:0]u8);
        var ffin: [10:0]u8 = std.mem.zeroes([10:0]u8);
        self.fecha_inicial.printTo(&fini);
        self.fecha_final.printTo(&ffin);
        pr("Fecha Inicial: {s}\n", .{fini});
        pr("Fecha Final:   {s}\n", .{ffin});
        pr("\n", .{});
        for (self.movimientos.items) |mov| {
            mov.printOneLine();
        }
    }

    pub fn parse(self: *Cuenta, line: *const [82]u8, allocator: std.mem.Allocator) void {
        self.entidad = [4]u8{ line[2], line[3], line[4], line[5] };
        self.oficina = [4]u8{ line[6], line[7], line[8], line[9] };
        self.numero = [10]u8{ line[10], line[11], line[12], line[13], line[14], line[15], line[16], line[17], line[18], line[19] }; // line[10..20],
        self.fecha_inicial = util.parseFecha(line[20..26]);
        self.fecha_final = util.parseFecha(line[26..32]);
        self.saldo = util.signoFromDebeHaberU8(line[32]) * util.parseImporte(line[33..47]);
        self.divisa = util.parseDivisa(line[47..50]);
        self.modalidad = line[50] - 48; // Quito ASCII '0',
        self.nombre_abrev = std.mem.zeroes([26]u8);
        self.movimientos = std.ArrayList(Movimiento).init(allocator);
        std.mem.copy(u8, &self.nombre_abrev, line[51..77]);
    }
};
