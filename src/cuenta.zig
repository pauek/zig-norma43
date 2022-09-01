const std = @import("std");
const util = @import("./util.zig");
const Movimiento = @import("./movimiento.zig").Movimiento;
const pr = util.print;

fn digito(n: u8) u8 {
    return '0' + switch (n) {
        11 => 0,
        10 => 1,
        else => n,
    };
}

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

    pub fn digitosDeControl(self: *const Cuenta) [2]u8 {
        // https://www.geogebra.org/m/q7RhU98P
        const pesos = [10]usize{ 1, 2, 4, 8, 5, 10, 9, 7, 3, 6 };
        var suma1: usize = 0;
        for (self.entidad) |e, i| {
            suma1 += (e - '0') * pesos[2 + i];
        }
        for (self.oficina) |o, i| {
            suma1 += (o - '0') * pesos[6 + i];
        }
        var suma2: usize = 0;
        for (self.numero) |n, i| {
            suma2 += (n - '0') * pesos[i];
        }
        var mod1: u8 = @intCast(u8, suma1 % 11);
        var mod2: u8 = @intCast(u8, suma2 % 11);
        return .{ digito(11 - mod1), digito(11 - mod2) };
    }

    pub fn print(self: *const Cuenta) void {
        pr("----- Cuenta ----------------------------------------\n", .{});
        var dc = self.digitosDeControl();
        pr("Cuenta:    {s}-{s}-{s}-{s}\n", .{ self.entidad, self.oficina, dc, self.numero });
        pr("Saldo:     {d}{s}\n", .{ self.saldo, self.divisa });
        pr("Modalidad: {d}\n", .{self.modalidad});
        pr("Nombre:    {s}\n", .{self.nombre_abrev});

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

    pub fn printJson(self: *const Cuenta) void {
        pr("{\"cuenta\": \"{s}-{s}-__-{s}\"}", .{ self.entidad, self.oficina, self.numero });
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
