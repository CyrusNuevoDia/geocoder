defmodule Geocoder.HttpClient.Httpoison do
  @moduledoc """
  HTTPoison client. See HTTPoison for documentation for options that can be passed
  in the http_client_opts
  """
  @behaviour Geocoder.HttpClient

  if Code.ensure_loaded?(HTTPoison) do
    def request(%{method: method, url: url, query_params: params} = request, config \\ []) do
      http_client_opts = config[:http_client_opts]
      json_codec = config[:json_codec]
      httpoison_module = config[:httpoison_module] || HTTPoison

      opts = [:with_body | http_client_opts] ++ [ibrowse: [headers_as_is: true], params: params]
      headers = request[:headers] || []

      case httpoison_module.request(method, url, "", headers, opts) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
          {:ok, %{status_code: 200, body: json_codec.decode!(body), headers: headers}}

        {:ok, %HTTPoison.Response{status_code: code, body: body, headers: headers}} ->
          {:ok, %{status_code: code, body: body, headers: headers}}

        {:error, %HTTPoison.Error{} = error} ->
          {:error, error}
      end
    end
  end
end
