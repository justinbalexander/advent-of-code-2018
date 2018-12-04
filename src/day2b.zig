const std = @import("std");
const file = std.os.File;
const assert = std.debug.assert;
const warn = std.debug.warn;

pub fn main() anyerror!void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();
    const allocator = &direct_allocator.allocator;

    const input_file = try file.openRead("day2input.txt");
    defer input_file.close();

    const buf = try allocator.alloc(u8, try input_file.getEndPos());
    defer allocator.free(buf);

    _ = input_file.inStream().stream.readFull(buf);

    var box_id1: [100]u8 = undefined;
    var box_id2: [100]u8 = undefined;
    var diff_pos: usize = undefined;

    var iter_i = std.mem.split(buf, "\n");
    outer: while (iter_i.next()) |id_i| {
      var iter_j = std.mem.split(buf, "\n");
      while (iter_j.next()) |id_j| {
        var diffCount: u8 = 0;
        for (id_i) |char,i| {
          if (char != id_j[i]) {
            diffCount += 1;
            diff_pos = i;
          }
        }
        if (diffCount == 1) {
          std.mem.copy(u8, box_id1[0..], id_i[0..]);
          std.mem.copy(u8, box_id2[0..], id_j[0..]);
          break :outer;
        }
      }
    }

    const out = try std.io.getStdOut();
    defer out.close();
    try out.outStream().stream.print("\nThe two box ids are:\n{}\n{}\nThe letters that are the same are:\n{c}{c}\n",box_id1, box_id2, box_id1[0..diff_pos],box_id1[diff_pos+1..]);
}
