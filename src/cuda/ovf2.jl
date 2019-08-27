function write_OVF2_Data(io::IOStream, sim::MicroSimGPU, dataformat::String)
    if dataformat == "text"
        hdr(io, "Begin", "Data " * dataformat)
        write_OVF2_Text(io, sim)
    elseif dataformat == "binary"
        write_OVF2_Binary(io, sim)
    else
        @info "Data format error!"
    end
end

function write_OVF2_Text(io::IOStream, sim::MicroSimGPU)
    Float = _cuda_using_double.x ? Float64 : Float32
    mesh = sim.mesh
    nx, ny, nz = mesh.nx, mesh.ny, mesh.nz
    nxyz = nx*ny*nz
    spin = zeros(Float, 3*nxyz)

    copyto!(spin, sim.spin)

    b = reshape(spin, (3, nx, ny, nz))

    for k = 1:nz, j = 1:ny, i = 1:nx
        write(io, string(b[1, i, j, k], " ", b[2, i, j, k], " ", b[3, i, j, k], "\n"))
    end

end

function write_OVF2_Binary(io::IOStream, sim::MicroSimGPU)
    Float = _cuda_using_double.x ? Float64 : Float32
    binary = _cuda_using_double.x ? "Binary 8" : "Binary 4"
    hdr(io, "Begin", "Data "  * binary)
    
    mesh = sim.mesh
    nx, ny, nz = mesh.nx, mesh.ny, mesh.nz
    nxyz = nx*ny*nz
    spin = zeros(Float, 3*nxyz)

    copyto!(spin, sim.spin)

    b = reshape(spin, (3, nx, ny, nz))
    checknumber = _cuda_using_double.x ? Float(123456789012345.0) : Float(1234567.0)

    write(io, checknumber)   ##OOMMF requires this number to be first to check the format

    for k = 1:nz, j = 1:ny, i = 1:nx
        write(io, Float(b[1, i, j, k]))
        write(io, Float(b[2, i, j, k]))
        write(io, Float(b[3, i, j, k]))
    end

end
