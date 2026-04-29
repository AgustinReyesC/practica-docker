const express = require("express");
const Database = require("better-sqlite3");
const path = require("path");

const app = express();
const db = new Database("/app/datos/agenda.db");

// Crear tabla si no existe
db.exec(`
  CREATE TABLE IF NOT EXISTS contactos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    telefono TEXT NOT NULL,
    email TEXT
  )
`);

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// GET - listar todos los contactos
app.get("/api/contactos", (req, res) => {
  const contactos = db.prepare("SELECT * FROM contactos ORDER BY nombre").all();
  res.json(contactos);
});

// POST - agregar contacto
app.post("/api/contactos", (req, res) => {
  const { nombre, telefono, email } = req.body;
  if (!nombre || !telefono) {
    return res.status(400).json({ error: "Nombre y teléfono son obligatorios" });
  }
  const result = db
    .prepare("INSERT INTO contactos (nombre, telefono, email) VALUES (?, ?, ?)")
    .run(nombre, telefono, email || "");
  res.json({ id: result.lastInsertRowid, nombre, telefono, email: email || "" });
});

// DELETE - eliminar contacto
app.delete("/api/contactos/:id", (req, res) => {
  db.prepare("DELETE FROM contactos WHERE id = ?").run(req.params.id);
  res.json({ ok: true });
});

app.listen(3000, () => console.log("Agenda corriendo en http://localhost:3000"));
