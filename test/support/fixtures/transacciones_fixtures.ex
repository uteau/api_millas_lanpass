defmodule MillasLanpass.TransaccionesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MillasLanpass.Transacciones` context.
  """

  @doc """
  Generate a transaccion.
  """
  def transaccion_fixture(attrs \\ %{}) do
    {:ok, transaccion} =
      attrs
      |> Enum.into(%{
        descripcion: "some descripcion",
        impuestos: 42,
        millas: 42,
        precio: 42,
        saldo: 42,
        tipo: "some tipo",
        tipo_clase: "some tipo_clase",
        tipo_vuelo: "some tipo_vuelo"
      })
      |> MillasLanpass.Transacciones.create_transaccion()

    transaccion
  end
end
