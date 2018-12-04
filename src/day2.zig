const std = @import("std");
const file = std.os.File;
const assert = std.debug.assert;

pub fn main() anyerror!void {
  var doubles_count: u64 = 0;
  var triples_count: u64 = 0;

  var direct_allocator = std.heap.DirectAllocator.init();
  defer direct_allocator.deinit();
  const allocator = &direct_allocator.allocator;

  const input_file = try file.openRead("day2input.txt");
  defer input_file.close();

  const buf = try allocator.alloc(u8,try input_file.getEndPos());
  defer allocator.free(buf);

  _ = input_file.inStream().stream.readFull(buf);

  var iter = std.mem.split(buf, "\n");
  while (iter.next()) |box_id| {
    const packed_result = try countDoubleAndTriple(allocator, box_id);
    doubles_count += packed_result.double;
    triples_count += packed_result.triple;
  }

  const out = try std.io.getStdOut();
  defer out.close();
  try out.outStream().stream.print("\nThe checksum is {} * {} = {}",
                                    doubles_count,
                                    triples_count,
                                    doubles_count * triples_count);

}

pub const CountDandT = struct {
  double: u8,
  triple: u8,
};

fn countDoubleAndTriple(allocator: *std.mem.Allocator, box_id: []const u8) !CountDandT {
  var retVal  = CountDandT {
                  .double = 0,
                  .triple = 0,
                };
  var countMap = std.AutoHashMap(u8, u8).init(allocator);
  defer countMap.deinit();
  for (std.mem.trim(u8,box_id," ")) |char| {
    if (countMap.get(char)) |item| {
      _ = try countMap.put(item.key, item.value + 1);
    } else {
      _ = try countMap.put(char, 1);
    }
  }

  var iter = countMap.iterator();
  while (iter.next()) |kv_pair| {
    if (kv_pair.value == 2) {
      retVal.double = 1;
    } else if (kv_pair.value == 3) {
      retVal.triple = 1;
    }
  }

  return retVal;
}

test "count" {
  var answer1 = try countDoubleAndTriple(std.debug.global_allocator, "aaabcb");
  assert(answer1.double == 1);
  assert(answer1.triple == 1);
}
