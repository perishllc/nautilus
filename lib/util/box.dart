/* TODO: rewrite the encryption / decryption in dart / flutter */

class Box {
  static const NONCE_LENGTH = 24;

  String encrypt(String message, String address, String privateKey) {
    // if (!message) {
    // 	throw new Error('No message to encrypt')
    // }

    // const publicKey = NanoAddress.addressToPublicKey(address)
    // const { privateKey: convertedPrivateKey, publicKey: convertedPublicKey } = new Ed25519().convertKeys({
    // 	privateKey,
    // 	publicKey,
    // })

    // const nonce = Convert.hex2ab(lib.WordArray.random(this.NONCE_LENGTH).toString())
    // const encrypted = new Curve25519().box(
    // 	Convert.decodeUTF8(message),
    // 	nonce,
    // 	Convert.hex2ab(convertedPublicKey),
    // 	Convert.hex2ab(convertedPrivateKey),
    // )

    // const full = new Uint8Array(nonce.length + encrypted.length)
    // full.set(nonce)
    // full.set(encrypted, nonce.length)

    // return base64.bytesToBase64(full)
  }

  String decrypt(String encrypted, String address, String privateKey) {
    // if (!encrypted) {
    //   throw new Error('No message to decrypt');
    // }

    // const publicKey = NanoAddress.addressToPublicKey(address)
    // const { privateKey: convertedPrivateKey, publicKey: convertedPublicKey } = new Ed25519().convertKeys({
    // 	privateKey,
    // 	publicKey,
    // })

    // const decodedEncryptedMessageBytes = base64.base64ToBytes(encrypted)
    // const nonce = decodedEncryptedMessageBytes.slice(0, this.NONCE_LENGTH)
    // const encryptedMessage = decodedEncryptedMessageBytes.slice(this.NONCE_LENGTH, encrypted.length)

    // const decrypted = new Curve25519().boxOpen(
    // 	encryptedMessage,
    // 	nonce,
    // 	Convert.hex2ab(convertedPublicKey),
    // 	Convert.hex2ab(convertedPrivateKey),
    // )

    // if (!decrypted) {
    // 	throw new Error('Could not decrypt message')
    // }

    // return Convert.encodeUTF8(decrypted)
  }

  String getJSLib() {
    return "";
  }
}
