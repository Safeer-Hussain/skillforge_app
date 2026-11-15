import 'dart:io';
import 'dart:typed_data';

// Pure Dart PNG generator using uncompressed Deflate blocks
class PngBuilder {
  final int width;
  final int height;
  late final Uint8List rawRgba;

  PngBuilder(this.width, this.height) {
    rawRgba = Uint8List(width * height * 4);
  }

  void setPixel(int x, int y, int r, int g, int b, int a) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    final index = (y * width + x) * 4;
    rawRgba[index] = r;
    rawRgba[index + 1] = g;
    rawRgba[index + 2] = b;
    rawRgba[index + 3] = a;
  }

  void fill(int r, int g, int b, int a) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        setPixel(x, y, r, g, b, a);
      }
    }
  }

  void drawRect(int x1, int y1, int x2, int y2, int r, int g, int b, int a) {
    for (int y = y1; y <= y2; y++) {
      for (int x = x1; x <= x2; x++) {
        setPixel(x, y, r, g, b, a);
      }
    }
  }

  void drawCircle(int cx, int cy, int radius, int r, int g, int b, int a) {
    final r2 = radius * radius;
    for (int y = cy - radius; y <= cy + radius; y++) {
      for (int x = cx - radius; x <= cx + radius; x++) {
        final d2 = (x - cx) * (x - cx) + (y - cy) * (y - cy);
        if (d2 <= r2) {
          setPixel(x, y, r, g, b, a);
        }
      }
    }
  }

  void drawLine(
    int x0,
    int y0,
    int x1,
    int y1,
    int thickness,
    int r,
    int g,
    int b,
    int a,
  ) {
    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    int curX = x0;
    int curY = y0;
    while (true) {
      drawCircle(curX, curY, thickness, r, g, b, a);
      if (curX == x1 && curY == y1) break;
      int e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        curX += sx;
      }
      if (e2 < dx) {
        err += dx;
        curY += sy;
      }
    }
  }

  Uint8List encode() {
    final scanlineLength = 1 + width * 4;
    final rawScanlines = Uint8List(scanlineLength * height);

    for (int y = 0; y < height; y++) {
      final lineStart = y * scanlineLength;
      rawScanlines[lineStart] = 0; // Filter type 0 (None)
      for (int x = 0; x < width; x++) {
        final srcIdx = (y * width + x) * 4;
        final dstIdx = lineStart + 1 + x * 4;
        rawScanlines[dstIdx] = rawRgba[srcIdx];
        rawScanlines[dstIdx + 1] = rawRgba[srcIdx + 1];
        rawScanlines[dstIdx + 2] = rawRgba[srcIdx + 2];
        rawScanlines[dstIdx + 3] = rawRgba[srcIdx + 3];
      }
    }

    final idatBytes = _deflateStore(rawScanlines);

    final out = BytesBuilder();
    // Signature
    out.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

    // IHDR
    final ihdrData = ByteData(13);
    ihdrData.setUint32(0, width, Endian.big);
    ihdrData.setUint32(4, height, Endian.big);
    ihdrData.setUint8(8, 8); // bit depth
    ihdrData.setUint8(9, 6); // color type (RGBA)
    ihdrData.setUint8(10, 0); // compression
    ihdrData.setUint8(11, 0); // filter
    ihdrData.setUint8(12, 0); // interlace
    _writeChunk(out, 'IHDR', ihdrData.buffer.asUint8List());

    // IDAT
    _writeChunk(out, 'IDAT', idatBytes);

    // IEND
    _writeChunk(out, 'IEND', Uint8List(0));

    return out.toBytes();
  }

  Uint8List _deflateStore(Uint8List data) {
    final out = BytesBuilder();
    // Zlib header (CMF=0x78, FLG=0x01)
    out.addByte(0x78);
    out.addByte(0x01);

    const maxBlock = 65535;
    int offset = 0;
    while (offset < data.length) {
      final remaining = data.length - offset;
      final chunkSize = remaining > maxBlock ? maxBlock : remaining;
      final isLast = (offset + chunkSize) >= data.length;

      out.addByte(isLast ? 0x01 : 0x00);
      out.addByte(chunkSize & 0xFF);
      out.addByte((chunkSize >> 8) & 0xFF);
      final nlen = (~chunkSize) & 0xFFFF;
      out.addByte(nlen & 0xFF);
      out.addByte((nlen >> 8) & 0xFF);

      out.add(data.sublist(offset, offset + chunkSize));
      offset += chunkSize;
    }

    // Adler-32
    int s1 = 1;
    int s2 = 0;
    for (int i = 0; i < data.length; i++) {
      s1 = (s1 + data[i]) % 65521;
      s2 = (s2 + s1) % 65521;
    }
    final adler = (s2 << 16) | s1;
    final adlerData = ByteData(4)..setUint32(0, adler, Endian.big);
    out.add(adlerData.buffer.asUint8List());

    return out.toBytes();
  }

  void _writeChunk(BytesBuilder out, String type, Uint8List data) {
    final lenData = ByteData(4)..setUint32(0, data.length, Endian.big);
    out.add(lenData.buffer.asUint8List());

    final typeBytes = type.codeUnits;
    out.add(typeBytes);
    out.add(data);

    final crc = _crc32(typeBytes, data);
    final crcData = ByteData(4)..setUint32(0, crc, Endian.big);
    out.add(crcData.buffer.asUint8List());
  }

  int _crc32(List<int> type, Uint8List data) {
    int crc = 0xFFFFFFFF;
    for (final b in type) {
      crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >>> 8);
    }
    for (final b in data) {
      crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >>> 8);
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  static final List<int> _crcTable = () {
    final table = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      int c = i;
      for (int k = 0; k < 8; k++) {
        if ((c & 1) != 0) {
          c = 0xEDB88320 ^ (c >>> 1);
        } else {
          c = c >>> 1;
        }
      }
      table[i] = c;
    }
    return table;
  }();
}

