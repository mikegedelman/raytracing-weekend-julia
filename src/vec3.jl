using StaticArrays
using LinearAlgebra

const Vec3 = SVector{3,Float64}
const Color = Vec3
const Point3 = Vec3

function lengthSquared(vec::Vec3)
    dot(vec, vec)
end

function length(vec::Vec3)
    sqrt(lengthSquared(vec))
end

function unitVector(vec::Vec3)
    vec ./ length(vec)
end

function randomInUnitSphere()
    while true
        p = rand(-1.0:0.00000001:1.0, Vec3)
        if lengthSquared(p) < 1
            return p
        end
    end
end

function randomUnitVector()
    unitVector(randomInUnitSphere())
end
