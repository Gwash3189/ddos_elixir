defmodule Ddos do
  require Logger

  def request(url, workers \\ 10) do
    case Node.list do
      [] -> Ddos.Caller.start(workers, url)
      nodes ->
        cluster = [node()] ++ nodes
        equal_workers = round(workers / Enum.count(cluster))
        :rpc.multicall(cluster, Ddos.Caller, :start, [equal_workers, url])
    end
  end
end
