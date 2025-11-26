const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');

const app = express();
const PORT = 3000;
const FILE = './registros.json';

app.use(cors());
app.use(bodyParser.json());

let registros = [];

// 🔹 Cargar registros desde archivo al iniciar
function cargarDesdeArchivo() {
  if (fs.existsSync(FILE)) {
    registros = JSON.parse(fs.readFileSync(FILE));
  }
}

// 🔹 Guardar registros en archivo cada vez que se modifican
function guardarEnArchivo() {
  fs.writeFileSync(FILE, JSON.stringify(registros, null, 2));
}

cargarDesdeArchivo();

// 🔹 Redirección desde la raíz hacia /registros
app.get('/', (req, res) => {
  res.redirect('/registros');
});

// GET
app.get('/registros', (req, res) => res.json(registros));

// POST con validación y duplicados
app.post('/registros', (req, res) => {
  const { placa, nombrePropietario } = req.body;

  // Validación mínima
  if (!placa || !nombrePropietario) {
    return res.status(400).json({ mensaje: 'Datos incompletos' });
  }

  // Evitar duplicados por placa
  if (registros.some(r => r.placa === placa)) {
    return res.status(409).json({ mensaje: 'Placa ya registrada' });
  }

  registros.push(req.body);
  guardarEnArchivo();
  res.status(201).json(req.body);
});

// PUT
app.put('/registros/:placa', (req, res) => {
  const { placa } = req.params;
  const index = registros.findIndex(r => r.placa === placa);

  if (index !== -1) {
    registros[index] = { ...registros[index], ...req.body };
    guardarEnArchivo();
    res.json(registros[index]);
  } else {
    res.status(404).json({ mensaje: 'Registro no encontrado' });
  }
});

// DELETE
app.delete('/registros/:placa', (req, res) => {
  const { placa } = req.params;
  registros = registros.filter(r => r.placa !== placa);
  guardarEnArchivo();
  res.json({ mensaje: 'Registro eliminado' });
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});