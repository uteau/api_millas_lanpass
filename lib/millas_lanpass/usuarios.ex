defmodule MillasLanpass.Usuarios do
  @moduledoc """
  The Usuarios context.
  """

  import Ecto.Query, warn: false
  alias MillasLanpass.Repo

  alias MillasLanpass.Usuarios.Usuario

  @doc """
  Returns the list of usuarios.

  ## Examples

      iex> list_usuarios()
      [%Usuario{}, ...]

  """
  def listar_usuarios do
    Repo.all(Usuario)
  end

  @doc """
  Gets a single usuario.

  Raises `Ecto.NoResultsError` if the Usuario does not exist.

  ## Examples

      iex> get_usuario!(123)
      %Usuario{}

      iex> get_usuario!(456)
      ** (Ecto.NoResultsError)

  """

  def get_usuario!(id), do: Repo.get!(Usuario, id)
  @doc """
  Creates a usuario.

  ## Examples

      iex> create_usuario(%{field: value})
      {:ok, %Usuario{}}

      iex> create_usuario(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_usuario(attrs) do
    %Usuario{}
    |> Usuario.registration_changeset(attrs)
    |> Repo.insert()
  end

  # ====================== Funciones custom ======================

  # Obtener usuario por email
  def obtener_usuario_por_email(email) do
    Repo.get_by(Usuario, email: email)
  end

  # Actualizar puntos calificables
  def actualizar_puntos_calificables(usuario_id, nuevos_puntos) do
    usuario = get_usuario!(usuario_id)

    usuario
    |> Usuario.changeset(%{puntos_calificables: nuevos_puntos})
    |> Repo.update()
  end

  # Verificar y actualizar categoría si es necesario
  def verificar_actualizar_categoria(usuario_id) do
    usuario = get_usuario!(usuario_id)

    nueva_categoria = calcular_categoria(usuario.puntos_calificables)

    if nueva_categoria != usuario.categoria do
      usuario
      |> Usuario.changeset(%{categoria: nueva_categoria})
      |> Repo.update()
    else
      {:ok, usuario}
    end
  end

  defp calcular_categoria(puntos) do
    cond do
      puntos >= 200000 -> "BLACK_SIGNATURE"
      puntos >= 100000 -> "BLACK"
      puntos >= 35000 -> "PLATINUM"
      puntos >= 12000 -> "GOLD"
      true -> "LATAM"
    end
  end


  # ====================== NO las uso ======================
  @doc """
  Updates a usuario.

  ## Examples

      iex> update_usuario(usuario, %{field: new_value})
      {:ok, %Usuario{}}

      iex> update_usuario(usuario, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_usuario(%Usuario{} = usuario, attrs) do
    usuario
    |> Usuario.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a usuario.

  ## Examples

      iex> delete_usuario(usuario)
      {:ok, %Usuario{}}

      iex> delete_usuario(usuario)
      {:error, %Ecto.Changeset{}}

  """
  def delete_usuario(%Usuario{} = usuario) do
    Repo.delete(usuario)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking usuario changes.

  ## Examples

      iex> change_usuario(usuario)
      %Ecto.Changeset{data: %Usuario{}}

  """
  def change_usuario(%Usuario{} = usuario, attrs \\ %{}) do
    Usuario.changeset(usuario, attrs)
  end
end
