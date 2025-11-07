defmodule MillasLanpassWeb.TransaccionController do
  use MillasLanpassWeb, :controller

  alias MillasLanpass.Transacciones
  alias MillasLanpass.Transacciones.Transaccion

  action_fallback MillasLanpassWeb.FallbackController

  # ====================== CUSTOM ======================

  # POST /api/transacciones/acumular
  def acumular(conn, %{"transaccion" => parametros}) do
    case Transacciones.acumular_millas(parametros) do
      {:ok, %Transaccion{} = transaccion} ->
        json_response(conn, 201, %{
          data: %{
            id: transaccion.id,
            tipo: transaccion.tipo,
            millas: transaccion.millas,
            saldo: transaccion.saldo,
            descripcion: transaccion.descripcion,
            usuario_id: transaccion.usuario_id,
            inserted_at: transaccion.inserted_at
          }
        })

      {:error, reason} when is_binary(reason) ->
        json_response(conn, 422, %{error: reason})

      {:error, changeset} ->
        errors = transform_changeset_errors(changeset)
        json_response(conn, 422, %{errors: errors})
    end
  end

  # POST /api/transacciones/canjear
  def canjear(conn, %{"transaccion" => parametros}) do
    case Transacciones.canjear_millas(parametros) do
      {:ok, %Transaccion{} = transaccion} ->
        json_response(conn, 201, %{
          data: %{
            id: transaccion.id,
            tipo: transaccion.tipo,
            millas: transaccion.millas,
            saldo: transaccion.saldo,
            descripcion: transaccion.descripcion,
            usuario_id: transaccion.usuario_id,
            inserted_at: transaccion.inserted_at
          }
        })

      {:error, reason} when is_binary(reason) ->
        json_response(conn, 422, %{error: reason})

      {:error, changeset} ->
        errors = transform_changeset_errors(changeset)
        json_response(conn, 422, %{errors: errors})
    end
  end

  # GET /api/usuarios/:usuario_id/transacciones
  def historial(conn, %{"usuario_id" => usuario_id}) do
    transacciones = Transacciones.listar_transacciones_usuario(usuario_id)

    transacciones_json = Enum.map(transacciones, fn transaccion ->
      %{
        id: transaccion.id,
        tipo: transaccion.tipo,
        millas: transaccion.millas,
        saldo: transaccion.saldo,
        descripcion: transaccion.descripcion,
        inserted_at: transaccion.inserted_at
      }
    end)

    json_response(conn, 200, %{data: transacciones_json})
  end

  # GET /api/transacciones/:id
  def mostrar(conn, %{"id" => id}) do
    try do
      transaccion = Transacciones.obtener_transaccion!(id)

      json_response(conn, 200, %{
        data: %{
          id: transaccion.id,
          tipo: transaccion.tipo,
          millas: transaccion.millas,
          saldo: transaccion.saldo,
          descripcion: transaccion.descripcion,
          precio: transaccion.precio,
          impuestos: transaccion.impuestos,
          tipo_vuelo: transaccion.tipo_vuelo,
          tipo_clase: transaccion.tipo_clase,
          usuario_id: transaccion.usuario_id,
          inserted_at: transaccion.inserted_at
        }
      })
    rescue
      Ecto.NoResultsError ->
        json_response(conn, 404, %{error: "Transacción no encontrada"})
    end
  end

  # ====================== UTILITY ======================

  defp json_response(conn, status, data) do
    conn
    |> put_status(status)
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(data))
  end

  defp transform_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  # ====================== DEFAULT ======================

  def index(conn, _params) do
    transacciones = Transacciones.list_transacciones()
    render(conn, :index, transacciones: transacciones)
  end

  def create(conn, %{"transaccion" => transaccion_params}) do
    with {:ok, %Transaccion{} = transaccion} <- Transacciones.create_transaccion(transaccion_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/transacciones/#{transaccion}")
      |> render(:show, transaccion: transaccion)
    end
  end

  def show(conn, %{"id" => id}) do
    transaccion = Transacciones.get_transaccion!(id)
    render(conn, :show, transaccion: transaccion)
  end

  def update(conn, %{"id" => id, "transaccion" => transaccion_params}) do
    transaccion = Transacciones.get_transaccion!(id)

    with {:ok, %Transaccion{} = transaccion} <- Transacciones.update_transaccion(transaccion, transaccion_params) do
      render(conn, :show, transaccion: transaccion)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaccion = Transacciones.get_transaccion!(id)

    with {:ok, %Transaccion{}} <- Transacciones.delete_transaccion(transaccion) do
      send_resp(conn, :no_content, "")
    end
  end
end
