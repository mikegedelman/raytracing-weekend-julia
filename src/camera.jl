include("vec3.jl")
include("ray.jl")

function degreesToRadians(degrees::Float64)
    degrees * (pi / 180.0)
end

struct Camera
    origin::Point3
    horizontal::Vec3
    vertical::Vec3
    lowerLeftCorner::Point3
    u::Vec3
    v::Vec3
    # w not used
    lensRadius::Float64
end

function Camera(
    lookfrom::Point3,
    lookat::Point3,
    vup::Vec3,
    vfov::Float64,
    aspectRatio::Float64,
    aperture::Float64,
    focusDist::Float64
)
    theta = degreesToRadians(vfov)
    h = tan(theta / 2)
    viewportHeight = 2.0 * h
    viewportWidth = aspectRatio * viewportHeight

    w = unitVector(lookfrom .- lookat)
    u = unitVector(cross(vup, w))
    v = cross(w, u)

    focalLength = 1.0

    origin = lookfrom
    horizontal = focusDist .* viewportWidth .* u
    vertical = focusDist .* viewportHeight .* v
    lowerLeftCorner = origin - (horizontal ./ 2) - (vertical ./ 2) - (focusDist .* w)

    lensRadius = aperture / 2

    Camera(origin, horizontal, vertical, lowerLeftCorner, u, v, lensRadius)
end


# Quick helper function for randomInUnitDisk
randomDoubleNegative() = rand(-1.0:0.0000001:1.0)

function randomInUnitDisk()
    while true
        p = Vec3(randomDoubleNegative(), randomDoubleNegative(), 0.0)
        if lengthSquared(p) < 1
            return p
        end
    end
end

function getRay(camera::Camera, s::Float64, t::Float64)
    rd = camera.lensRadius * randomInUnitDisk()
    offset = (camera.u .* rd[1]) .+ (camera.v .* rd[2])
    Ray(
        camera.origin + offset,
        camera.lowerLeftCorner + (s * camera.horizontal) + (t * camera.vertical) - camera.origin - offset
    )
end
