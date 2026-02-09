/**
 * Utilitaires cryptographiques — Web Crypto API.
 *
 * Chiffrement AES-256-GCM de bout en bout.
 * Compatible avec le format mobile (nonce 12 bytes + ciphertext+tag).
 */

const PBKDF2_ITERATIONS = 100_000
const SALT_LENGTH = 32
const DEK_LENGTH = 32
const IV_LENGTH = 12

function toBase64(buffer: Uint8Array): string {
  let binary = ''
  for (let i = 0; i < buffer.length; i++) {
    binary += String.fromCharCode(buffer[i])
  }
  return btoa(binary)
}

function fromBase64(base64: string): Uint8Array {
  const binary = atob(base64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes
}

export function generateSalt(): Uint8Array {
  return crypto.getRandomValues(new Uint8Array(SALT_LENGTH))
}

export function generateDEK(): Uint8Array {
  return crypto.getRandomValues(new Uint8Array(DEK_LENGTH))
}

export async function deriveKEK(masterPassword: string, salt: Uint8Array): Promise<CryptoKey> {
  const encoder = new TextEncoder()
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(masterPassword),
    'PBKDF2',
    false,
    ['deriveBits', 'deriveKey'],
  )

  return crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: salt as BufferSource,
      iterations: PBKDF2_ITERATIONS,
      hash: 'SHA-256',
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt'],
  )
}

export async function encrypt(plaintext: Uint8Array, key: CryptoKey): Promise<Uint8Array> {
  const iv = crypto.getRandomValues(new Uint8Array(IV_LENGTH))
  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    key,
    plaintext as BufferSource,
  )

  // Format: IV (12 bytes) + ciphertext+tag
  const result = new Uint8Array(IV_LENGTH + ciphertext.byteLength)
  result.set(iv, 0)
  result.set(new Uint8Array(ciphertext), IV_LENGTH)
  return result
}

export async function decrypt(data: Uint8Array, key: CryptoKey): Promise<Uint8Array> {
  const iv = data.slice(0, IV_LENGTH)
  const ciphertext = data.slice(IV_LENGTH)

  const plaintext = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv },
    key,
    ciphertext,
  )

  return new Uint8Array(plaintext)
}

export async function encryptString(plaintext: string, key: CryptoKey): Promise<string> {
  const encoder = new TextEncoder()
  const encrypted = await encrypt(encoder.encode(plaintext), key)
  return toBase64(encrypted)
}

export async function decryptString(ciphertext: string, key: CryptoKey): Promise<string> {
  const data = fromBase64(ciphertext)
  const decrypted = await decrypt(data, key)
  return new TextDecoder().decode(decrypted)
}

async function importRawKey(rawKey: Uint8Array): Promise<CryptoKey> {
  return crypto.subtle.importKey(
    'raw',
    rawKey as BufferSource,
    { name: 'AES-GCM', length: 256 },
    true,
    ['encrypt', 'decrypt'],
  )
}

export async function encryptDEK(dek: Uint8Array, kek: CryptoKey): Promise<string> {
  const encrypted = await encrypt(dek, kek)
  return toBase64(encrypted)
}

export async function decryptDEK(encryptedDEK: string, kek: CryptoKey): Promise<Uint8Array> {
  const data = fromBase64(encryptedDEK)
  return decrypt(data, kek)
}

export function encodeSalt(salt: Uint8Array): string {
  return toBase64(salt)
}

export function decodeSalt(saltBase64: string): Uint8Array {
  return fromBase64(saltBase64)
}

export { importRawKey }
