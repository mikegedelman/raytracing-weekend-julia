using StaticArrays
using LinearAlgebra

const Vec3 = SVector{3,Float64}
const Color = Vec3
const Point = Vec3

function lengthSquared(vec::Vec3)
    dot(vec, vec)
end

function length(vec::Vec3)
    sqrt(lengthSquared(vec))
end

