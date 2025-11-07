defmodule MillasLanpass.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MillasLanpassWeb.Telemetry,
      MillasLanpass.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:millas_lanpass, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:millas_lanpass, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MillasLanpass.PubSub},
      # Start a worker by calling: MillasLanpass.Worker.start_link(arg)
      # {MillasLanpass.Worker, arg},
      # Start to serve requests, typically the last entry
      MillasLanpassWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MillasLanpass.Supervisor]
    #Supervisor.start_link(children, opts)
    case Supervisor.start_link(children, opts) do
      {:ok, _pid} = result ->
        seed_database()
        result

      other ->
        other
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MillasLanpassWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end

  defp seed_database do
    # Pequeña pausa para asegurar que el Repo esté listo
    :timer.sleep(500)

    # Verificar si ya hay usuarios para no ejecutar semillas múltiples veces
    case MillasLanpass.Repo.all(MillasLanpass.Usuarios.Usuario) do
      [] ->
        IO.puts "🌱 Ejecutando semillas automáticamente..."
        Mix.Task.run("run", ["priv/repo/seeds.exs"])
        IO.puts "✅ Semillas ejecutadas correctamente!"
      _ ->
        IO.puts "✅ Base de datos ya tiene datos, omitiendo semillas."
        #Mix.Task.run("run", ["priv/repo/seeds.exs"])
    end
  rescue
    error ->
      IO.puts "⚠️  Error ejecutando semillas: #{inspect(error)}"
      IO.puts "💡 Ejecuta manualmente: mix run priv/repo/seeds.exs"
  end
end
