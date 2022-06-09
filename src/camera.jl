include("vec3.jl")
include("ray.jl")


struct Camera
    origin::Point3
    horizontal::Vec3
    vertical::Vec3
    lowerLeftCorner::Point3
end

function Camera()
    aspectRatio = 16.0 / 9.0
    viewportHeight = 2.0
    viewportWidth = aspectRatio * viewportHeight
    focalLength = 1.0

    origin = Point3(0, 0, 0)
    horizontal = Vec3(viewportWidth, 0, 0)
    vertical = Vec3(0, viewportHeight, 0)
    lowerLeftCorner = origin - (horizontal ./ 2) - (vertical ./ 2) - Vec3(0, 0, focalLength)
    Camera(origin, horizontal, vertical, lowerLeftCorner)
end


function getRay(camera::Camera, u::Float64, v::Float64)
    Ray(camera.origin, camera.lowerLeftCorner + (u * camera.horizontal) + (v * camera.vertical) - camera.origin)
end
