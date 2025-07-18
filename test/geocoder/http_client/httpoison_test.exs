defmodule Geocoder.HttpClient.HttpoisonTest do
  use ExUnit.Case, async: true

  import Mox

  alias Geocoder.HttpClient.Httpoison

  # Define a mock for HTTPoison
  defmock(HTTPoisonMock, for: HTTPoison.Base)

  setup :verify_on_exit!

  describe "request/2" do
    test "handles 200 status code with JSON decoding" do
      HTTPoisonMock
      |> expect(:request, fn :get, "https://example.com/api", "", [], _opts ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: ~s({"lat": 40.7128, "lon": -74.0060}),
           headers: [{"content-type", "application/json"}]
         }}
      end)

      request = %{
        method: :get,
        url: "https://example.com/api",
        query_params: %{q: "test"}
      }

      config = [
        http_client_opts: [],
        json_codec: Jason,
        httpoison_module: HTTPoisonMock
      ]

      result = Httpoison.request(request, config)

      assert {:ok, %{status_code: 200, body: %{"lat" => 40.7128, "lon" => -74.0060}, headers: _}} =
               result
    end

    test "handles non-200 status codes without JSON decoding" do
      HTTPoisonMock
      |> expect(:request, fn :get, "https://example.com/api", "", [], _opts ->
        {:ok,
         %HTTPoison.Response{
           status_code: 503,
           body: "Service Unavailable",
           headers: [{"content-type", "text/plain"}]
         }}
      end)

      request = %{
        method: :get,
        url: "https://example.com/api",
        query_params: %{}
      }

      config = [
        http_client_opts: [],
        json_codec: Jason,
        httpoison_module: HTTPoisonMock
      ]

      result = Httpoison.request(request, config)

      assert {:ok, %{status_code: 503, body: "Service Unavailable", headers: _}} = result
    end

    test "handles HTTPoison errors" do
      HTTPoisonMock
      |> expect(:request, fn :get, "https://example.com/api", "", [], _opts ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      request = %{
        method: :get,
        url: "https://example.com/api",
        query_params: %{}
      }

      config = [
        http_client_opts: [],
        json_codec: Jason,
        httpoison_module: HTTPoisonMock
      ]

      result = Httpoison.request(request, config)

      assert {:error, %HTTPoison.Error{reason: :timeout}} = result
    end

    test "handles malformed JSON in 200 responses" do
      HTTPoisonMock
      |> expect(:request, fn :get, "https://example.com/api", "", [], _opts ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: "invalid json{",
           headers: [{"content-type", "application/json"}]
         }}
      end)

      request = %{
        method: :get,
        url: "https://example.com/api",
        query_params: %{}
      }

      config = [
        http_client_opts: [],
        json_codec: Jason,
        httpoison_module: HTTPoisonMock
      ]

      # This should raise an exception when trying to decode invalid JSON
      assert_raise Jason.DecodeError, fn ->
        Httpoison.request(request, config)
      end
    end

    test "verifies the fix prevents crashes on various non-200 responses" do
      # Test multiple non-200 status codes to ensure they all return raw body
      test_cases = [
        {404, "Not Found", [{"content-type", "text/html"}]},
        {500, "Internal Server Error", [{"content-type", "text/plain"}]},
        {502, "Bad Gateway", [{"content-type", "text/html"}]},
        {429, "Too Many Requests", [{"content-type", "application/json"}]}
      ]

      for {status_code, body, headers} <- test_cases do
        HTTPoisonMock
        |> expect(:request, fn :get, "https://example.com/api", "", [], _opts ->
          {:ok,
           %HTTPoison.Response{
             status_code: status_code,
             body: body,
             headers: headers
           }}
        end)

        request = %{
          method: :get,
          url: "https://example.com/api",
          query_params: %{}
        }

        config = [
          http_client_opts: [],
          json_codec: Jason,
          httpoison_module: HTTPoisonMock
        ]

        result = Httpoison.request(request, config)

        # Should return raw body for non-200, no JSON decoding attempted
        assert {:ok, %{status_code: ^status_code, body: ^body, headers: ^headers}} = result
      end
    end

    test "passes through all request parameters correctly" do
      HTTPoisonMock
      |> expect(:request, fn method, url, body, headers, opts ->
        # Verify all parameters are passed correctly
        assert method == :post
        assert url == "https://api.example.com/geocode"
        assert body == ""
        assert headers == [{"Authorization", "Bearer token123"}]

        assert [:with_body, :timeout] ++
                 [ibrowse: [headers_as_is: true], params: %{q: "New York"}] == opts

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: ~s({"results": []}),
           headers: [{"content-type", "application/json"}]
         }}
      end)

      request = %{
        method: :post,
        url: "https://api.example.com/geocode",
        query_params: %{q: "New York"},
        headers: [{"Authorization", "Bearer token123"}]
      }

      config = [
        http_client_opts: [:timeout],
        json_codec: Jason,
        httpoison_module: HTTPoisonMock
      ]

      result = Httpoison.request(request, config)

      assert {:ok, %{status_code: 200, body: %{"results" => []}, headers: _}} = result
    end
  end
end
