import 'dart:convert';

import 'package:file/src/interface/file.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver.dart';
import 'package:path/path.dart' as path;
// import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      timeout: const Duration(seconds: 60 * 10),
      responseDataCallback: (Map<String, dynamic>? data) async {
        if (data != null) {
          final String? platform = data["platform"] as String?;
          final String? width = data["width"] as String?;
          final String? height = data["height"] as String?;

          for (final String key in data.keys) {
            if (["platform", "width", "height"].contains(key)) {
              continue;
            }

            final String base64EncodedImage = data[key] as String;

            // create directory:
            String dir = "$_destinationDirectory/$platform/$width-$height";
            await fs.directory(dir).create(recursive: true);
            
            // write to disk:
            final File file = fs.file(
              path.join(
                dir,
                // _destinationDirectory,
                "$key.png",
              ),
            );
            await file.writeAsBytes(base64Decode(base64EncodedImage));
          }
        }
      },
    );
  } catch (error) {
    print('Error occured during integration test: $error');
  }
}

const String _destinationDirectory = "screenshots";
