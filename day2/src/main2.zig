const std = @import("std");
const ArrayList = std.ArrayList;

const MAXR = 12;
const MAXG = 13;
const MAXB = 14;

fn splitLine(allocator: std.mem.Allocator, line: []const u8) !ArrayList([]const u8) {
    var ret = ArrayList([]const u8).init(allocator);

    var split = std.mem.split(u8, line, ":");

    if (split.next()) |first| {
        try ret.append(first);
    }

    if (split.next()) |second| {
        var sets = std.mem.split(u8, second, ";");
        while (sets.next()) |set| {
            try ret.append(set);
        }
    }

    return ret;
}

fn countGame(sets: [][]const u8) !u128 {
    var red: u16 = 0;
    var green: u16 = 0;
    var blue: u16 = 0;

    for (sets) |set| {
        var i: usize = 0;
        var temp: u8 = 0;
        var len: u16 = 0;
        while (i < set.len) : (i += 1) {
            if (std.ascii.isDigit(set[i])) {
                if (std.ascii.isDigit(set[i + 1])) {
                    temp = try std.fmt.parseInt(u8, set[i .. i + 2], 10);
                    i += 1;
                } else {
                    temp = try std.fmt.parseInt(u8, set[i .. i + 1], 10);
                }
            } else if (!std.ascii.isWhitespace(set[i]) and set[i] != ',') {
                len += 1;
                if (i + 1 == set.len) {
                    switch (len) {
                        3 => {
                            if (temp > red) red = temp;
                        },
                        4 => {
                            if (temp > blue) blue = temp;
                        },
                        5 => {
                            if (temp > green) green = temp;
                        },
                        else => std.debug.print("Oopsie\n", .{}),
                    }
                    temp = 0;
                    len = 0;
                }
            } else if (std.mem.eql(u8, set[i .. i + 1], ",")) {
                switch (len) {
                    3 => {
                        if (temp > red) red = temp;
                    },
                    4 => {
                        if (temp > blue) blue = temp;
                    },
                    5 => {
                        if (temp > green) green = temp;
                    },
                    else => std.debug.print("Oopsie\n", .{}),
                }
                temp = 0;
                len = 0;
            }
        }
    }
    std.debug.print("{d} * {d} * {d}\n", .{ red, green, blue });
    const ret: u64 = red * blue;
    return ret * green;
}

test {
    var sets = [_][]const u8{ " 3 blue, 4 red,", " 1 red, 2 green, 6 blue,", " 2 green," };
    var sets2 = [_][]const u8{ "8 green, 6 blue, 20 red,", " 5 blue, 4 red, 13 green,", " 5 green, 1 red," };

    const good = try countGame(&sets);
    const bad = try countGame(&sets2);
    try std.testing.expect(good == 48);
    try std.testing.expect(bad == 1560);
}

pub fn main() !void {
    const alloc = std.heap.c_allocator;
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const stat = try file.stat();
    const contents = try file.reader().readAllAlloc(alloc, stat.size);
    defer alloc.free(contents);

    var lines = std.mem.split(u8, contents, "\n");

    var total: u256 = 0;

    while (lines.next()) |line| {
        const list = try splitLine(alloc, line);
        defer list.deinit();

        const sets = list.items[1..];
        const power = try countGame(sets);
        total += power;
    }
    std.debug.print("{d}\n", .{total});
}
