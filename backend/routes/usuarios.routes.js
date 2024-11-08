router.get('/:userId/role', async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(
      'SELECT role FROM Users WHERE id = $1',
      [userId]
    );
    res.json({ role: result.rows[0]?.role || 'user' });
  } catch (err) {
    res.status(500).json({ message: "Error al obtener rol de usuario" });
  }
}); 