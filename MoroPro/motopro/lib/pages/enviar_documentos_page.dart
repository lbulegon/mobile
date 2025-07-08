import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motopro/services/session_manager.dart';
import 'package:motopro/utils/app_config.dart';

class EnviarDocumentosPage extends StatefulWidget {
  const EnviarDocumentosPage({super.key});

  @override
  State<EnviarDocumentosPage> createState() => _EnviarDocumentosPageState();
}

class _EnviarDocumentosPageState extends State<EnviarDocumentosPage> {
  File? selectedFile;
  bool isUploading = false;

  Future<void> selecionarArquivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> enviarArquivo() async {
    if (selectedFile == null) return;

    setState(() {
      isUploading = true;
    });

    final token = await SessionManager.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.baseUrl}/motoboy/upload-documento/'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.files.add(
      await http.MultipartFile.fromPath('documento', selectedFile!.path),
    );

    final response = await request.send();

    setState(() {
      isUploading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento enviado com sucesso!')),
      );
      setState(() {
        selectedFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no envio: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Documentos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Selecione e envie uma foto ou documento (CNH, CPF, etc.)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            selectedFile != null
                ? Image.file(
                    selectedFile!,
                    height: 200,
                  )
                : const Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: double.infinity,
                  ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: selecionarArquivo,
              icon: const Icon(Icons.upload_file),
              label: const Text('Selecionar Documento'),
            ),
            const SizedBox(height: 16),
            isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: selectedFile != null ? enviarArquivo : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('Enviar Documento'),
                  ),
          ],
        ),
      ),
    );
  }
}
