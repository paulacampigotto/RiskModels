using Plots

function readFile(fileName)
	global adjClose = []
	file = open(fileName) do file
		for l in eachline(file)
			if split(l,",")[6] != "Adj Close"
				push!(adjClose, parse(Float64, split(l,",")[6]) )
			end
		end
	end
end

function returnValue()
	global return_ = []
	for i in 1:(length(adjClose) - 1)
		push!(return_, (adjClose[i+1] - adjClose[i])/adjClose[i])
	end
end

function garchVarianceValue()
	global garchVariance = []
	push!(garchVariance, abs2(return_[1]))
	for i in 2:( length(return_) -1 )
		push!(garchVariance, ω + ( α * abs2(return_[i]) ) + ( β * abs2(garchVariance[i-1]) ) )
	end
end

function likelihoodValue()
	global likelihood = 0
	for i in 1:( length(garchVariance) -1)
		likelihood = likelihood + ( (-1 * log(garchVariance[i])) - abs2(return_[i+1])/garchVariance[i] )
	end
	println(likelihood) #optimize this number, using the parameters
end

function ewmaVarianceValue()
	global ewmaVariance = []
	push!(ewmaVariance, abs2(return_[1]))
	for i in 2:( length(return_) -1 )
		push!(ewmaVariance, (1-λ)*return_[i] + λ*ewmaVariance[i-1] )
	end
end

function lpmVarianceValue()
	global lpmVariance = []
	push!(lpmVariance, abs2(return_[1]))
	for i in 2:( length(return_) -1 )
		push!(lpmVariance, (min(return_[i] - τ, 0)^k)^(1/k)) # E() ?
	end
end


global ω, α, β, λ, τ, k

ω = 0.0001
α = 0.75
β = 0.1
λ = 0.94
τ = 0 # retorno-alvo: média do ativo, taxa livre de risco, um benchmarking (como o Ibovespa) ou mesmo o zero.
k = 2 # nível de aversão ao risco do investidor

#k = 0 (safety first) maior nível de aversão ao risco do investidor
#k = 1 (regret)
#k = 2 (second order)
#k = 3 (semi-skewness)
#k = 4 (semi-kurtosis)  menor nível de aversão ao risco do investidor

#file = "PBR_2015-2019"
file = "AAPL_2015-2019"

readFile(file * ".csv")
returnValue()
garchVarianceValue()
ewmaVarianceValue()
lpmVarianceValue()

returnPlot = plot(return_, label = "Return", title = "Return",linecolor = :red)
garchPlot = plot(garchVariance, label = "GARCH", title = "GARCH",linecolor = :red)
ewmaPlot = plot(ewmaVariance, label = "EWMA", title = "EWMA",linecolor = :red)
lpmPlot = plot(lpmVariance, label = "LPM", title = "LPM",linecolor = :red)

savefig(returnPlot, file * "Return" * ".png")
savefig(garchPlot, file * "Garch" * ".png")
savefig(ewmaPlot, file * "Ewma" * ".png")
savefig(lpmPlot, file * "Lpm" * ".png")
