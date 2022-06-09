using Printf

include("vec3.jl")
include("ray.jl")
include("hit.jl")
include("camera.jl")

const aspectRatio = 3.0 / 2.0
const imageWidth = 1200
const imageHeight = trunc(Int, imageWidth / aspectRatio)
const samplesPerPixel = 100
const maxDepth = 50

function writeColor(file, color::Color, samplesPerPixel::Int)
    scale = 1.0 / samplesPerPixel
    r = 256 * clamp(sqrt(scale * color[1]), 0.0, 0.999)
    g = 256 * clamp(sqrt(scale * color[2]), 0.0, 0.999)
    b = 256 * clamp(sqrt(scale * color[3]), 0.0, 0.999)

    @printf file "%d %d %d\n" r g b
end

function writeFile(filePath, pixels)
    open(filePath, "w") do file
        @printf file "P3\n%d %d\n255\n" imageWidth imageHeight
        for pixel in pixels
            writeColor(file, pixel, samplesPerPixel)
        end
        close(file)
    end
end

function rayColor(ray::Ray, objects::Vector{Hittable}, depth::Int)
    if depth <= 0
        return Color(0, 0, 0)
    end

    # I highly doubt this is how to properly handle Some/None
    # TODO: fixme
    rec = something(hitList(objects, ray, 0.001, Inf))
    if rec != Nothing
        attenuation, scattered = scatter(rec.material, ray, rec)
        return attenuation .* rayColor(scattered, objects, depth - 1)
    end

    unit_direction = unitVector(ray.direction)
    t = 0.5 * (unit_direction[2] + 1.0)
    ((1.0 - t) * Color(1, 1, 1)) .+ (t * Color(0.5, 0.7, 1.0))
end

function runSamples(
    camera::Camera,
    world::Vector{Hittable},
    pixels::Vector{Color},
    i::Int,
    j::Int
)::Color
    pixelColor = Color(0, 0, 0)

    for s in (0:samplesPerPixel - 2)
        u = Float64(i + rand(Float64)) / (imageWidth - 1)
        v = Float64(j + rand(Float64)) / (imageHeight - 1)

        ray = getRay(camera, u, v)
        pixelColor += rayColor(ray, world, maxDepth)
    end

    pixelColor
end

function randomScene()
    world = Hittable[]

    groundMaterial = Lambertian(Color(0.5, 0.5, 0.5))
    push!(world, Sphere(Point3(0, -1000, 0), 1000, groundMaterial))

    for a in -11:10
        for b in -11:10
            chooseMat = rand()
            center = Point3(a + (0.9 * rand()), 0.2, b + (0.9 * rand()))

            if length(center .- Point3(4, 0.2, 0)) > 0.9
                sphereMaterial = if chooseMat < 0.8
                    # diffuse
                    albedo = rand(Vec3) .* rand(Vec3)
                    Lambertian(albedo)
                elseif chooseMat < 0.95
                    # metal
                    albedo = rand(0.5:0.0001:1.0, Vec3)
                    fuzz = rand(0.0:0.0001:0.5)
                    Metal(albedo, fuzz)
                else
                    # glass
                    Dialectric(1.5)
                end

                push!(world, Sphere(center, 0.2, sphereMaterial))
            end
        end
    end

    material1 = Dialectric(1.5)
    push!(world, Sphere(Point3(0, 1, 0), 1.0, material1))

    material2 = Lambertian(Color(0.4, 0.2, 0.1))
    push!(world, Sphere(Point3(04, 1, 0), 1.0, material2))

    material3 = Metal(Color(0.7, 0.6, 0.5), 0.0)
    push!(world, Sphere(Point3(4, 1, 0), 1.0, material3))

    world
end

function main()
    world = randomScene()

    lookfrom = Point3(13, 2, 3)
    lookat = Point3(0, 0, 0)
    vup = Vec3(0, 1, 0)
    distToFocus = 10.0
    aperture = 0.1
    camera = Camera(lookfrom, lookat, vup, 20.0, aspectRatio, aperture, distToFocus);

    pixels = Color[]
    @time begin
        for j in reverse(0:imageHeight - 1)
            for i in (0:imageWidth - 1)
                pixelColor = runSamples(camera, world, pixels, i, j)
                push!(pixels, pixelColor)
            end
        end
    end # end timing

    writeFile("image.ppm", pixels)
end

main()
