defmodule MillasLanpass.Repo do
  use Ecto.Repo,
    otp_app: :millas_lanpass,
    adapter: Ecto.Adapters.SQLite3
end
