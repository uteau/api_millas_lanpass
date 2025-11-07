defmodule MillasLanpass.Transacciones do
  @moduledoc """
  The Transacciones context.
  """

  import Ecto.Query, warn: false
  alias MillasLanpass.Repo

  alias MillasLanpass.Transacciones.Transaccion
  alias MillasLanpass.Usuarios

  # ====================== CUSTOM ======================

  # Crear transacción de acumulación por vuelo

  def acumular_millas(parametros) do
    # Calcular millas basado en categoría y tipo de vuelo
    millas_calculadas = calcular_millas_por_vuelo(parametros)

    # Obtener saldo actual del usuario
    saldo_actual = obtener_saldo_actual(parametros["usuario_id"])
    nuevo_saldo = saldo_actual + millas_calculadas

    parametros_transaccion = Map.merge(parametros, %{
      "tipo" => "ACUMULACION",
      "millas" => millas_calculadas,
      "saldo" => nuevo_saldo,
      "descripcion" => "Acumulación por vuelo #{parametros["tipo_vuelo"]}"
    })

    %Transaccion{}
    |> Transaccion.acumulacion_changeset(parametros_transaccion)
    |> Repo.insert()
    |> after_insert()
  end

  # Crear transacción de redención
  def canjear_millas(parametros) do
    IO.puts "🔍 [DEBUG CANJEAR] Entra a la funcion"
    saldo_actual = obtener_saldo_actual(parametros["usuario_id"])
    millas_a_canjear = parametros["millas"]
    IO.puts "🔍 [DEBUG CANJEAR] Saldo actual: #{saldo_actual} - Millas a canjear: #{millas_a_canjear} "

    millas_a_canjear_int = String.to_integer(millas_a_canjear || "0")

    if saldo_actual >= millas_a_canjear_int do
      IO.puts "🔍 [DEBUG CANJEAR] Entra al bloque if saldo>=millas"
      nuevo_saldo = saldo_actual - millas_a_canjear_int

      parametros_transaccion = Map.merge(parametros, %{
        "tipo" => "REDENCION",
        "saldo" => nuevo_saldo,
        "descripcion" => "Canje: #{parametros["descripcion"]}"
      })

      %Transaccion{}
      |> Transaccion.redencion_changeset(parametros_transaccion)
      |> Repo.insert()
      |> after_insert()
    else
      IO.puts "🔍 [DEBUG CANJEAR] error en bloque if saldo>=millas"
      {:error, "Saldo insuficiente de millas"}
    end
  end

  # Obtener historial de usuario
  def listar_transacciones_usuario(usuario_id) do
    query = from t in Transaccion,
            where: t.usuario_id == ^usuario_id,
            order_by: [desc: t.inserted_at],
            preload: [:usuario]

    Repo.all(query)
  end

  # Obtener transacción por ID
  def obtener_transaccion!(id) do
    Repo.get!(Transaccion, id)
    |> Repo.preload(:usuario)
  end

  # Obtener saldo actual de usuario
  def obtener_saldo_actual(usuario_id) do
    query = from t in Transaccion,
            where: t.usuario_id == ^usuario_id,
            order_by: [desc: t.inserted_at],
            limit: 1,
            select: t.saldo

    case Repo.one(query) do
      nil -> 0
      saldo -> saldo
    end
  end

  # Calcular millas según categoría y tipo de vuelo
  defp calcular_millas_por_vuelo(parametros) do
    usuario = Usuarios.get_usuario!(parametros["usuario_id"])

    # string a int
    precio = String.to_integer(parametros["precio"] || "0")
    impuestos = String.to_integer(parametros["impuestos"] || "0")

    precio_base = precio - impuestos

    multiplicador = obtener_multiplicador(usuario.categoria, parametros["tipo_vuelo"])

    precio_base * multiplicador
  end

  defp obtener_multiplicador(categoria, tipo_vuelo) do
    case {categoria, tipo_vuelo} do
      {"LATAM", "nacional"} -> 3
      {"LATAM", "internacional"} -> 5
      {"GOLD", "nacional"} -> 4
      {"GOLD", "internacional"} -> 6
      {"PLATINUM", "nacional"} -> 7
      {"PLATINUM", "internacional"} -> 9
      {"BLACK", "nacional"} -> 8
      {"BLACK", "internacional"} -> 10
      {"BLACK_SIGNATURE", "nacional"} -> 9
      {"BLACK_SIGNATURE", "internacional"} -> 11
      _ -> 1 # Default
    end
  end

  # Callback después de insertar transacción
  defp after_insert({:ok, transaccion}) do
    # Actualizar puntos calificables si es acumulación
    if transaccion.tipo == "ACUMULACION" do
      usuario = Usuarios.get_usuario!(transaccion.usuario_id)
      nuevos_puntos = usuario.puntos_calificables + calcular_puntos_calificables(transaccion)

      Usuarios.actualizar_puntos_calificables(usuario.id, nuevos_puntos)
      Usuarios.verificar_actualizar_categoria(usuario.id)
    end

    {:ok, transaccion}
  end

  defp after_insert(error), do: error

  defp calcular_puntos_calificables(transaccion) do
    # Los puntos calificables son el precio base del vuelo
    trunc(transaccion.precio - transaccion.impuestos)
  end

  # ====================== DEFAULT ======================
  @doc """
  Returns the list of transacciones.

  ## Examples

      iex> list_transacciones()
      [%Transaccion{}, ...]

  """
  def list_transacciones do
    Repo.all(Transaccion)
  end

  @doc """
  Gets a single transaccion.

  Raises `Ecto.NoResultsError` if the Transaccion does not exist.

  ## Examples

      iex> get_transaccion!(123)
      %Transaccion{}

      iex> get_transaccion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaccion!(id), do: Repo.get!(Transaccion, id)

  @doc """
  Creates a transaccion.

  ## Examples

      iex> create_transaccion(%{field: value})
      {:ok, %Transaccion{}}

      iex> create_transaccion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaccion(attrs) do
    %Transaccion{}
    |> Transaccion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaccion.

  ## Examples

      iex> update_transaccion(transaccion, %{field: new_value})
      {:ok, %Transaccion{}}

      iex> update_transaccion(transaccion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaccion(%Transaccion{} = transaccion, attrs) do
    transaccion
    |> Transaccion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaccion.

  ## Examples

      iex> delete_transaccion(transaccion)
      {:ok, %Transaccion{}}

      iex> delete_transaccion(transaccion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaccion(%Transaccion{} = transaccion) do
    Repo.delete(transaccion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaccion changes.

  ## Examples

      iex> change_transaccion(transaccion)
      %Ecto.Changeset{data: %Transaccion{}}

  """
  def change_transaccion(%Transaccion{} = transaccion, attrs \\ %{}) do
    Transaccion.changeset(transaccion, attrs)
  end
end
