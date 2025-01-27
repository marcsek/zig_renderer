const t = @import("std").testing;

pub fn Matrix4x4(comptime T: type) type {
    return struct {
        const Self = @This();

        buf: [4][4]T,

        pub fn init(v: T) Self {
            return Self{
                .buf = [_][4]T{[_]T{v} ** 4} ** 4,
            };
        }

        pub fn initProjection(near: T, far: T, fov: T, aspect: T) Self {
            const fovRad = 1.0 / @tan(fov * 0.5 / 180.0 * 3.14159);

            return Self{
                .buf = .{
                    .{ aspect * fovRad, 0.0, 0.0, 0.0 },
                    .{ 0.0, fovRad, 0.0, 0.0 },
                    .{ 0.0, 0.0, far / (far - near), 1 },
                    .{ 0.0, 0.0, (-far * near) / (far - near), 0.0 },
                },
            };
        }

        pub fn multVec3(self: Self, vec: Vec3(T)) Vec3(T) {
            var newX = vec.x * self.buf[0][0] + vec.y * self.buf[1][0] + vec.z * self.buf[2][0] + self.buf[3][0];
            var newY = vec.x * self.buf[0][1] + vec.y * self.buf[1][1] + vec.z * self.buf[2][1] + self.buf[3][1];
            var newZ = vec.x * self.buf[0][2] + vec.y * self.buf[1][2] + vec.z * self.buf[2][2] + self.buf[3][2];
            const w = vec.x * self.buf[0][3] + vec.y * self.buf[1][3] + vec.z * self.buf[2][3] + self.buf[3][3];

            if (w != 0.0) {
                newX /= w;
                newY /= w;
                newZ /= w;
            }

            return Vec3(T).init(newX, newY, newZ);
        }
    };
}

pub fn Vec3(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,

        pub fn init(x: T, y: T, z: T) Self {
            return Self{
                .x = x,
                .y = y,
                .z = z,
            };
        }
    };
}

test "Create Vector" {
    const v = Vec3(i32).init(3, 3, 3);

    try t.expectEqual(v.x, v.y);
}

test "Create Matrix" {
    const m = Matrix4x4(i32).init(0);

    try t.expectEqual(m.buf[0][0], @as(i32, 0));
}
