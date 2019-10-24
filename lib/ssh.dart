// Copyright 2019 dartssh developers
// Use of this source code is governed by a MIT-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:pointycastle/src/utils.dart';

import 'package:dartssh/protocol.dart';
import 'package:dartssh/serializable.dart';

typedef NameFunction = String Function(int);
typedef SupportedFunction = bool Function(int);

String buildPreferenceCsv(
    NameFunction name, SupportedFunction supported, int end,
    [int startAfter = 0]) {
  String ret = '';
  for (int i = 1 + startAfter; i <= end; i++) {
    if (supported(i)) ret += (ret.isEmpty ? '' : ',') + name(i);
  }
  return ret;
}

String preferenceIntersection(String intersectCsv, String supportedCsv) {
  Set<String> supported = Set<String>.of(supportedCsv.split(','));
  for (String intersect in intersectCsv.split(',')) {
    if (supported.contains(intersect)) return intersect;
  }
  return '';
}

class Key {
  static const int ED25519 = 1,
      ECDSA_SHA2_NISTP256 = 2,
      ECDSA_SHA2_NISTP384 = 3,
      ECDSA_SHA2_NISTP521 = 4,
      RSA = 5,
      DSS = 6,
      End = 6;

  static int id(String name) {
    switch (name) {
      case 'ssh-rsa':
        return RSA;
      case 'ssh-dss':
        return DSS;
      case 'ecdsa-sha2-nistp256':
        return ECDSA_SHA2_NISTP256;
      case 'ecdsa-sha2-nistp384':
        return ECDSA_SHA2_NISTP384;
      case 'ecdsa-sha2-nistp521':
        return ECDSA_SHA2_NISTP521;
      case 'ssh-ed25519':
        return ED25519;
      default:
        return 0;
    }
  }

  static String name(int id) {
    switch (id) {
      case RSA:
        return 'ssh-rsa';
      case DSS:
        return 'ssh-dss';
      case ECDSA_SHA2_NISTP256:
        return 'ecdsa-sha2-nistp256';
      case ECDSA_SHA2_NISTP384:
        return 'ecdsa-sha2-nistp384';
      case ECDSA_SHA2_NISTP521:
        return 'ecdsa-sha2-nistp521';
      case ED25519:
        return 'ssh-ed25519';
      default:
        return '';
    }
  }

  static bool supported(int id) => true;

  static bool ellipticCurveDSA(int id) =>
      id == ECDSA_SHA2_NISTP256 ||
      id == ECDSA_SHA2_NISTP384 ||
      id == ECDSA_SHA2_NISTP521;

  static String preferenceCsv([int startAfter = 0]) =>
      buildPreferenceCsv(name, supported, End, startAfter);

  static int preferenceIntersect(String intersectCsv, [int startAfter = 0]) =>
      id(preferenceIntersection(preferenceCsv(startAfter), intersectCsv));
}

class KEX {
  static const int ECDH_SHA2_X25519 = 1,
      ECDH_SHA2_NISTP256 = 2,
      ECDH_SHA2_NISTP384 = 3,
      ECDH_SHA2_NISTP521 = 4,
      DHGEX_SHA256 = 5,
      DHGEX_SHA1 = 6,
      DH14_SHA1 = 7,
      DH1_SHA1 = 8,
      End = 8;

  static int id(String name) {
    switch (name) {
      case 'curve25519-sha256@libssh.org':
        return ECDH_SHA2_X25519;
      case 'ecdh-sha2-nistp256':
        return ECDH_SHA2_NISTP256;
      case 'ecdh-sha2-nistp384':
        return ECDH_SHA2_NISTP384;
      case 'ecdh-sha2-nistp521':
        return ECDH_SHA2_NISTP521;
      case 'diffie-hellman-group-exchange-sha256':
        return DHGEX_SHA256;
      case 'diffie-hellman-group-exchange-sha1':
        return DHGEX_SHA1;
      case 'diffie-hellman-group14-sha1':
        return DH14_SHA1;
      case 'diffie-hellman-group1-sha1':
        return DH1_SHA1;
      default:
        return 0;
    }
  }

  static String name(int id) {
    switch (id) {
      case ECDH_SHA2_X25519:
        return 'curve25519-sha256@libssh.org';
      case ECDH_SHA2_NISTP256:
        return 'ecdh-sha2-nistp256';
      case ECDH_SHA2_NISTP384:
        return 'ecdh-sha2-nistp384';
      case ECDH_SHA2_NISTP521:
        return 'ecdh-sha2-nistp521';
      case DHGEX_SHA256:
        return 'diffie-hellman-group-exchange-sha256';
      case DHGEX_SHA1:
        return 'diffie-hellman-group-exchange-sha1';
      case DH14_SHA1:
        return 'diffie-hellman-group14-sha1';
      case DH1_SHA1:
        return 'diffie-hellman-group1-sha1';
      default:
        return '';
    }
  }

  static bool supported(int id) => true;

  static bool X25519DiffieHellman(int id) => id == ECDH_SHA2_X25519;

