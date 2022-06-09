using Printf

include("vec3.jl")
include("ray.jl")

const aspectRatio = 16.0 / 9.0
const imageWidth = 256
const imageHeight = trunc(Int, imageWidth / aspectRatio)

const viewportHeight = 2.0
const viewportWidth = aspectRatio * viewportHeight
const focalLength = 1.0

const origin = Point3(0, 0, 0)
const horizontal = Vec3(viewportWidth, 0, 0)
const vertical = Vec3(0, viewportHeight, 0)
const lowerLeftCorner = origin - (horizontal / 2) - (vertical / 2) - Vec3(0, 0, focalLength)

function writeColor(file, color::Color)
    ir = trunc(Int, 255.99 * color[1])
    ib = trunc(Int, 255.99 * color[2])
    ig = trunc(Int, 255.99 * color[3])

    @printf file "%d %d %d\n" ir ib ig
end

function rayColor(ray::Ray)
    unit_direction = unitVector(ray.direction)
    t = 0.5 * (unit_direction[2] + 1.0)
    ((1.0 - t) * Color(1, 1, 1)) + (t * Color(0.5, 0.7, 1.0))
end

function main()
    file = open("image.ppm", "w")

    @printf file "P3\n%d %d\n255\n" imageWidth imageHeight
    for j in reverse(0:imageHeight - 1)
        for i in (0:imageWidth - 1)
            u = Float64(i) / (imageWidth - 1)
            v = Float64(j) / (imageHeight - 1)
            r = Ray(origin, lowerLeftCorner + (u * horizontal) + (v * vertical) - origin)
            pixelColor = rayColor(r)

            writeColor(file, pixelColor)
        end
    end

    close(file)
end

main()
