# priv/repo/seeds.exs
alias MillasLanpass.{Repo, Usuarios, Transacciones}

IO.puts "Creando usuarios de prueba..."

# Limpiar datos existentes (opcional)
IO.puts "Limpiando datos existentes..."
Repo.delete_all(Transacciones.Transaccion)
Repo.delete_all(Usuarios.Usuario)

# Usuario 1: Bruno (para pruebas principales)
{:ok, usuario1} = Usuarios.create_usuario(%{
  nombre: "Bruno Guerra",
  email: "bruno@gmail.com",
  rut: "12345678-9",
  categoria: "LATAM",
  puntos_calificables: 0
})

# Usuario 2: Ana (categoría GOLD)
{:ok, usuario2} = Usuarios.create_usuario(%{
  nombre: "Jeremías Carrasco",
  email: "el.jere@gmail.com",
  rut: "23456789-0",
  categoria: "GOLD",
  puntos_calificables: 15000
})

# Usuario 3: Carlos (categoría PLATINUM)
{:ok, usuario3} = Usuarios.create_usuario(%{
  nombre: "Javier Arredondo",
  email: "javibnloko@gmail.com",
  rut: "34567890-1",
  categoria: "PLATINUM",
  puntos_calificables: 40000
})

# Usuario 4: María (categoría LATAM)
{:ok, usuario4} = Usuarios.create_usuario(%{
  nombre: "Camilo Castro",
  email: "el_ninja_maldit0@gmail.com",
  rut: "45678901-2",
  categoria: "LATAM",
  puntos_calificables: 5000
})

IO.puts "Usuarios creados exitosamente:"
IO.puts "   👤 #{usuario1.nombre} - #{usuario1.email} - #{usuario1.categoria}"
IO.puts "   👤 #{usuario2.nombre} - #{usuario2.email} - #{usuario2.categoria}"
IO.puts "   👤 #{usuario3.nombre} - #{usuario3.email} - #{usuario3.categoria}"
IO.puts "   👤 #{usuario4.nombre} - #{usuario4.email} - #{usuario4.categoria}"

# Opcional: Crear algunas transacciones de ejemplo
IO.puts "Creando transacciones de ejemplo..."

# Acumulación para Bruno
Transacciones.acumular_millas(%{
  "usuario_id" => usuario1.id,
  "precio" => "900",
  "impuestos" => "100",
  "tipo_vuelo" => "internacional",
  "tipo_clase" => "full"
})

# Acumulación para Jere
Transacciones.acumular_millas(%{
  "usuario_id" => usuario2.id,
  "precio" => "1200",
  "impuestos" => "150",
  "tipo_vuelo" => "internacional",
  "tipo_clase" => "full"
})

IO.puts "Transacciones de ejemplo creadas"
IO.puts "Semilla completada! 4 usuarios listos para pruebas."
