import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cashback/helpers/helper.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({Key? key}) : super(key: key);

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
      controller.resumeCamera();
      controller.scannedDataStream.listen((scanData) async {
        Get.back(result: scanData);
        setState(() {
          // result = scanData;
        });
      });
    });
  }

  flash() async {
    await controller?.toggleFlash();
    setState(() {});
  }

  switchCamera() async {
    await controller?.flipCamera();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: QRView(
            key: qrKey,
            onQRViewCreated: onQRViewCreated,
            overlay: QrScannerOverlayShape(
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
              borderWidth: 10,
              borderRadius: 10,
              borderColor: purple,
            ),
          ),
        ),
        // Positioned(
        //   top: 100,
        //   right: MediaQuery.of(context).size.width * 0.4,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(8),
        //       color: Colors.white.withOpacity(0.5),
        //     ),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.max,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         Container(
        //           margin: EdgeInsets.only(right: 10),
        //           child: GestureDetector(
        //             onTap: () {
        //               flash();
        //             },
        //             child: Icon(
        //               Icons.flash_off,
        //               color: Colors.white,
        //             ),
        //           ),
        //         ),
        //         GestureDetector(
        //           onTap: () {
        //             switchCamera();
        //           },
        //           child: Icon(
        //             Icons.switch_camera,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
