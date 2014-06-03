defmodule Elk.Mixfile do
  use Mix.Project

  def project do
    [ app: :elk,
      version: "0.0.1",
      elixir: "~> 0.12.5",
      deps: deps,
      elixirc_options: options(Mix.env) ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [ :exlager, :httpotion,
                      # These next ones are just to cover a bug in elixir 12.x
                      :kernel, :stdlib, :elixir,
                      # This next one may also be an elixir 12.x bug, not sure
                      :erlport, :json ],
      mod: { Elk, [] } ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [ {:erlport, github: "hdima/erlport"},
      {:amrita, "~>0.2", github: "josephwilk/amrita"}, 
      {:httpotion, github: "myfreeweb/httpotion" }, 
      # ibrowse is an httpotion dependency.  It's only here to work around a
      # bug building the version of ibrowse that httpotion currently pulls in
      # by default.
      {:ibrowse, github: "cmullaparthi/ibrowse", ref: "5bae7308a749f2dc801347c27f56dc1a21996aea", override: true},
      {:json, github: "cblage/elixir-json"},
      {:exlager, github: "khia/exlager"},
      {:exrm, github: "bitwalker/exrm"}, 
      {:ex_doc, github: "elixir-lang/ex_doc", ref: "c14203bfca186f68ff178e5ada9af4f5fb37e205"}
    ]
  end

  defp options(_env) do
    [exlager_level: :debug, exlager_truncation_size: 1048576]
  end
end
