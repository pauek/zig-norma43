
const std = @import("std");
const util = @import("./util.zig");
const pr = util.print;

pub const Complemento = struct {
  const Self = @This();

  dato: [2]u8,
  concepto: [76]u8,

  pub fn parse(self: *Self, line: *const [82]u8) void {
    std.mem.copy(u8, &self.dato, line[2..4]);
    std.mem.copy(u8, self.concepto[0..38], line[4..42]);
    std.mem.copy(u8, self.concepto[38..], line[42..80]);
  }

  pub fn print(self: *const Self) void {
    pr("    [{s}] {s}\n", .{ self.dato, self.concepto });
  }
};