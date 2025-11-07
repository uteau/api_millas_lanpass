defmodule MillasLanpassWeb.TransaccionJSON do
  alias MillasLanpass.Transacciones.Transaccion

  @doc """
  Renders a list of transacciones.
  """
  def index(%{transacciones: transacciones}) do
    %{data: for(transaccion <- transacciones, do: data(transaccion))}
  end

  @doc """
  Renders a single transaccion.
  """
  def show(%{transaccion: transaccion}) do
    %{data: data(transaccion)}
  end

  defp data(%Transaccion{} = transaccion) do
    %{
      id: transaccion.id,
      tipo: transaccion.tipo,
      millas: transaccion.millas,
      saldo: transaccion.saldo,
      descripcion: transaccion.descripcion,
      precio: transaccion.precio,
      impuestos: transaccion.impuestos,
      tipo_vuelo: transaccion.tipo_vuelo,
      tipo_clase: transaccion.tipo_clase
    }
  end
end
