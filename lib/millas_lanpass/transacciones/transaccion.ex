defmodule MillasLanpass.Transacciones.Transaccion do
  use Ecto.Schema
  import Ecto.Changeset

  @tipos_validos ["ACUMULACION", "REDENCION"]
  @tipos_vuelo_validos ["nacional", "internacional"]
  @clases_validas ["basic", "full"]

  schema "transacciones" do
    field :tipo, :string
    field :millas, :integer
    field :saldo, :integer
    field :descripcion, :string

    # Campos opcionales para vuelos
    field :precio, :integer
    field :impuestos, :integer
    field :tipo_vuelo, :string
    field :tipo_clase, :string

    # Relación con usuario
    belongs_to :usuario, MillasLanpass.Usuarios.Usuario

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaccion, atributos) do
    transaccion
    |> cast(atributos, [
      :tipo, :millas, :saldo, :descripcion, :precio, :impuestos,
      :tipo_vuelo, :tipo_clase, :usuario_id
    ])
    |> validate_required([:tipo, :millas, :saldo, :descripcion, :usuario_id])
    |> validate_inclusion(:tipo, @tipos_validos)
    |> validate_inclusion(:tipo_vuelo, @tipos_vuelo_validos)
    |> validate_inclusion(:tipo_clase, @clases_validas)
    |> foreign_key_constraint(:usuario_id)
    |> validate_saldo_consistency()
  end

  # Changeset específico para acumulación
  def acumulacion_changeset(transaccion, atributos) do
    transaccion
    |> changeset(atributos)
    |> put_change(:tipo, "ACUMULACION")
    |> validate_required([:precio, :impuestos, :tipo_vuelo, :tipo_clase])
    |> validate_number(:precio, greater_than: 0)
    |> validate_number(:impuestos, greater_than_or_equal_to: 0)
    |> validate_number(:millas, greater_than: 0, message: "debe ser positivo para acumulación")
  end

  # Changeset específico para redención
  def redencion_changeset(transaccion, atributos) do
    transaccion
    |> changeset(atributos)
    |> put_change(:tipo, "REDENCION")
    |> put_change(:precio, nil)
    |> put_change(:impuestos, nil)
    |> put_change(:tipo_vuelo, nil)
    |> put_change(:tipo_clase, nil)
    |> validate_number(:millas, greater_than: 0, message: "no puede ser cero")
  end

  # Validación personalizada: el saldo debe ser consistente
  defp validate_saldo_consistency(changeset) do
    validate_change(changeset, :saldo, fn :saldo, saldo ->
      if saldo < 0 do
        [saldo: "no puede ser negativo"]
      else
        []
      end
    end)
  end
end
