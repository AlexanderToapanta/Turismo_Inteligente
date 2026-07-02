import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import '../theme/tema_turismo.dart';

class UsuariosView extends StatefulWidget {
  const UsuariosView({super.key});

  @override
  State<UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<UsuariosView> {
  final UsuarioService _usuarioService = UsuarioService();
  late Future<List<UsuarioModel>> _futureUsuarios;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  void _cargarUsuarios() {
    setState(() {
      _futureUsuarios = _usuarioService.obtenerTodosLosUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UsuarioModel>>(
      future: _futureUsuarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final usuarios = snapshot.data ?? [];

        if (usuarios.isEmpty) {
          return const Center(child: Text('No hay usuarios registrados.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _cargarUsuarios(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: usuarios.length,
            itemBuilder: (context, i) => _UsuarioCard(
              usuario: usuarios[i],
              onRoleChanged: _cargarUsuarios,
            ),
          ),
        );
      },
    );
  }
}

class _UsuarioCard extends StatefulWidget {
  final UsuarioModel usuario;
  final VoidCallback onRoleChanged;

  const _UsuarioCard({required this.usuario, required this.onRoleChanged});

  @override
  State<_UsuarioCard> createState() => _UsuarioCardState();
}

class _UsuarioCardState extends State<_UsuarioCard> {
  final UsuarioService _usuarioService = UsuarioService();
  bool _cambiandoRol = false;
  bool _cambiandoEstado = false;

  Future<void> _cambiarRol(String nuevoRol) async {
    setState(() => _cambiandoRol = true);
    try {
      await _usuarioService.actualizarRolUsuario(widget.usuario.id, nuevoRol);
      widget.onRoleChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar rol: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cambiandoRol = false);
      }
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    setState(() => _cambiandoEstado = true);
    try {
      await _usuarioService.actualizarEstadoUsuario(widget.usuario.id, nuevoEstado);
      widget.onRoleChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cambiandoEstado = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = widget.usuario.rol == 'administrador';
    final esActivo = widget.usuario.estado == 'activo';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              esAdmin ? TemaPersona5.primaryColor : Colors.grey[800],
          child: Icon(esAdmin ? Icons.admin_panel_settings : Icons.person,
              color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(widget.usuario.nombre,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: esActivo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: esActivo ? Colors.green : Colors.red, width: 0.5),
              ),
              child: Text(
                esActivo ? 'ACTIVO' : 'BLOQUEADO',
                style: GoogleFonts.poppins(fontSize: 8, color: esActivo ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Text(widget.usuario.correo),
        trailing: (_cambiandoRol || _cambiandoEstado)
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) {
                  if (val == 'usuario' || val == 'administrador') {
                    if (val != widget.usuario.rol) {
                      _cambiarRol(val);
                    }
                  } else if (val == 'activar') {
                    _cambiarEstado('activo');
                  } else if (val == 'desactivar') {
                    _cambiarEstado('desactivado');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'usuario',
                    child: Text('Hacer Usuario'),
                  ),
                  const PopupMenuItem(
                    value: 'administrador',
                    child: Text('Hacer Administrador'),
                  ),
                  const PopupMenuDivider(),
                  if (!esActivo)
                    const PopupMenuItem(
                      value: 'activar',
                      child: Text('Activar Cuenta', style: TextStyle(color: Colors.green)),
                    ),
                  if (esActivo)
                    const PopupMenuItem(
                      value: 'desactivar',
                      child: Text('Desactivar Cuenta', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
      ),
    );
  }
}
