defmodule MillasLanpassWeb.UsuarioController do
  use MillasLanpassWeb, :controller

  alias MillasLanpass.Usuarios
  alias MillasLanpass.Usuarios.Usuario
  alias MillasLanpass.Transacciones  # ← Agregar este alias

  action_fallback MillasLanpassWeb.FallbackController

  # ====================== CUSTOM ======================

  # POST /api/usuarios
  def create(conn, %{"usuario" => parametros_usuario}) do
    case Usuarios.create_usuario(parametros_usuario) do
      {:ok, %Usuario{} = usuario} ->
        json_response(conn, 201, %{
          data: %{
            id: usuario.id,
            nombre: usuario.nombre,
            email: usuario.email,
            rut: usuario.rut,
            categoria: usuario.categoria,
            puntos_calificables: usuario.puntos_calificables,
            inserted_at: usuario.inserted_at
          }
        })

      {:error, changeset} ->
        errors = transform_changeset_errors(changeset)
        json_response(conn, 422, %{errors: errors})
    end
  end

  # GET /api/usuarios/:usuario_id/estado
  def estado(conn, %{"usuario_id" => usuario_id}) do
    try do
      usuario = Usuarios.get_usuario!(usuario_id)
      saldo_actual = Transacciones.obtener_saldo_actual(usuario_id)

      json_response(conn, 200, %{
        usuario: %{
          id: usuario.id,
          nombre: usuario.nombre,
          email: usuario.email,
          categoria: usuario.categoria,
          puntos_calificables: usuario.puntos_calificables
        },
        millas: %{
          saldo_actual: saldo_actual
        }
      })
    rescue
      Ecto.NoResultsError ->
        json_response(conn, 404, %{error: "Usuario no encontrado"})
    end
  end

  # GET /api/usuarios
  def listar(conn, _params) do
    usuarios = Usuarios.listar_usuarios()

    usuarios_json = Enum.map(usuarios, fn usuario ->
      %{
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        categoria: usuario.categoria
      }
    end)

    json_response(conn, 200, %{data: usuarios_json})
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
    usuarios = Usuarios.listar_usuarios()

    usuarios_json = Enum.map(usuarios, fn usuario ->
      %{
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        categoria: usuario.categoria
      }
    end)

    json_response(conn, 200, %{data: usuarios_json})
  end

  # Editado
  def show(conn, %{"id" => id}) do
    try do
      usuario = Usuarios.get_usuario!(id)

      json_response(conn, 200, %{
        data: %{
          id: usuario.id,
          nombre: usuario.nombre,
          email: usuario.email,
          rut: usuario.rut,
          categoria: usuario.categoria,
          puntos_calificables: usuario.puntos_calificables,
          inserted_at: usuario.inserted_at
        }
      })
    rescue
      Ecto.NoResultsError ->
        json_response(conn, 404, %{error: "Usuario no encontrado"})
    end
  end

  def update(conn, %{"id" => id, "usuario" => usuario_params}) do
    usuario = Usuarios.get_usuario!(id)

    with {:ok, %Usuario{} = usuario} <- Usuarios.update_usuario(usuario, usuario_params) do
      render(conn, :show, usuario: usuario)
    end
  end

  def delete(conn, %{"id" => id}) do
    usuario = Usuarios.get_usuario!(id)

    with {:ok, %Usuario{}} <- Usuarios.delete_usuario(usuario) do
      send_resp(conn, :no_content, "")
    end
  end
end
