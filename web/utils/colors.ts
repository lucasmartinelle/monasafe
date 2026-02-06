/** Palette de couleurs prédéfinies pour comptes et catégories */
export const COLOR_PALETTE: number[] = [
  0xFF1B5E5A, // Primary teal
  0xFF4A8B87, // Primary light
  0xFFE87B4D, // Accent orange
  0xFF4CAF50, // Green
  0xFFF44336, // Red
  0xFF2196F3, // Blue
  0xFF9C27B0, // Purple
  0xFFFF9800, // Orange
  0xFF00BCD4, // Cyan
  0xFF795548, // Brown
  0xFFFF5722, // Deep orange
  0xFF607D8B, // Blue grey
  0xFF3F51B5, // Indigo
  0xFFCDDC39, // Lime
  0xFFE91E63, // Pink
  0xFF009688, // Teal
  0xFF673AB7, // Deep purple
  0xFF8BC34A, // Light green
  0xFFFFC107, // Amber
  0xFF03A9F4, // Light blue
]

/**
 * Convertit un entier couleur (0xAARRGGBB) en string CSS hex (#RRGGBB)
 */
export function intToHex(colorInt: number): string {
  const hex = (colorInt & 0x00FFFFFF).toString(16).padStart(6, '0')
  return `#${hex}`
}

/**
 * Convertit un string CSS hex (#RRGGBB) en entier couleur (0xFFRRGGBB)
 */
export function hexToInt(hex: string): number {
  const clean = hex.replace('#', '')
  return 0xFF000000 + parseInt(clean, 16)
}

/**
 * Retourne le style CSS background-color pour un entier couleur
 */
export function colorStyle(colorInt: number): string {
  return intToHex(colorInt)
}

/**
 * Détermine si le texte doit être blanc ou noir sur un fond donné
 */
export function contrastTextColor(colorInt: number): string {
  const r = (colorInt >> 16) & 0xFF
  const g = (colorInt >> 8) & 0xFF
  const b = colorInt & 0xFF
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return luminance > 0.5 ? '#000000' : '#FFFFFF'
}
