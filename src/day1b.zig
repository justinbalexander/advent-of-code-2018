const std = @import("std");
const File = std.os.File;
const warn = std.debug.warn;


pub fn main() anyerror!void {
  var direct_allocator = std.heap.DirectAllocator.init();
  defer direct_allocator.deinit();

  const allocator = &direct_allocator.allocator;

  const inputF = try File.openRead("../day1input.txt");
  defer inputF.close();

  const size = try inputF.getEndPos();
  const buf = try allocator.alloc(u8,size);
  defer allocator.free(buf);

  _ = inputF.inStream().stream.readFull(buf);

  var frequencyMap = std.AutoHashMap(i64, bool).init(allocator);
  defer frequencyMap.deinit();

  var result: i64 = 0;
  outer: while (true) {
    var iterator = std.mem.split(buf, "\n");
    while (iterator.next()) |asciiNum| {
      result += try std.fmt.parseInt(i64, asciiNum, 10);
      if (frequencyMap.get(result) == null) {
        _ = try frequencyMap.put(result,true);
      } else {
        break :outer;
      }
    }
  }

  const out= try std.io.getStdOut();
  defer out.close();

  out.outStream().stream.print("\nThis is the answer: {}\n\n", result) catch |err| warn("stdOut Failure: {}\n", err);

}


