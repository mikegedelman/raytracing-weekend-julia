include("vec3.jl")

struct HitRecord
    p::Point3
    normal::Vec3
    t::Float64
    frontFace::Bool
end


function getFaceNormal(ray::Ray, outwardNormal::Vec3)
    frontFace = dot(ray.direction, outwardNormal) < 0
    normal = if frontFace outwardNormal else -outwardNormal end
    (frontFace, normal)
end

abstract type Hittable end

struct Sphere <: Hittable
    center::Point3
    radius::Float64
end

function hit(sphere::Sphere, ray::Ray, tMin::Float64, tMax::Float64)
    oc = ray.origin .- sphere.center
    a = lengthSquared(ray.direction)
    half_b = dot(oc, ray.direction)
    c = lengthSquared(oc) - (sphere.radius * sphere.radius)
    discriminant = (half_b * half_b) - (a * c)

    if discriminant < 0
        return Nothing
    end

    sqrtd = sqrt(discriminant)
    root = (-half_b - sqrtd) / a
    if root < tMin || tMax < root
        root = (-half_b + sqrtd) / a

        if root < tMin || tMax < root
            return Nothing
        end
    end

    t = root
    p = at(ray, root)
    outwardNormal = (p .- sphere.center) ./ sphere.radius
    frontFace, normal = getFaceNormal(ray, outwardNormal)
    Some(HitRecord(p, normal, t, frontFace))
end

function hitList(objects::Vector{Hittable}, ray::Ray, tMin::Float64, tMax::Float64)
    closestRec = Nothing
    closestSoFar = tMax

    for object in objects
        rec = something(hit(object, ray, tMin, closestSoFar))
        if rec != Nothing
            closestRec = Some(rec)
            closestSoFar = rec.t
        end
    end

    closestRec
end