  static bool EllipticCurveDiffieHellman(int id) =>
      id == ECDH_SHA2_NISTP256 ||
      id == ECDH_SHA2_NISTP384 ||
      id == ECDH_SHA2_NISTP521;

  static bool DiffieHellmanGroupExchange(int id) =>
      id == DHGEX_SHA256 || id == DHGEX_SHA1;

  static bool DiffieHellman(int id) =>
      id == DHGEX_SHA256 ||
      id == DHGEX_SHA1 ||
      id == DH14_SHA1 ||
      id == DH1_SHA1;

  static String preferenceCsv([int startAfter = 0]) =>
      buildPreferenceCsv(name, supported, End, startAfter);

  static int preferenceIntersect(String intersectCsv, [int startAfter = 0]) =>
      id(preferenceIntersection(preferenceCsv(startAfter), intersectCsv));
}

class Cipher {
  static const int AES128_CTR = 1,
      AES128_CBC = 2,
      TripDES_CBC = 3,
      Blowfish_CBC = 4,
      RC4 = 5,
      End = 5;

  static int id(String name) {
    switch (name) {
      case 'aes128-ctr':
        return AES128_CTR;
      case 'aes128-cbc':
        return AES128_CBC;
      case '3des-cbc':
        return TripDES_CBC;
      case 'blowfish-cbc':
        return Blowfish_CBC;
      case 'arcfour':
        return RC4;
      default:
        return 0;
    }
  }

  static String name(int id) {
    switch (id) {
      case AES128_CTR:
        return 'aes128-ctr';
      case AES128_CBC:
        return 'aes128-cbc';
      case TripDES_CBC:
        return '3des-cbc';
      case Blowfish_CBC:
        return 'blowfish-cbc';
      case RC4:
        return 'arcfour';
      default:
        return '';
    }
  }

  static bool supported(int id) => true;

  static String preferenceCsv([int startAfter = 0]) =>
      buildPreferenceCsv(name, supported, End, startAfter);

  static int preferenceIntersect(String intersectCsv, [int startAfter = 0]) =>
      id(preferenceIntersection(preferenceCsv(startAfter), intersectCsv));

  //static Crypto::CipherAlgo Algo(int id, int *blocksize=0);
}

class MAC {
  static const int MD5 = 1,
      SHA1 = 2,
      SHA1_96 = 3,
      MD5_96 = 4,
      SHA256 = 5,
      SHA256_96 = 6,
      SHA512 = 7,
      SHA512_96 = 8,
      End = 8;

  static int id(String name) {
    switch (name) {
      case 'hmac-md5':
        return MD5;
      case 'hmac-md5-96':
        return MD5_96;
      case 'hmac-sha1':
        return SHA1;
      case 'hmac-sha1-96':
        return SHA1_96;
      case 'hmac-sha2-256':
        return SHA256;
      case 'hmac-sha2-256-96':
        return SHA256_96;
      case 'hmac-sha2-512':
        return SHA512;
      case 'hmac-sha2-512-96':
        return SHA512_96;
      default:
        return 0;
    }
  }

  static String name(int id) {
    switch (id) {
      case MD5:
        return 'hmac-md5';
      case MD5_96:
        return 'hmac-md5-96';
      case SHA1:
        return 'hmac-sha1';
      case SHA1_96:
        return 'hmac-sha1-96';
      case SHA256:
        return 'hmac-sha2-256';
      case SHA256_96:
        return 'hmac-sha2-256-96';
      case SHA512:
        return 'hmac-sha2-512';
      case SHA512_96:
        return 'hmac-sha2-512-96';
      default:
        return '';
    }
  }

  static bool supported(int id) => true;

  static String preferenceCsv([int startAfter = 0]) =>
      buildPreferenceCsv(name, supported, End, startAfter);

  static int preferenceIntersect(String intersectCsv, [int startAfter = 0]) =>
      id(preferenceIntersection(preferenceCsv(startAfter), intersectCsv));

  //static Crypto::MACAlgo Algo(int id, int *prefix_bytes=0);
}

class Compression {
  static const int OpenSSHZLib = 1, None = 2, End = 2;

  static int id(String name) {
    switch (name) {
      case 'zlib@openssh.com':
        return OpenSSHZLib;
      case 'none':
        return None;
      default:
        return 0;
    }
  }

  static String name(int id) {
    switch (id) {
      case OpenSSHZLib:
        return 'zlib@openssh.com';
      case None:
        return 'none';
      default:
        return '';
    }
  }

  static bool supported(int id) => true;

  static String preferenceCsv([int startAfter = 0]) =>
      buildPreferenceCsv(name, supported, End, startAfter);

  static int preferenceIntersect(String intersectCsv, [int startAfter = 0]) =>
      id(preferenceIntersection(preferenceCsv(startAfter), intersectCsv));
}

class DSSKey with Serializable {
  String formatId = 'ssh-dss';
  BigInt p, q, g, y;
  DSSKey(this.p, this.q, this.g, this.y);

  @override
  int get serializedHeaderSize => 5 * 4;

