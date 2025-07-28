import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:typed_data';

class DownloadPdfScreen extends StatefulWidget {
  const DownloadPdfScreen({super.key});

  @override
  State<DownloadPdfScreen> createState() => _DownloadPdfScreenState();
}

class _DownloadPdfScreenState extends State<DownloadPdfScreen> {
  bool isDownloading = false;
  String downloadStatus = '';

  // Lista de PDFs disponibles en assets
  final List<Map<String, String>> availablePDFs = [
    {
      'title': 'Diccionario Tzeltal',
      'asset': 'assets/pdfs/zai.pdf',
      'filename': 'diccionario_tseltal.pdf',
      'description': 'Diccionario completo del idioma Tseltal',
      'size': '2.5 MB'
    },
    {
      'title': 'Abecedario Zapoteco',
      'asset': 'assets/pdfs/guia-abecedario-zapotecos.pdf',
      'filename': 'guia-abecedarios-zapotecos.pdf',
      'description': 'Abecedario y pronunciación del idioma Zapoteco',
      'size': '1.8 MB'
    },
    {
      'title': 'Guia Numeros Tzeltal',
      'asset': 'assets/pdfs/guia-numeros-tzeltal.pdf',
      'filename': 'guia-numeros-tzeltal.pdf',
      'description': 'Aprende numeros en tzeltal',
      'size': '3.2 MB'
    },
    {
      'title': 'Guia Numeros Zapoteco',
      'asset': 'assets/pdfs/guia-numeros-zapotecos.pdf',
      'filename': 'guia-numeros-zapotecos.pdf',
      'description': 'Aprende numeros en zapoteco',
      'size': '3.2 MB'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Descargar Recursos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFD4A574),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con información
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recursos Disponibles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Descarga los materiales de estudio para acceder sin conexión',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Status de descarga
          if (downloadStatus.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: downloadStatus.contains('Error') 
                    ? Colors.red[50] 
                    : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: downloadStatus.contains('Error') 
                      ? Colors.red[300]! 
                      : Colors.green[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    downloadStatus.contains('Error') 
                        ? Icons.error_outline 
                        : Icons.check_circle_outline,
                    color: downloadStatus.contains('Error') 
                        ? Colors.red[600] 
                        : Colors.green[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      downloadStatus,
                      style: TextStyle(
                        color: downloadStatus.contains('Error') 
                            ? Colors.red[700] 
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Lista de PDFs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: availablePDFs.length,
              itemBuilder: (context, index) {
                final pdf = availablePDFs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: isDownloading
                          ? null
                          : () => _downloadPDFFromAssets(
                              pdf['asset']!,
                              pdf['filename']!,
                              pdf['title']!,
                            ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icono del PDF
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red[600],
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Información del PDF
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pdf['title']!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pdf['description']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.storage,
                                        size: 16,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        pdf['size']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Botón de descarga
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDownloading 
                                    ? Colors.grey[100] 
                                    : const Color(0xFFD4A574).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isDownloading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFD4A574),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.download,
                                      color: const Color(0xFFD4A574),
                                      size: 24,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer informativo
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Los archivos se guardan en tu carpeta de Descargas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDFFromAssets(
    String assetPath,
    String fileName,
    String title,
  ) async {
    setState(() {
      isDownloading = true;
      downloadStatus = 'Preparando descarga de "$title"...';
    });

    try {
      // 1. Solicitar permisos
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        setState(() {
          downloadStatus = 'Error: Se necesitan permisos de almacenamiento para continuar';
          isDownloading = false;
        });
        return;
      }

      setState(() {
        downloadStatus = 'Cargando "$title" desde la aplicación...';
      });

      // 2. Cargar PDF desde assets
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      setState(() {
        downloadStatus = 'Guardando "$title" en el dispositivo...';
      });

      // 3. Obtener directorio de descargas
      String downloadsPath = await _getDownloadsDirectory();

      // 4. Crear archivo en descargas
      final File file = File('$downloadsPath/$fileName');
      await file.writeAsBytes(bytes);

      setState(() {
        downloadStatus = '✅ "$title" descargado exitosamente';
        isDownloading = false;
      });

      // Mostrar snackbar de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('$title descargado correctamente'),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // Limpiar mensaje después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            downloadStatus = '';
          });
        }
      });

    } catch (e) {
      setState(() {
        downloadStatus = 'Error al descargar "$title": ${e.toString()}';
        isDownloading = false;
      });
      
      // Mostrar snackbar de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error al descargar $title'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      
      print('Error en descarga: $e');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Verificar versión de Android
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      
      if (androidInfo.version.sdkInt >= 30) {
        // Android 11+ (API 30+)
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          // Mostrar dialog explicativo antes de solicitar permiso
          bool shouldRequest = await _showPermissionDialog();
          if (shouldRequest) {
            status = await Permission.manageExternalStorage.request();
          }
        }
        return status.isGranted;
      } else {
        // Android 10 y anteriores
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          bool shouldRequest = await _showPermissionDialog();
          if (shouldRequest) {
            status = await Permission.storage.request();
          }
        }
        return status.isGranted;
      }
    }
    return true; // iOS no requiere permisos especiales para esto
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.folder, color: Color(0xFFD4A574)),
              SizedBox(width: 12),
              Text('Permiso Requerido'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para descargar los archivos PDF necesitamos acceso al almacenamiento de tu dispositivo.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Esto nos permitirá:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Guardar los PDFs en tu carpeta de Descargas'),
              Text('• Permitir que accedas a ellos desde otras apps'),
              SizedBox(height: 12),
              Text(
                'Tus archivos estarán seguros y solo se usarán para esta función.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.white,
              ),
              child: const Text('Conceder Permiso'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<String> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Para Android, acceder a la carpeta Downloads pública
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Navegar desde /storage/emulated/0/Android/data/... 
        // hasta /storage/emulated/0/Download
        List<String> paths = directory.path.split('/');
        String newPath = '';
        for (int i = 1; i < paths.length; i++) {
          if (paths[i] != 'Android') {
            newPath += '/' + paths[i];
          } else {
            break;
          }
        }
        newPath += '/Download';
        
        // Crear directorio si no existe
        Directory downloadsDir = Directory(newPath);
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        
        return newPath;
      }
    }
    
    // Fallback: usar directorio de documentos de la app
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFD4A574)),
              SizedBox(width: 12),
              Text('Información'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acerca de las descargas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Los archivos se guardan en tu carpeta de Descargas'),
              Text('• Podrás acceder a ellos desde cualquier aplicación'),
              Text('• Una vez descargados, no necesitas internet'),
              Text('• Los archivos ocupan espacio en tu dispositivo'),
              SizedBox(height: 12),
              Text(
                'Nota: Se requieren permisos de almacenamiento para descargar los archivos.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Color(0xFFD4A574)),
              ),
            ),
          ],
        );
      },
    );
  }
}