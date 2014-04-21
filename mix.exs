defmodule Pyexq.Mixfile do
  use Mix.Project

  def project do
    [ app: :pyexq,
      version: "0.0.1",
      elixir: "~> 0.12.5",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [ :exlager, :httpotion ],
      mod: { Pyexq, [] } ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [ {:erlport, github: "hdima/erlport"},
      {:poolboy, github: "devinus/poolboy", tag: "1.0.0"}, 
      {:amrita, "~>0.2", github: "josephwilk/amrita"}, 
      {:httpotion, github: "myfreeweb/httpotion" }, 
      {:json, github: "cblage/elixir-json"},
      {:exlager, github: "khia/exlager"}]
  end
end
