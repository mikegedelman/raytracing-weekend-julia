
struct Ray
    origin::Point3
    direction::Vec3
end

function at(ray::Ray, t::Float64)
    ray.origin .+ (t .* ray.direction)
end
