use blake2::{digest::Digest, Blake2b};
use curve25519_dalek::{
    constants::ED25519_BASEPOINT_TABLE,
    edwards::{CompressedEdwardsY},
    scalar::Scalar,
};
use rand::{rngs::OsRng, RngCore};

/// Takes as an input a public key. Returns the corresponding username
/// registration public key, or None if the input public key was invalid.
pub fn public_key_username_registration(namespace: String, public_key: [u8; 32]) -> Option<[u8; 32]> {
    let hash = Blake2b::digest(namespace.as_bytes()).into();
    let offset = &ED25519_BASEPOINT_TABLE * &Scalar::from_bytes_mod_order_wide(&hash);

    let mut point = CompressedEdwardsY(public_key).decompress()?;
    point += offset;
    Some(point.compress().to_bytes())
}

fn private_key_to_scalar(key: [u8; 32]) -> Scalar {
    let mut expanded: [u8; 64] = Blake2b::digest(key).into();
    expanded[0] &= 248;
    expanded[31] &= 63;
    expanded[31] |= 64;
    Scalar::from_bytes_mod_order(expanded[..32].try_into().unwrap())
}

/// Signs a given message with the given private key, returning the signature.
pub fn sign_as_username_registration(namespace: String, private_key: [u8; 32], message: Vec<u8>) -> [u8; 64] {

    let hash = Blake2b::digest(namespace.as_bytes()).into();
    let scalar_offset = Scalar::from_bytes_mod_order_wide(&hash);
    
    let mut key = private_key_to_scalar(private_key);
    // key += *USERNAME_REGISTRATION_SCALAR_OFFSET;
    key += scalar_offset;
    let pubkey = &ED25519_BASEPOINT_TABLE * &key;
    let mut nonce_entropy = [0u8; 64];
    OsRng.fill_bytes(&mut nonce_entropy);
    let nonce_scalar = Scalar::from_bytes_mod_order_wide(&nonce_entropy);
    let nonce_pub = (&ED25519_BASEPOINT_TABLE * &nonce_scalar)
        .compress()
        .to_bytes();
    let mut hram = Blake2b::new();
    hram.update(nonce_pub);
    hram.update(pubkey.compress().to_bytes());
    hram.update(&message);
    let hram = Scalar::from_bytes_mod_order_wide(&hram.finalize().into());
    let s = nonce_scalar + hram * key;
    let mut output_signature = [0u8; 64];
    output_signature[..32].copy_from_slice(&nonce_pub);
    output_signature[32..].copy_from_slice(s.as_bytes());
    output_signature
}