void main() {
  Directory('assets/icons').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);

  // 1. App Icon: 256x256 (Obsidian background, emerald-gold spark, anvil/prism geometric, binary syntax chevron)
  final icon = PngBuilder(256, 256);
  icon.fill(16, 20, 24, 255); // Dark obsidian

  // Outer subtle glow
  icon.drawCircle(128, 128, 110, 24, 32, 40, 255);

  // Forged geometric prism base
  icon.drawLine(64, 180, 192, 180, 8, 16, 185, 129, 255); // Emerald base
  icon.drawLine(64, 180, 96, 120, 6, 16, 185, 129, 255);
  icon.drawLine(192, 180, 160, 120, 6, 16, 185, 129, 255);
  icon.drawLine(96, 120, 160, 120, 6, 52, 211, 153, 255);

  // Binary syntax chevrons < / >
  icon.drawLine(110, 85, 85, 105, 5, 245, 158, 11, 255); // Amber chevron
  icon.drawLine(85, 105, 110, 125, 5, 245, 158, 11, 255);

  icon.drawLine(146, 85, 171, 105, 5, 245, 158, 11, 255);
  icon.drawLine(171, 105, 146, 125, 5, 245, 158, 11, 255);

  // Center spark / prism crystal
  icon.drawCircle(128, 105, 14, 251, 191, 36, 255); // Gold spark
  icon.drawCircle(128, 105, 7, 255, 255, 255, 255); // Core brilliant spark

  File('assets/icons/app_icon.png').writeAsBytesSync(icon.encode());

  // 2. Track Renders
  final tracks = [
    {'name': 'track_flutter', 'r': 14, 'g': 165, 'b': 233},
    {'name': 'track_distributed', 'r': 99, 'g': 102, 'b': 241},
    {'name': 'track_ai', 'r': 168, 'g': 85, 'b': 247},
    {'name': 'track_system_design', 'r': 245, 'g': 158, 'b': 11},
    {'name': 'track_security', 'r': 239, 'g': 68, 'b': 68},
  ];

  for (final t in tracks) {
    final img = PngBuilder(200, 120);
    img.fill(20, 24, 30, 255);
    final r = t['r'] as int;
    final g = t['g'] as int;
    final b = t['b'] as int;

    // Geometric grid lines
    img.drawLine(20, 100, 180, 100, 2, r, g, b, 200);
    img.drawLine(40, 30, 100, 70, 3, r, g, b, 255);
    img.drawLine(100, 70, 160, 40, 3, r, g, b, 255);
    img.drawCircle(40, 30, 8, r, g, b, 255);
    img.drawCircle(100, 70, 10, 255, 255, 255, 255);
    img.drawCircle(160, 40, 8, r, g, b, 255);

    File('assets/images/${t['name']}.png').writeAsBytesSync(img.encode());
  }

  // 3. Certificate Seal
  final seal = PngBuilder(160, 160);
  seal.fill(24, 28, 36, 255);
  seal.drawCircle(80, 80, 65, 245, 158, 11, 255);
  seal.drawCircle(80, 80, 55, 16, 20, 24, 255);
  seal.drawCircle(80, 80, 45, 245, 158, 11, 200);
  seal.drawCircle(80, 80, 35, 16, 185, 129, 255);
  seal.drawCircle(80, 80, 15, 255, 255, 255, 255);
  File('assets/images/certificate_seal.png').writeAsBytesSync(seal.encode());

  // 4. Mentor Avatar
  final mentor = PngBuilder(160, 160);
  mentor.fill(18, 22, 28, 255);
  mentor.drawCircle(80, 80, 68, 59, 130, 246, 255);
  mentor.drawCircle(80, 80, 62, 16, 20, 26, 255);
  mentor.drawCircle(80, 65, 28, 96, 165, 250, 255);
  mentor.drawCircle(80, 130, 40, 59, 130, 246, 255);
  File('assets/images/mentor_avatar.png').writeAsBytesSync(mentor.encode());

  print('Generated all assets successfully.');
}
