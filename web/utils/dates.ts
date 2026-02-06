import {
  format,
  startOfMonth,
  endOfMonth,
  startOfYear,
  endOfYear,
  subMonths,
  addMonths,
  isToday,
  isYesterday,
  parseISO,
  getDaysInMonth,
  setDate,
} from 'date-fns'
import { fr } from 'date-fns/locale'

export function formatDate(date: string | Date, pattern = 'dd MMM yyyy'): string {
  const d = typeof date === 'string' ? parseISO(date) : date
  return format(d, pattern, { locale: fr })
}

export function formatRelativeDate(date: string | Date): string {
  const d = typeof date === 'string' ? parseISO(date) : date
  if (isToday(d)) return "Aujourd'hui"
  if (isYesterday(d)) return 'Hier'
  return format(d, 'dd MMM yyyy', { locale: fr })
}

export function formatMonthYear(date: Date): string {
  return format(date, 'MMMM yyyy', { locale: fr })
}

export function getMonthRange(date: Date): { start: Date; end: Date } {
  return { start: startOfMonth(date), end: endOfMonth(date) }
}

export function getYearRange(date: Date): { start: Date; end: Date } {
  return { start: startOfYear(date), end: endOfYear(date) }
}

export function getPreviousMonth(date: Date): Date {
  return subMonths(date, 1)
}

export function getNextMonth(date: Date): Date {
  return addMonths(date, 1)
}

export function clampDayToMonth(day: number, date: Date): Date {
  const maxDay = getDaysInMonth(date)
  const clampedDay = Math.min(day, maxDay)
  return setDate(date, clampedDay)
}

export function toISODateString(date: Date): string {
  return format(date, 'yyyy-MM-dd')
}

export { parseISO, startOfMonth, endOfMonth, startOfYear, endOfYear }
