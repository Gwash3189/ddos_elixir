defmodule Ddos.Worker do
  use Timex
  alias HTTPoison.Response
  require Logger

  def start(url, get \\ &HTTPoison.get/1) do
    log()
    {timestamp, response} = Duration.measure(fn -> get.(url) end)
    handle_response({Duration.to_milliseconds(timestamp), response})
  end

  defp log do
    case Node.list do
      [] -> nil
      _ -> IO.puts "Running on #node-#{node()}"
    end
  end

  defp handle_response({msecs, {:ok, %Response{status_code: code}}}) do
    case code >= 200 and code <= 304 do
      true ->
        Logger.info "worker [#{node()}-#{inspect self()}] completed in #{msecs} msecs"
      _ -> nil
    end
  end

  defp handle_response({_msecs, {:error, reason}}) do
     Logger.info "worker [#{node()}-#{inspect self()}] error due to #{inspect reason}"
    {:error, reason}
  end

  defp handle_response({_msecs, _}) do
     Logger.info "worker [#{node()}-#{inspect self()}] errored out"
    {:error, :unknown}
  end
end
