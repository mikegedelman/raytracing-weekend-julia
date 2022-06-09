using Printf

include("vec3.jl")
include("ray.jl")
include("hit.jl")
include("camera.jl")

const aspectRatio = 16.0 / 9.0
const imageWidth = 256
const imageHeight = trunc(Int, imageWidth / aspectRatio)
const samplesPerPixel = 100

function writeColor(file, color::Color, samplesPerPixel::Int)
    scale = 1.0 / samplesPerPixel
    r = 256 * clamp(scale * color[1], 0.0, 0.999)
    g = 256 * clamp(scale * color[2], 0.0, 0.999)
    b = 256 * clamp(scale * color[3], 0.0, 0.999)

    @printf file "%d %d %d\n" r g b
end

function rayColor(ray::Ray, objects::Vector{Hittable})
    sphere = Sphere(Point3(0, 0, -1), 0.5)

    # I highly doubt this is how to properly handle Some/None
    # TODO: fixme
    rec = something(hitList(objects, ray, 0.0, Inf))
    if rec != Nothing
        return 0.5 * (rec.normal + Color(1, 1, 1))
    end

    unit_direction = unitVector(ray.direction)
    t = 0.5 * (unit_direction[2] + 1.0)
    ((1.0 - t) * Color(1, 1, 1)) + (t * Color(0.5, 0.7, 1.0))
end

function main()
    file = open("image.ppm", "w")

    world = Hittable[]
    push!(world, Sphere(Point3(0, 0, -1), 0.5))
    push!(world, Sphere(Point3(0, -100.5, -1), 100))

    camera = Camera()

    @printf file "P3\n%d %d\n255\n" imageWidth imageHeight
    for j in reverse(0:imageHeight - 1)
        for i in (0:imageWidth - 1)
            pixelColor = Color(0, 0, 0)

            for s in (0:samplesPerPixel - 2)
                u = Float64(i + rand(Float64)) / (imageWidth - 1)
                v = Float64(j + rand(Float64)) / (imageHeight - 1)

                ray = getRay(camera, u, v)
                pixelColor += rayColor(ray, world)
            end

            writeColor(file, pixelColor, samplesPerPixel)
        end
    end

    close(file)
end

main()
