using Printf

include("vec3.jl")

const imageWidth = 256
const imageHeight = 256

function writeColor(file, color::Color)
    ir = trunc(Int, 255.99 * color[1])
    ib = trunc(Int, 255.99 * color[2])
    ig = trunc(Int, 255.99 * color[3])

    @printf file "%d %d %d\n" ir ib ig
end

function main()
    file = open("image.ppm", "w")

    @printf file "P3\n%d %d\n255\n" imageWidth imageHeight
    for j in reverse(0:imageHeight - 1)
        for i in (0:imageWidth - 1)
            r = Float64(i) / (imageWidth - 1)
            g = Float64(j) / (imageHeight - 1)
            b = 0.25

            writeColor(file, Color(r, g, b))
        end
    end

    close(file)
end

main()
