defmodule Pyexq.TokenHandler do
  @moduledoc """
  A singleton process that stores oauth tokens and handles requesting new ones.
  """
  use GenServer.Behaviour

  @token_url "https://accounts.google.com/o/oauth2/token"
  @grant_type "urn:ietf:params:oauth:grant-type:jwt-bearer"

  ##
  # Public API
  ##
  def start_link() do
    :gen_server.start_link({:local, :token_handler}, __MODULE__, [], [])
  end

  def get_token() do
    :gen_server.call(:token_handler, :get_token)
  end
  
  ##
  # GenServer methods
  ##
  def init(_) do
    {:ok, nil}
  end

  def handle_call(:get_token, _from, nil) do
    {token, expiry} = state = request_token()
    { :reply, token, state }
  end

  def handle_call(:get_token, from, state = {token, expiry}) do
    cond do
      has_expired(expiry) -> handle_call(:get_token, from, nil)
      true -> { :reply, token, state }
    end
  end

  @client_id ""
  @scope "https://www.googleapis.com/auth/taskqueue.consumer"
  @duration_secs 60 * 60

  ##
  # Private Helpers
  ##
  defp request_token() do
    request = [{ :grant_type, @grant_type },
               { :assertion, build_jwt() }] |> URI.encode_query

    case do_fetch(request) do
      {:ok, body} -> 
        {:ok, data} = JSON.decode(body)
        {megasecs, secs, millisecs} = :os.timestamp()
        expiry = Dict.get(data, "expires_in")
        {Dict.get(data, "access_token"), {megasecs, secs+expiry, millisecs}}

      {:error, body} -> throw "Could not get token: #{body}"
    end
  end

  def build_jwt() do
    {:ok, python_pid} = :python.start()
    params = [@client_id, @scope, @duration_secs]
    signed_jwt = :python.call(python_pid, :auth, :get_signed_jwt, params)
    :python.stop(python_pid)
    signed_jwt
  end

  defp do_fetch(request) do
    alias HTTPotion.Response
    HTTPotion.start

    headers = [{'Content-Type', 'application/x-www-form-urlencoded'}]

    case HTTPotion.post(@token_url, request, headers) do
      Response[body: body, status_code: status, headers: _headers ]
      when status in 200..299 ->
        {:ok, body}
      Response[body: body, status_code: status, headers: _headers ] ->
        {error: body}
    end
  end

  defp has_expired(expiry) do
    expiry <= :os.timestamp()
  end

end