  @override
  int get serializedSize =>
      serializedHeaderSize +
      formatId.length +
      mpIntLength(p) +
      mpIntLength(q) +
      mpIntLength(g) +
      mpIntLength(y);

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    if (formatId != 'ssh-dss') throw FormatException(formatId);
    p = deserializeMpInt(input);
    q = deserializeMpInt(input);
    g = deserializeMpInt(input);
    y = deserializeMpInt(input);
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    serializeMpInt(output, p);
    serializeMpInt(output, q);
    serializeMpInt(output, g);
    serializeMpInt(output, y);
  }
}

class DSSSignature with Serializable {
  String formatId = 'ssh-dss';
  BigInt r, s;
  DSSSignature(this.r, this.s);

  @override
  int get serializedHeaderSize => 4 * 2 + 7 + 20 * 2;

  @override
  int get serializedSize => serializedHeaderSize;

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    Uint8List blob = deserializeStringBytes(input);
    if (formatId != 'ssh-dss' || blob.length != 40) {
      throw FormatException('$formatId ${blob.length}');
    }
    r = decodeBigInt(Uint8List.view(blob.buffer, 0, 20));
    s = decodeBigInt(Uint8List.view(blob.buffer, 20, 20));
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    Uint8List rBytes = encodeBigInt(r);
    Uint8List sBytes = encodeBigInt(s);
    assert(rBytes.length == 20);
    assert(sBytes.length == 20);
    serializeString(output, Uint8List.fromList(rBytes + sBytes));
  }
}

class RSAKey with Serializable {
  String formatId = 'ssh-rsa';
  BigInt e, n;
  RSAKey(this.e, this.n);

  @override
  int get serializedHeaderSize => 3 * 4;

  @override
  int get serializedSize =>
      serializedHeaderSize + formatId.length + mpIntLength(e) + mpIntLength(n);

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    if (formatId != Key.name(Key.RSA)) throw FormatException(formatId);
    e = deserializeMpInt(input);
    n = deserializeMpInt(input);
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    serializeMpInt(output, e);
    serializeMpInt(output, n);
  }
}

class RSASignature with Serializable {
  String formatId = 'ssh-rsa';
  Uint8List sig;
  RSASignature(this.sig);

  @override
  int get serializedHeaderSize => 4 * 2 + 7;

  @override
  int get serializedSize => serializedHeaderSize + sig.length;

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    sig = deserializeStringBytes(input);
    if (formatId != 'ssh-rsa') throw FormatException(formatId);
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    serializeString(output, sig);
  }
}

class ECDSAKey with Serializable {
  String formatId, curveId;
  Uint8List q;
  ECDSAKey(this.formatId, this.curveId, this.q);

  @override
  int get serializedHeaderSize => 3 * 4;

  @override
  int get serializedSize =>
      serializedHeaderSize + formatId.length + curveId.length + q.length;

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    if (!formatId.startsWith('ecdsa-sha2-')) throw FormatException(formatId);
    curveId = deserializeString(input);
    q = deserializeStringBytes(input);
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    serializeString(output, curveId);
    serializeString(output, q);
  }
}

class ECDSASignature with Serializable {
  String formatId;
  BigInt r, s;
  ECDSASignature(this.formatId, this.r, this.s);

  @override
  int get serializedHeaderSize => 4 * 4;

  @override
  int get serializedSize =>
      serializedHeaderSize + formatId.length + mpIntLength(r) + mpIntLength(s);

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    Uint8List blob = deserializeStringBytes(input);
    if (!formatId.startsWith('ecdsa-sha2-')) throw FormatException(formatId);
    SerializableInput blobInput = SerializableInput(blob);
    r = deserializeMpInt(blobInput);
    s = deserializeMpInt(blobInput);
    if (!blobInput.done) throw FormatException('${blobInput.offset}');
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    Uint8List blob = Uint8List(4 * 2 + mpIntLength(r) + mpIntLength(s));
    SerializableOutput blobOutput = SerializableOutput(blob);
    serializeMpInt(blobOutput, r);
    serializeMpInt(blobOutput, s);
    if (!blobOutput.done) throw FormatException('${blobOutput.offset}');
    serializeString(output, blob);
  }
}

class Ed25519Key with Serializable {
  String formatId = 'ssh-ed25519';
  Uint8List key;
  Ed25519Key(this.key);

  @override
  int get serializedHeaderSize => 4 * 2 + 11;

  @override
  int get serializedSize => serializedHeaderSize + key.length;

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    key = deserializeStringBytes(input);
    if (formatId != 'ssh-ed25519') throw FormatException(formatId);
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    serializeString(output, key);
  }
}

class Ed25519Signature with Serializable {
  String formatId = 'ssh-ed25519';
  Uint8List sig;
  Ed25519Signature(this.sig);

  @override
  int get serializedHeaderSize => 4 * 2 + 11;

  @override
  int get serializedSize => serializedHeaderSize + sig.length;

  @override
  void deserialize(SerializableInput input) {
    formatId = deserializeString(input);
    sig = deserializeStringBytes(input);
    if (formatId != 'ssh-ed25519') throw FormatException(formatId);
  }

  @override
  void serialize(SerializableOutput output) {
    serializeString(output, formatId);
    serializeString(output, sig);
  }
}
