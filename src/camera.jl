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
end

function Camera(
    lookfrom::Point3,
    lookat::Point3,
    vup::Vec3,
    vfov::Float64,
    aspectRatio::Float64
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
    horizontal = viewportWidth .* u
    vertical = viewportHeight .* v
    lowerLeftCorner = origin - (horizontal ./ 2) - (vertical ./ 2) - w
    Camera(origin, horizontal, vertical, lowerLeftCorner)
end


function getRay(camera::Camera, s::Float64, t::Float64)
    Ray(camera.origin, camera.lowerLeftCorner + (s * camera.horizontal) + (t * camera.vertical) - camera.origin)
end
