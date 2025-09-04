import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Verifica e solicita permissões de câmera
  static Future<bool> requestCameraPermission() async {
    print('📸 [CameraService] Solicitando permissão de câmera...');
    
    final status = await Permission.camera.request();
    print('📸 [CameraService] Status da permissão: $status');
    
    return status.isGranted;
  }
  
  /// Tira uma foto usando a câmera
  static Future<File?> takePhoto() async {
    print('📸 [CameraService] Iniciando captura de foto...');
    
    try {
      // Verifica permissão
      if (!await requestCameraPermission()) {
        print('❌ [CameraService] Permissão de câmera negada');
        return null;
      }
      
      print('📸 [CameraService] Capturando foto...');
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front, // Selfie
      );
      
      if (photo != null) {
        print('✅ [CameraService] Foto capturada: ${photo.path}');
        return File(photo.path);
      } else {
        print('❌ [CameraService] Nenhuma foto foi capturada');
        return null;
      }
    } catch (e) {
      print('❌ [CameraService] Erro ao capturar foto: $e');
      return null;
    }
  }
  
  /// Seleciona uma foto da galeria
  static Future<File?> pickFromGallery() async {
    print('📸 [CameraService] Selecionando foto da galeria...');
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        print('✅ [CameraService] Foto selecionada: ${image.path}');
        return File(image.path);
      } else {
        print('❌ [CameraService] Nenhuma foto foi selecionada');
        return null;
      }
    } catch (e) {
      print('❌ [CameraService] Erro ao selecionar foto: $e');
      return null;
    }
  }
  
  /// Salva a foto do avatar localmente
  static Future<String?> saveAvatarPhoto(File photoFile) async {
    print('💾 [CameraService] Salvando foto do avatar...');
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${directory.path}/avatars');
      
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
        print('📁 [CameraService] Diretório de avatares criado');
      }
      
      final avatarPath = '${avatarDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await photoFile.copy(avatarPath);
      
      print('✅ [CameraService] Avatar salvo em: $avatarPath');
      
      // Salva o caminho no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', avatarPath);
      
      return avatarPath;
    } catch (e) {
      print('❌ [CameraService] Erro ao salvar avatar: $e');
      return null;
    }
  }
  
  /// Carrega a foto do avatar salva
  static Future<String?> getAvatarPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('avatar_path');
    } catch (e) {
      print('❌ [CameraService] Erro ao carregar caminho do avatar: $e');
      return null;
    }
  }
  
  /// Remove a foto do avatar
  static Future<bool> removeAvatar() async {
    print('🗑️ [CameraService] Removendo avatar...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('avatar_path');
      print('✅ [CameraService] Avatar removido com sucesso');
      return true;
    } catch (e) {
      print('❌ [CameraService] Erro ao remover avatar: $e');
      return false;
    }
  }
}
