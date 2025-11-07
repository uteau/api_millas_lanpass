defmodule MillasLanpass.UsuariosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MillasLanpass.Usuarios` context.
  """

  @doc """
  Generate a usuario.
  """
  def usuario_fixture(attrs \\ %{}) do
    {:ok, usuario} =
      attrs
      |> Enum.into(%{
        categoria: "some categoria",
        email: "some email",
        nombre: "some nombre",
        puntos_calificables: 42,
        rut: "some rut"
      })
      |> MillasLanpass.Usuarios.create_usuario()

    usuario
  end
end
