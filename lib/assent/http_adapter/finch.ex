defmodule Assent.HTTPAdapter.Finch do
  @moduledoc """
  HTTP adapter module for making http requests with Finch.

  The Finch adapter must be configured with the supervisor
  `http_adapter: {Assent.HTTPAdapter.Finch, [supervisor: MyFinch]}`.

  See `Assent.HTTPAdapter` for more.
  """
  alias Assent.{HTTPAdapter, HTTPAdapter.HTTPResponse}

  @behaviour HTTPAdapter

  @impl HTTPAdapter
  def request(method, url, body, headers, finch_opts \\ nil) do
    headers = headers ++ [HTTPAdapter.user_agent_header()]

    supervisor = Keyword.get(finch_opts || [], :supervisor) || raise "Missing `:supervisor` option for the #{__MODULE__} configuration"
    build_opts = Keyword.get(finch_opts || [], :build, [])
    request_opts = Keyword.get(finch_opts || [], :request, [])

    method
    |> Finch.build(url, headers, body, build_opts)
    |> Finch.request(supervisor, request_opts)
    |> case do
      {:ok, response} -> {:ok, %HTTPResponse{status: response.status, headers: response.headers, body: response.body}}
      {:error, error} -> {:error, error}
    end
  end
end
