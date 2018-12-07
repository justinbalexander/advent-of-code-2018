const std = @import("std");
const file = std.os.File;
const assert = std.debug.assert;
const warn = std.debug.warn;

pub fn main() anyerror!void {
  var direct_allocator = std.heap.DirectAllocator.init();
  defer direct_allocator.deinit();
  const allocator = &direct_allocator.allocator;

  const input_file = try file.openRead("day3input.txt");
  defer input_file.close();

  const buf = try allocator.alloc(u8,try input_file.getEndPos());
  defer allocator.free(buf);

  _ = input_file.inStream().stream.readFull(buf);

// 1000 sq foot grid, packed struct to make four u2's be in one byte
  var cloth_grid = try allocator.alloc(u2,1000*1000);
  defer allocator.free(cloth_grid);
  std.mem.set(u2,cloth_grid,0);
  warn("\ntype of u2buf: {}\n", @typeName(@typeOf(cloth_grid)));
  warn("\nbytelength: {}\n", @sliceToBytes(cloth_grid).len);

  var iter = std.mem.split(buf,"\n");
  while (iter.next()) |chunk_info| {
    var field_iter = std.mem.split(chunk_info,"# @,:x");
    _ = field_iter.next();
    var x_coord = try std.fmt.parseInt(u32,field_iter.next() orelse []u8{0},10);
    var y_coord = try std.fmt.parseInt(u32,field_iter.next() orelse []u8{0},10);
    var x_length = try std.fmt.parseInt(u32,field_iter.next() orelse []u8{0},10);
    var y_length = try std.fmt.parseInt(u32,field_iter.next() orelse []u8{0},10);
    tickOffChunks(cloth_grid,x_coord,y_coord,x_length,y_length);
  }

  const std_out = try std.io.getStdOut();
  defer std_out.close();
  try std_out.outStream().stream.print("\nThis many square inches of fabric have overlapping claims: {}\n", countOverlappingClaims(cloth_grid));

}

fn tickOffChunks( buf: []u2,
                  x_coord: u32,
                  y_coord: u32,
                  x_length: u32,
                  y_length: u32,) void {
  const hop_distance = 1000;
  var index: u32 = (y_coord * hop_distance) + x_coord;
  var y_temp_len = y_length;
  while (y_temp_len > 0) {
  var x_temp_len = x_length;
      while (x_temp_len > 0 and index < buf.len) {
        if (buf[index] < std.math.maxInt(u2)) {
          buf[index] += 1;
        }
        index += 1;
        x_temp_len -= 1;
      }
      index += hop_distance - x_length;
      y_temp_len -= 1;
  }
  
}

fn countOverlappingClaims(buf: []u2) u32 {
  var answer: u32 = 0;
  for (buf) |count| {
    if (count > 1) {
      answer += 1;
    }
  }
  return answer;
}


test "u2 array" {

  var direct_allocator = std.heap.DirectAllocator.init();
  defer direct_allocator.deinit();
  const allocator = &direct_allocator.allocator;

  var u2buf = try allocator.alloc(u2,1000*1000);
  warn("\ntype of u2buf: {}\n", @typeName(@typeOf(u2buf)));
  warn("\nbytelength: {}\n", @sliceToBytes(u2buf).len);

  var u2buf_slice = u2buf[0..];
  warn("\ntype of u2buf_slice: {}\n", @typeName(@typeOf(u2buf_slice)));
  
}
