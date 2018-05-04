defmodule Toybox do
  @moduledoc """
  Provide tools to create KV and CS objects quickly.
  """

  @doc """
  Print usage

  """
	def usage do
    	"A group of functions meant to be used inside of iex."
	end

  	def get_env(app, var) do
		System.get_env(var) || Application.get_env(app, String.to_atom(var))
	end
end
