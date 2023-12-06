const std = @import("std");

const numbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
const ns = [_][]const u8{ "1", "2", "3", "4", "5", "6", "7", "8", "9" };
fn checkNum(allocator: std.mem.Allocator, line: []const u8) !std.ArrayList([]const u8) {
    var i: usize = 0;
    var ret = std.ArrayList([]const u8).init(allocator);
    while (i < line.len) : (i += 1) {
        var j: usize = 0;
        const curr = line[i .. i + 1];
        if (std.ascii.isDigit(curr[0])) {
            try ret.append(curr);
            continue;
        }

        for (numbers) |num| {
            if (i + (num.len) > line.len) {
                j += 1;
                continue;
            }
            const cmp = line[i .. i + (num.len)];

            if (std.mem.eql(u8, num, cmp)) {
                try ret.append(ns[j]);
            }
            j += 1;
        }
    }
    return ret;
}

test {
    const alloc = std.testing.allocator;
    const inp = "four5725eight";
    const arr = try checkNum(alloc, inp);
    defer arr.deinit();
    std.debug.print("{s}\n", .{arr.items});
}

pub fn main() !void {
    const alloc = std.heap.c_allocator;
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const stat = try file.stat();

    const contents = try file.reader().readAllAlloc(alloc, stat.size);
    defer alloc.free(contents);

    var iter = std.mem.split(u8, contents, "\n");

    var total: u64 = 0;

    while (iter.next()) |line| {
        const arr = try checkNum(alloc, line);
        defer arr.deinit();
        if (arr.items.len != 0) {
            var conc: [2]u8 = undefined;
            conc[0] = arr.items[0][0];
            conc[1] = arr.items[arr.items.len - 1][0];
            const num = try std.fmt.parseInt(u8, &conc, 10);
            total += num;
        }
    }
    std.debug.print("{d}\n", .{total});
}
