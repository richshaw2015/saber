import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:saber/service/log/log.dart';

/// A widget that displays a page of a PDF document.
class PdfPageView extends StatefulWidget {
  const PdfPageView({
    required this.document,
    required this.pageNumber,
    this.maximumDpi = 300,
    this.alignment = Alignment.center,
    this.decoration,
    this.backgroundColor,
    super.key,
  });

  /// The PDF document.
  final PdfDocument document;

  /// The page number to be displayed. (The first page is 1).
  final int pageNumber;

  /// The maximum DPI of the page image. The default value is 300.
  ///
  /// The value is used to limit the actual image size to avoid excessive memory usage.
  final double maximumDpi;

  /// The alignment of the page image within the widget.
  final AlignmentGeometry alignment;

  /// The decoration of the page image.
  ///
  /// To disable the default drop-shadow, set [decoration] to `BoxDecoration(color: Colors.white)` or such.
  final Decoration? decoration;

  /// The background color of the page.
  final Color? backgroundColor;

  @override
  State<PdfPageView> createState() => _PdfPageViewState();
}

class _PdfPageViewState extends State<PdfPageView> {
  ui.Image? _image;
  Size? _pageSize;

  @override
  void initState() {
    super.initState();
  }

  /// 从 Uint8List 创建 ui.Image
  Future<ui.Image> createImageFromBytes(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    
    ui.decodeImageFromList(bytes, (ui.Image image) {
      if (!completer.isCompleted) {
        completer.complete(image);
      }
    });
    
    return completer.future;
  }

  /// 加载图片数据
  Future<void> loadImageFromBytes(Uint8List bytes) async {
    try {
      final ui.Image image = await createImageFromBytes(bytes);
      if (mounted) {
        setState(() {
          _image?.dispose(); // 释放旧图片内存
          _image = image;
        });
      }
    } catch (e) {
      Log.w('Failed to create image from bytes: $e');
    }
  }

  @override
  void dispose() {
    _image?.dispose();

    super.dispose();
  }

  Widget _defaultDecorationBuilder(BuildContext context, Size pageSize, RawImage? pageImage) {
    return Align(
      alignment: widget.alignment,
      child: AspectRatio(
        aspectRatio: pageSize.width / pageSize.height,
        child: Stack(
          children: [
            Container(
              decoration:
              widget.decoration ??
                  BoxDecoration(
                    color: pageImage == null ? widget.backgroundColor ?? Colors.white : Colors.transparent,
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
                  ),
            ),
            if (pageImage != null) pageImage,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final query = MediaQuery.of(context);
        _updateImage(constraints.biggest * query.devicePixelRatio);

        if (_pageSize != null) {
          final decorationBuilder = _defaultDecorationBuilder;
          final scale = min(constraints.maxWidth / _pageSize!.width, constraints.maxHeight / _pageSize!.height);
          return decorationBuilder(
            context,
            _pageSize!,
            _image != null
                ? RawImage(
              image: _image,
              width: _pageSize!.width * scale,
              height: _pageSize!.height * scale,
              fit: BoxFit.fill,
            )
                : null,
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> _updateImage(Size size) async {
    final document = widget.document;
    if (widget.pageNumber < 1 || widget.pageNumber > document.pagesCount || size.isEmpty) {
      return;
    }

    final page = await document.getPage(widget.pageNumber);

    final Size pageSize;

    final scale = min(widget.maximumDpi / 72, min(size.width / page.width, size.height / page.height));
    pageSize = Size(page.width * scale, page.height * scale);

    if (pageSize == _pageSize) return;
    _pageSize = pageSize;

    final pageImage = await page.render(
      width: pageSize.width,
      height: pageSize.height,
    );
    if (pageImage == null) return;

    loadImageFromBytes(pageImage.bytes);
  }
}
