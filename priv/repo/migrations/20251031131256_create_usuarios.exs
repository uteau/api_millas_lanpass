defmodule MillasLanpass.Repo.Migrations.CreateUsuarios do
  use Ecto.Migration

  def change do
    create table(:usuarios) do
      add :nombre, :string, null: false
      add :email, :string, null: false
      add :rut, :string, null: false
      add :categoria, :string, null: false, default: "LATAM"
      add :puntos_calificables, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:usuarios, [:email])
    create unique_index(:usuarios, [:rut])
  end
end
