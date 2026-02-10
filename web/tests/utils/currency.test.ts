import { describe, it, expect } from 'vitest'
import { formatCurrency, formatAmount, parseCurrencyInput } from '~/utils/currency'

describe('formatCurrency', () => {
  it('formate un montant en EUR par défaut', () => {
    const result = formatCurrency(1234.56)
    // Intl peut utiliser des espaces insécables, on normalise
    const normalized = result.replace(/\s/g, ' ')
    expect(normalized).toContain('1')
    expect(normalized).toContain('234')
    expect(normalized).toContain('56')
    expect(normalized).toContain('€')
  })

  it('formate un montant négatif', () => {
    const result = formatCurrency(-50)
    const normalized = result.replace(/\s/g, ' ')
    expect(normalized).toContain('50')
    expect(normalized).toContain('€')
  })

  it('formate zéro', () => {
    const result = formatCurrency(0)
    const normalized = result.replace(/\s/g, ' ')
    expect(normalized).toContain('0')
    expect(normalized).toContain('€')
  })

  it('utilise une devise personnalisée', () => {
    const result = formatCurrency(100, 'USD')
    const normalized = result.replace(/\s/g, ' ')
    expect(normalized).toContain('100')
    expect(normalized).toContain('$')
  })
})

describe('formatAmount', () => {
  it('formate un montant sans symbole de devise', () => {
    const result = formatAmount(1234.56)
    const normalized = result.replace(/\s/g, ' ')
    expect(normalized).toContain('1')
    expect(normalized).toContain('234')
    expect(normalized).toContain('56')
    expect(normalized).not.toContain('€')
  })
})

describe('parseCurrencyInput', () => {
  it('parse un montant avec virgule', () => {
    expect(parseCurrencyInput('12,50')).toBe(12.5)
  })

  it('parse un montant avec point', () => {
    expect(parseCurrencyInput('12.50')).toBe(12.5)
  })

  it('retourne 0 pour une chaîne invalide', () => {
    expect(parseCurrencyInput('abc')).toBe(0)
  })

  it('retourne 0 pour une chaîne vide', () => {
    expect(parseCurrencyInput('')).toBe(0)
  })

  it('supprime les caractères non numériques', () => {
    expect(parseCurrencyInput('€ 1 234,56')).toBe(1234.56)
  })

  it('arrondit à 2 décimales', () => {
    expect(parseCurrencyInput('10.999')).toBe(11)
  })
})
