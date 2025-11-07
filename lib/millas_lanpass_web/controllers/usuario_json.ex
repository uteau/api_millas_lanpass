defmodule MillasLanpassWeb.UsuarioJSON do
  alias MillasLanpass.Usuarios.Usuario

  @doc """
  Renders a list of usuarios.
  """
  def index(%{usuarios: usuarios}) do
    %{data: for(usuario <- usuarios, do: data(usuario))}
  end

  @doc """
  Renders a single usuario.
  """
  def show(%{usuario: usuario}) do
    %{data: data(usuario)}
  end

  defp data(%Usuario{} = usuario) do
    %{
      id: usuario.id,
      nombre: usuario.nombre,
      email: usuario.email,
      rut: usuario.rut,
      categoria: usuario.categoria,
      puntos_calificables: usuario.puntos_calificables
    }
  end
end
