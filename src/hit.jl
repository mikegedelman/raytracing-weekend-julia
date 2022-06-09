include("vec3.jl")

function hitSphere(center::Point3, radius::Float64, ray::Ray)
    oc = ray.origin - center
    a = dot(ray.direction, ray.direction)
    b = 2.0 * dot(oc, ray.direction)
    c = dot(oc, oc) - radius * radius
    discriminant = b * b - (4 * a * c)
    discriminant > 0
end
