const std = @import("std");
const File = std.os.File;

const Alloc = std.debug.global_allocator;

pub fn main() anyerror!void {
    const inputF = try File.openRead("../day1input.txt");
    defer inputF.close();

    const size = try inputF.getEndPos();
    const buf = try Alloc.alloc(u8,size);
    defer Alloc.free(buf);

    _ = inputF.inStream().stream.readFull(buf);

    var endingFrequency = sumListOfAsciiNumbers(buf);

    const out= try std.io.getStdOut();
    defer out.close();

    try out.outStream().stream.print("\nThis is the answer: {}\n\n", endingFrequency);

}

fn sumListOfAsciiNumbers(input: []const u8) !i64 {
  var iterator = std.mem.split(input, "\n");
  var result: i64 = 0;
  while (iterator.next()) |asciiNum| {
    result += try std.fmt.parseInt(i64, asciiNum, 10);
  }
  return result;
}



