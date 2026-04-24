import { DEFAULT_CATEGORIES } from '~/utils/defaultCategories'

/**
 * Migration des catégories globales (user_id IS NULL) vers le scope perso
 * de l'utilisateur. Exécutée une fois par utilisateur, idempotente via
 * un flag `categories_migrated` dans `user_settings`.
 *
 * Pour chaque catégorie globale référencée par les transactions /
 * récurrences / budgets de l'utilisateur, on crée une copie perso
 * et on re-pointe les références vers cette copie. Les défauts non
 * référencés sont remplacés par le set curaté DEFAULT_CATEGORIES.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  if (!user.value) return

  const isExcluded =
    to.path === '/' ||
    to.path.startsWith('/auth') ||
    to.path === '/terms' ||
    to.path === '/privacy' ||
    to.path.startsWith('/onboarding')

  if (isExcluded) return

  const migrationStatus = useState<Record<string, boolean>>('categories-migration-status', () => ({}))
  const uid = user.value.id

  if (migrationStatus.value[uid]) return

  const supabase = useSupabaseClient<any>()

  try {
    const { data: flagRow } = await supabase
      .from('user_settings')
      .select('value')
      .eq('user_id', uid)
      .eq('key', 'categories_migrated')
      .maybeSingle() as { data: { value: string } | null }

    if (flagRow?.value === 'true') {
      migrationStatus.value[uid] = true
      return
    }

    // Catégories globales référencées par l'utilisateur
    const referencedIds = new Set<string>()

    for (const table of ['transactions', 'recurring_transactions', 'user_budgets']) {
      const { data } = await supabase
        .from(table)
        .select('category_id')
        .eq('user_id', uid)
      for (const row of (data ?? []) as { category_id: string }[]) {
        if (row.category_id) referencedIds.add(row.category_id)
      }
    }

    let referencedGlobals: any[] = []
    if (referencedIds.size > 0) {
      const { data } = await supabase
        .from('categories')
        .select('*')
        .is('user_id', null)
        .in('id', Array.from(referencedIds))
      referencedGlobals = data ?? []
    }

    // Crée les copies perso des catégories référencées
    const oldToNew = new Map<string, string>()
    if (referencedGlobals.length > 0) {
      const rows = referencedGlobals.map(g => ({
        user_id: uid,
        name: g.name,
        icon_key: g.icon_key,
        color: g.color,
        type: g.type,
        budget_limit: g.budget_limit,
        is_default: true,
      }))
      const { data: inserted, error: insErr } = await supabase
        .from('categories')
        .insert(rows)
        .select()
      if (insErr) throw insErr

      for (let i = 0; i < referencedGlobals.length; i++) {
        oldToNew.set(referencedGlobals[i].id, (inserted ?? [])[i].id)
      }

      // Re-pointe transactions / récurrences / budgets vers les copies
      for (const [oldId, newId] of oldToNew) {
        await Promise.all([
          supabase.from('transactions').update({ category_id: newId }).eq('user_id', uid).eq('category_id', oldId),
          supabase.from('recurring_transactions').update({ category_id: newId }).eq('user_id', uid).eq('category_id', oldId),
          supabase.from('user_budgets').update({ category_id: newId }).eq('user_id', uid).eq('category_id', oldId),
        ])
      }
    }

    // Complète avec les catégories du nouveau set par défaut qui ne sont pas
    // déjà couvertes (par nom + type) — pour donner un point de départ.
    const { data: existingPerso } = await supabase
      .from('categories')
      .select('name, type')
      .eq('user_id', uid)

    const have = new Set(
      ((existingPerso ?? []) as { name: string; type: string }[]).map(c => `${c.type}::${c.name.toLowerCase()}`),
    )
    const toAdd = DEFAULT_CATEGORIES
      .filter(c => !have.has(`${c.type}::${c.name.toLowerCase()}`))
      .map(c => ({
        user_id: uid,
        name: c.name,
        icon_key: c.iconKey,
        color: c.color,
        type: c.type,
        budget_limit: null,
        is_default: true,
      }))

    if (toAdd.length > 0) {
      await supabase.from('categories').insert(toAdd)
    }

    await supabase
      .from('user_settings')
      .upsert(
        { user_id: uid, key: 'categories_migrated', value: 'true' },
        { onConflict: 'user_id,key' },
      )

    migrationStatus.value[uid] = true
  } catch (e: unknown) {
    console.error('Erreur migration catégories:', e instanceof Error ? e.message : e)
    // On ne bloque pas la navigation : la migration sera retentée au prochain login
  }
})
