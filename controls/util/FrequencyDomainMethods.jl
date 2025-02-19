module FrequencyDomainMethods

using Plots, Interact, Printf
plotly()  # Switch to the Plotly backend

export interactive_root_locus, diagonal_root_locus

# Use plotly to interactively plot a roots from get_roots for a single gain using a slider of k_range
function interactive_root_locus(get_roots::Function, k_range)
    # Format hover tool tip with gain and roots
    function root_tooltip(k_val, roots)
        # We assume roots has exactly 2 elements:
        r1, r2 = roots
        return @sprintf("Root Locus<br>K: %.2f<br>R1: %.2f + %.2fj<br>R2: %.2f + %.2fj",
            k_val, real(r1), imag(r1), real(r2), imag(r2))
    end

    # Define colormap for K
    colormap = cgrad([:cyan, :red])  # Define colormap from blue to red
    min_K, max_K = extrema(k_range)  # Get the min and max K values

    # Keep track of all previously used (K, roots) so we can leave black markers behind
    history = []
    prev_K = nothing

    @manipulate for K1 in k_range
        # Save the previous K and its roots to 'history'
        if prev_K == nothing
            prev_K = K1
        else
            push!(history, (prev_K, get_roots(prev_K)))
            prev_K = K1
        end

        # Create the plot
        plt = plot(legend=false, xlabel="Re(s)", ylabel="Im(s)", title="Root Locus")

        # Plot all previous roots using colormap
        xs, ys, tooltips, colors = [], [], [], []
        for (k_val, roots_val) in history
            tip = root_tooltip(k_val, roots_val)
            color = colormap[(k_val - min_K) / (max_K - min_K)]
            for r in roots_val
                push!(xs, real(r))
                push!(ys, imag(r))
                push!(tooltips, tip)
                push!(colors, color)
            end
        end
        scatter!(plt, xs, ys, markercolor=colors, markerstrokewidth=0, markersize=3, hover=tooltips, hoverinfo="text")

        # Plot the current roots in red
        current_roots = get_roots(K1)
        current_tooltip = root_tooltip(K1, current_roots)
        current_color = colormap[(K1 - min_K) / (max_K - min_K)]
        scatter!(plt, real.(current_roots), imag.(current_roots), markercolor=current_color, markersize=5,
                 hover=current_tooltip, hoverinfo="text")

    end
end;

# Use plotly to interactively plot a roots from get_roots for a single gain using a slider of k_range
function diagonal_root_locus(get_roots::Function, k1_val, k2_range, plt; color=nothing, label=nothing)
    # Format hover tool tip with gain and roots
    function root_tooltip(k1_val, k2_val, roots)
        # We assume roots has exactly 2 elements:
        r1, r2 = roots
        return @sprintf("Root Locus<br>K1: %.2f<br>K2: %.2f<br>R1: %.2f + %.2fj<br>R2: %.2f + %.2fj",
            k1_val, k2_val, real(r1), imag(r1), real(r2), imag(r2))
    end

    # Plot all previous roots using colormap
    xs, ys, tooltips, = [], [], []
    for k2_val in k2_range
        roots = get_roots(k1_val, k2_val)
        tip = root_tooltip(k1_val, k2_val, roots)
        for r in roots
            push!(xs, real(r))
            push!(ys, imag(r))
            push!(tooltips, tip)
        end
    end
    scatter!(plt, xs, ys, markerstrokewidth=0, markersize=2, hover=tooltips, hoverinfo="text", markercolor=color, label=label)

end;

end