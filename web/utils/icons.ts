import * as LucideIcons from 'lucide-vue-next'
import type { Component } from 'vue'

/**
 * Retourne le composant Lucide correspondant au nom kebab-case.
 * Ex: "credit-card" → CreditCard
 */
export function getLucideIcon(name: string): Component {
  const key = name.split('-').map(w => w[0].toUpperCase() + w.slice(1)).join('')
  return ((LucideIcons as Record<string, unknown>)[key] as Component) ?? LucideIcons.Ellipsis
}

export const DEFAULT_ICON_KEY = 'ellipsis'
