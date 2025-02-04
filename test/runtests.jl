module FEFMM_Tests
    using Test
    using FEFMM
    using UnicodePlots
    using LinearAlgebra: norm

    include("testmediums.jl")

    @testset "FEFMM Tests" begin
        @testset "Solve Piecewise Quadratic" begin
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,1.0,1.0), 2.0)
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,1.0,1.0,1.0,1.0), 1.0+1/sqrt(2))
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,1.0,100.0,1.0,1.0), 2.0)
            @test isapprox(FEFMM.solve_piecewise_quadratic(2.0,1.0,1.0,100.0,1.0), 1.0)
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,1.0,1.0,1.0,1.0,1.0,1.0), 1.0+1/sqrt(3))
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,2.0,3.0,100.0,10.0,1.0,1.0), 2.0/3.0)
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,2.0,3.0,10.0,100.0,1.0,1.0), 2.0/3.0)
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,2.0,3.0,10.0,1.0,100.0,1.0), 1.0)
            @test isapprox(FEFMM.solve_piecewise_quadratic(1.0,2.0,3.0,1.0,10.0,100.0,1.0), 2.0)
        end

        @testset "Basic FEFMM Checks" begin
            κ21d = ones(101)
            dx1d = [0.1]
            xs1d = CartesianIndex(1)
            τa1d = 0:0.1:10
            @test all(isapprox.(τa1d, FEFMM.fefmm(κ21d, dx1d, xs1d)[1]))
            κ22d = ones(101,101)
            dx2d = [0.1,0.1]
            xs2d = CartesianIndex(1,1)
            τaxis = 0:0.1:10
            τa2d = sqrt.(τaxis'.^2 .+ τaxis.^2)
            @test all(isapprox.(τa2d, FEFMM.fefmm(κ22d, dx2d, xs2d)[1]))
            κ23d = ones(101,101,101)
            dx3d = [0.1,0.1,0.1]
            xs3d = CartesianIndex(1,1,1)
            τa3d = zeros(101,101,101)
            for k in 1:101
                for j in 1:101
                    for i in 1:101
                        τa3d[i,j,k] = sqrt(τaxis[i]^2+τaxis[j]^2+τaxis[k]^2)
                    end
                end
            end
            @test all(isapprox.(τa3d, FEFMM.fefmm(κ23d, dx3d, xs3d)[1]))
        end

        @testset "Constant Gradient of Squared Slowness 2D" begin
            hlist = [1/20, 1/40, 1/80, 1/160, 1/320]#, 1/640, 1/1280]
            linorm = zeros(length(hlist))
            l2norm = zeros(length(hlist))
            for i = 1:length(hlist)
                (x0, k2, t_exact) = const_k2_2D(hlist[i])
                (t_pred, ordering) = FEFMM.fefmm(k2, [hlist[i], hlist[i]], x0)
                err = t_exact.-t_pred
                linorm[i] = norm(err, Inf)
                l2norm[i] = norm(err, 2)/sqrt(length(err))
            end

            plt = lineplot(log10.(hlist), 
                           log10.(linorm),
                           title = "Constant Gradient of Squared Slowness 2D",
                           name = "L_inf norm",
                           xlabel = "log_10(h)",
                           ylabel = "log_10(Error)", 
                           xlim = [floor(minimum(log10.(hlist))), ceil(maximum(log10.(hlist)))],
                           ylim = [floor(minimum(log10.([linorm; l2norm]))), ceil(maximum(log10.([linorm; l2norm])))],
                           color = :blue)
            
            lineplot!(plt, log10.(hlist), log10.(l2norm), name = "mean L2 norm", color = :red)
            println(plt)
            @test reverse(linorm) == sort(linorm) #test for decreasing error with decreasing h
            @test reverse(l2norm) == sort(l2norm)
        end

        @testset "Constant Gradient of Squared Velocity 2D" begin
            hlist = [1/20, 1/40, 1/80, 1/160, 1/320]#, 1/640, 1/1280]
            linorm = zeros(length(hlist))
            l2norm = zeros(length(hlist))
            for i = 1:length(hlist)
                (x0, k2, t_exact) = const_v2_2D(hlist[i])
                (t_pred, ordering) = FEFMM.fefmm(k2, [hlist[i], hlist[i]], x0)
                err = t_exact.-t_pred
                linorm[i] = norm(err, Inf)
                l2norm[i] = norm(err, 2)/sqrt(length(err))
            end

                plt = lineplot(log10.(hlist), 
                            log10.(linorm),
                            title = "Constant Gradient of Squared Velocity 2D",
                            name = "L_inf norm",
                            xlabel = "log_10(h)",
                            ylabel = "log_10(Error)", 
                            xlim = [floor(minimum(log10.(hlist))), ceil(maximum(log10.(hlist)))],
                            ylim = [floor(minimum(log10.([linorm; l2norm]))), ceil(maximum(log10.([linorm; l2norm])))],
                            color = :blue)

            lineplot!(plt, log10.(hlist), log10.(l2norm), name = "mean L2 norm", color = :red)
            println(plt)
            @test reverse(linorm) == sort(linorm) #test for decreasing error with decreasing h
            @test reverse(l2norm) == sort(l2norm)
        end

        @testset "Gaussian Factor 2D" begin
            hlist = [1/20, 1/40, 1/80, 1/160, 1/320]#, 1/640, 1/1280]
            linorm = zeros(length(hlist))
            l2norm = zeros(length(hlist))
            for i = 1:length(hlist)
                (x0, k2, t_exact) = gaussian_factor_2D(hlist[i])
                (t_pred, ordering) = FEFMM.fefmm(k2, [hlist[i], hlist[i]], x0)
                err = t_exact.-t_pred
                linorm[i] = norm(err, Inf)
                l2norm[i] = norm(err, 2)/sqrt(length(err))
            end

                plt = lineplot(log10.(hlist), 
                            log10.(linorm),
                            title = "Gaussian Factor 2D",
                            name = "L_inf norm",
                            xlabel = "log_10(h)",
                            ylabel = "log_10(Error)", 
                            xlim = [floor(minimum(log10.(hlist))), ceil(maximum(log10.(hlist)))],
                            ylim = [floor(minimum(log10.([linorm; l2norm]))), ceil(maximum(log10.([linorm; l2norm])))],
                            color = :blue)

            lineplot!(plt, log10.(hlist), log10.(l2norm), name = "mean L2 norm", color = :red)
            println(plt)
            @test reverse(linorm) == sort(linorm) #test for decreasing error with decreasing h
            @test reverse(l2norm) == sort(l2norm)
        end
        
        @testset "Constant Gradient of Squared Slowness 3D" begin
            hlist = [1/10, 1/20, 1/40, 1/80]#, 1/160, 1/320]
            linorm = zeros(length(hlist))
            l2norm = zeros(length(hlist))
            for i = 1:length(hlist)
                (x0, k2, t_exact) = const_k2_3D(hlist[i])
                (t_pred, ordering) = FEFMM.fefmm(k2, [hlist[i], hlist[i], hlist[i]], x0)
                err = t_exact.-t_pred
                linorm[i] = norm(err, Inf)
                l2norm[i] = norm(err, 2)/sqrt(length(err))
            end

            plt = lineplot(log10.(hlist), 
                           log10.(linorm),
                           title = "Constant Gradient of Squared Slowness 3D",
                           name = "L_inf norm",
                           xlabel = "log_10(h)",
                           ylabel = "log_10(Error)", 
                           xlim = [floor(minimum(log10.(hlist))), ceil(maximum(log10.(hlist)))],
                           ylim = [floor(minimum(log10.([linorm; l2norm]))), ceil(maximum(log10.([linorm; l2norm])))],
                           color = :blue)
            
            lineplot!(plt, log10.(hlist), log10.(l2norm), name = "mean L2 norm", color = :red)
            println(plt)
            @test reverse(linorm) == sort(linorm) #test for decreasing error with decreasing h
            @test reverse(l2norm) == sort(l2norm)
        end

        @testset "Constant Gradient of Squared Velocity 3D" begin
            hlist = [1/10, 1/20, 1/40, 1/80]#, 1/160, 1/320]
            linorm = zeros(length(hlist))
            l2norm = zeros(length(hlist))
            for i = 1:length(hlist)
                (x0, k2, t_exact) = const_v2_3D(hlist[i])
                (t_pred, ordering) = FEFMM.fefmm(k2, [hlist[i], hlist[i], hlist[i]], x0)
                err = t_exact.-t_pred
                linorm[i] = norm(err, Inf)
                l2norm[i] = norm(err, 2)/sqrt(length(err))
            end

            plt = lineplot(log10.(hlist), 
                           log10.(linorm),
                           title = "Constant Gradient of Squared Velocity 3D",
                           name = "L_inf norm",
                           xlabel = "log_10(h)",
                           ylabel = "log_10(Error)", 
                           xlim = [floor(minimum(log10.(hlist))), ceil(maximum(log10.(hlist)))],
                           ylim = [floor(minimum(log10.([linorm; l2norm]))), ceil(maximum(log10.([linorm; l2norm])))],
                           color = :blue)
            
            lineplot!(plt, log10.(hlist), log10.(l2norm), name = "mean L2 norm", color = :red)
            println(plt)
            @test reverse(linorm) == sort(linorm) #test for decreasing error with decreasing h
            @test reverse(l2norm) == sort(l2norm)
        end

        @testset "Gaussian Factor 3D" begin
            hlist = [1/10, 1/20, 1/40, 1/80]#, 1/160, 1/320]
            linorm = zeros(length(hlist))
            l2norm = zeros(length(hlist))
            for i = 1:length(hlist)
                (x0, k2, t_exact) = gaussian_factor_3D(hlist[i])
                (t_pred, ordering) = FEFMM.fefmm(k2, [hlist[i], hlist[i], hlist[i]], x0)
                err = t_exact.-t_pred
                linorm[i] = norm(err, Inf)
                l2norm[i] = norm(err, 2)/sqrt(length(err))
            end

            plt = lineplot(log10.(hlist), 
                           log10.(linorm),
                           title = "Gaussian Factor 3D",
                           name = "L_inf norm",
                           xlabel = "log_10(h)",
                           ylabel = "log_10(Error)", 
                           xlim = [floor(minimum(log10.(hlist))), ceil(maximum(log10.(hlist)))],
                           ylim = [floor(minimum(log10.([linorm; l2norm]))), ceil(maximum(log10.([linorm; l2norm])))],
                           color = :blue)
            
            lineplot!(plt, log10.(hlist), log10.(l2norm), name = "mean L2 norm", color = :red)
            println(plt)
            @test reverse(linorm) == sort(linorm) #test for decreasing error with decreasing h
            @test reverse(l2norm) == sort(l2norm)
        end

    end
end