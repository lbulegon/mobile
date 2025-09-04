import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';
import 'package:motopro/services/camera_service.dart';
import 'dart:io';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? _avatarPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('🏗️ [PerfilPage] initState chamado');
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    print('🔄 [PerfilPage] Carregando avatar...');
    final path = await CameraService.getAvatarPath();
    if (mounted) {
      setState(() {
        _avatarPath = path;
      });
      print('✅ [PerfilPage] Avatar carregado: $_avatarPath');
    }
  }

  Future<void> _showPhotoOptions() async {
    print('📸 [PerfilPage] Mostrando opções de foto...');
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolher foto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 30),
              title: const Text('Tirar Selfie'),
              onTap: () {
                Navigator.pop(context);
                _takeSelfie();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 30),
              title: const Text('Escolher da Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete, size: 30, color: Colors.red),
                title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _takeSelfie() async {
    print('📸 [PerfilPage] Iniciando selfie...');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final photo = await CameraService.takePhoto();
      
      if (photo != null) {
        print('✅ [PerfilPage] Selfie tirada com sucesso');
        final savedPath = await CameraService.saveAvatarPhoto(photo);
        
        if (savedPath != null) {
          setState(() {
            _avatarPath = savedPath;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selfie salva com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        print('❌ [PerfilPage] Falha ao tirar selfie');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível tirar a foto'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [PerfilPage] Erro ao tirar selfie: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao tirar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    print('📸 [PerfilPage] Selecionando da galeria...');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final photo = await CameraService.pickFromGallery();
      
      if (photo != null) {
        print('✅ [PerfilPage] Foto selecionada da galeria');
        final savedPath = await CameraService.saveAvatarPhoto(photo);
        
        if (savedPath != null) {
          setState(() {
            _avatarPath = savedPath;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto selecionada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        print('❌ [PerfilPage] Falha ao selecionar foto da galeria');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível selecionar a foto'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [PerfilPage] Erro ao selecionar foto da galeria: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeAvatar() async {
    print('🗑️ [PerfilPage] Removendo avatar...');
    
    final success = await CameraService.removeAvatar();
    
    if (success) {
      setState(() {
        _avatarPath = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao remover foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    print('🎨 [PerfilPage] Construindo interface...');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar com ação de câmera
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _avatarPath != null
                      ? FileImage(File(_avatarPath!))
                      : const AssetImage('assets/user_placeholder.png') as ImageProvider,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _showPhotoOptions,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Nome e e-mail
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    Text(
                      userProvider.nome ?? 'Nome do Usuário',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userProvider.email ?? 'usuario@email.com',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Card com opções
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Perfil'),
                    onTap: () {
                      // ✏️ Editar perfil
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Alterar Senha'),
                    onTap: () {
                      // 🔐 Alterar senha
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Enviar Documentos'),
                    onTap: () {
                      // 📎 Upload de documentos
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('🗑️ [PerfilPage] dispose chamado');
    super.dispose();
  }
}
