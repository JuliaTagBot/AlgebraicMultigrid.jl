function standard_aggregation(S)

    n = size(S, 1)
    x = zeros(Int, n)
    y = zeros(Int, n)

    next_aggregate = 1

    for i = 1:n
        if x[i] != 0
            continue
        end

        has_agg_neighbors = false
        has_neighbors = false

        for j in nzrange(S, i)
            row = S.rowval[j]
            if row != i
                has_neighbors = true
                if x[row] != 0
                    has_agg_neighbors = true
                    break
                end
            end
        end

        if !has_neighbors
            x[i] = -n
        elseif !has_agg_neighbors
            x[i] = next_aggregate
            y[next_aggregate] = i

            for j in nzrange(S, i)
                row = S.rowval[j]
                x[row] = next_aggregate
            end

            next_aggregate += 1
        end
    end

    # Pass 2
    for i = 1:n
        if x[i] != 0
            continue
        end

        for j in nzrange(S, i)
            row = S.rowval[j]
            x_row = x[row]
            if x_row > 0
                x[i] = -x_row
                break
            end
        end
    end

    next_aggregate -= 1

    # Pass 3
    for i = 1:n
        xi = x[i]
        if xi != 0
            if xi > 0
                x[i] = xi - 1
            elseif xi == -n
                x[i] = -1
            else
                x[i] = -xi - 1
            end
            continue
        end

        x[i] = next_aggregate
        y[next_aggregate + 1] = i

        for j in nzrange(S, i)
            row = S.rowval[j]

            if x[row] == 0
                x[row] = next_aggregate
            end
        end

        next_aggregate += 1
    end

    @show next_aggregate
    @show x

    y = y[1:next_aggregate]
    M,N = (n, next_aggregate)

    Tp = collect(1:n+1)
    x .= x .+ 1
    Tx = ones(Int, length(x))

    SparseMatrixCSC(N, M, Tp, x, Tx)
end
