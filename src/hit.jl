include("vec3.jl")


abstract type Material end

struct Lambertian <: Material
    albedo::Color
end

struct Metal <: Material
    albedo::Color
    fuzz::Float64
end

struct Dialectric <: Material
    ir::Float64
end

struct HitRecord
    p::Point3
    normal::Vec3
    t::Float64
    frontFace::Bool
    material::Material
end

abstract type Hittable end

struct Sphere <: Hittable
    center::Point3
    radius::Float64
    material::Material
end

function getFaceNormal(ray::Ray, outwardNormal::Vec3)
    frontFace = dot(ray.direction, outwardNormal) < 0
    normal = if frontFace outwardNormal else -outwardNormal end
    (frontFace, normal)
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
    Some(HitRecord(p, normal, t, frontFace, sphere.material))
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


function scatter(metal::Metal, ray::Ray, rec::HitRecord)
    reflected = reflect(unitVector(ray.direction), rec.normal)
    scattered = Ray(rec.p, reflected + metal.fuzz * randomInUnitSphere())

    (metal.albedo, scattered)
end


function scatter(lambertian::Lambertian, ray::Ray, rec::HitRecord)
    scatterDirection = rec.normal + randomUnitVector()

    # Catch degenerate scatter direction
    if nearZero(scatterDirection)
        scatterDirection = rec.normal
    end

    scattered = Ray(rec.p, scatterDirection)
    (lambertian.albedo, scattered)
end

function refract(uv::Vec3, n::Vec3,  etaiOverEtat::Float64)
    cosTheta = min(dot(-uv, n), 1.0)
    rOutPerp = etaiOverEtat .* (uv .+ (cosTheta .* n))
    rOutParallel = -sqrt(abs(1.0 .- lengthSquared(rOutPerp))) .* n
    rOutPerp + rOutParallel
end

function reflectance(cosine::Float64, refIdx::Float64)
    # Use Schlick's approximation for reflectance
    r0 = (1 - refIdx) / (1 + refIdx)
    r0 = r0 * r0
    r0 + ((1 - r0) * ((1 - cosine) ^ 5))
end

function scatter(dialectric::Dialectric, ray::Ray, rec::HitRecord)
    attenuation = Color(1.0, 1.0, 1.0)
    refractionRatio = if rec.frontFace 1.0 / dialectric.ir else dialectric.ir end

    unitDirection = unitVector(ray.direction)
    cosTheta = min(dot(-unitDirection, rec.normal), 1.0)
    sinTheta = sqrt(1.0 - (cosTheta * cosTheta))

    cannotRefract = refractionRatio * sinTheta > 1.0

    direction = if cannotRefract || reflectance(cosTheta, refractionRatio) > rand(Float64)
        reflect(unitDirection, rec.normal)
    else
        refract(unitDirection, rec.normal, refractionRatio)
    end

    scattered = Ray(rec.p, direction)
    (attenuation, scattered)
end
