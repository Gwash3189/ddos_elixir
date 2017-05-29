defmodule Ddos.Caller do
  def start(n_workers, url) do
    worker_fun = fn -> Ddos.Worker.start(url) end
    1..n_workers
    |> Enum.map(fn _ -> Task.async(worker_fun) end)
    |> Enum.map(&Task.await(&1, :infinity))
  end
end
