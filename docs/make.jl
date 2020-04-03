push!(LOAD_PATH,"../src/")

using Documenter, PointClouds

makedocs(
	format = :html,
	sitename = "PointClouds.jl",
	assets = ["assets/PointClouds.css", "assets/logo.png"],
	pages = [
		"1 - Home" => "index.md",
		"2 - Getting Started" => "gettingStarted.md",
	]
)
