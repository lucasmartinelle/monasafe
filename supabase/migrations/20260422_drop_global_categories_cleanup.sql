-- =============================================================================
-- Cleanup post-migration : suppression des catégories globales et resserrement RLS
-- =============================================================================
-- À EXÉCUTER UNIQUEMENT après que :
--   - 20260422_migrate_categories_to_users.sql ait tourné avec succès,
--   - les 3 checks de fin de ce fichier renvoient bien 0,
--   - les apps web et mobile aient été déployées avec le code qui ne lit
--     plus les défauts globaux (PR « refonte catégories »).
--
-- Le script est défensif : il refuse de supprimer les globaux tant que des
-- transactions/récurrences/budgets y font encore référence.
-- =============================================================================

BEGIN;

-- Garde-fou : on ne touche à rien si des FKs pointent encore vers un global
DO $$
DECLARE
  v_orphan_tx        int;
  v_orphan_recurring int;
  v_orphan_budgets   int;
  v_unmigrated_users int;
BEGIN
  SELECT count(*) INTO v_orphan_tx
  FROM public.transactions t
  JOIN public.categories c ON c.id = t.category_id
  WHERE c.user_id IS NULL;

  SELECT count(*) INTO v_orphan_recurring
  FROM public.recurring_transactions r
  JOIN public.categories c ON c.id = r.category_id
  WHERE c.user_id IS NULL;

  SELECT count(*) INTO v_orphan_budgets
  FROM public.user_budgets b
  JOIN public.categories c ON c.id = b.category_id
  WHERE c.user_id IS NULL;

  SELECT count(*) INTO v_unmigrated_users
  FROM auth.users u
  WHERE NOT EXISTS (
    SELECT 1 FROM public.user_settings s
    WHERE s.user_id = u.id AND s.key = 'categories_migrated' AND s.value = 'true'
  );

  IF v_orphan_tx + v_orphan_recurring + v_orphan_budgets > 0 THEN
    RAISE EXCEPTION
      'Cleanup refusé : % transactions, % récurrences et % budgets pointent encore vers des catégories globales. Relancer la migration.',
      v_orphan_tx, v_orphan_recurring, v_orphan_budgets;
  END IF;

  IF v_unmigrated_users > 0 THEN
    RAISE EXCEPTION
      'Cleanup refusé : % utilisateurs n''ont pas encore le flag categories_migrated.',
      v_unmigrated_users;
  END IF;

  RAISE NOTICE 'Garde-fous OK, suppression des catégories globales en cours…';
END;
$$;

-- 1. Suppression effective des catégories globales
DELETE FROM public.categories WHERE user_id IS NULL;

-- 2. Resserrement de la RLS sur la table categories
--    Adapter le nom des policies à celles réellement présentes en base.
--    Les commandes ci-dessous sont des EXEMPLES — vérifier d'abord avec :
--      SELECT polname, polcmd FROM pg_policy
--      WHERE polrelid = 'public.categories'::regclass;
--
-- DROP POLICY IF EXISTS "Categories are viewable by owner or anyone (defaults)"
--   ON public.categories;
--
-- CREATE POLICY "Categories are viewable by owner"
--   ON public.categories FOR SELECT
--   USING (auth.uid() = user_id);
--
-- CREATE POLICY "Categories are insertable by owner"
--   ON public.categories FOR INSERT
--   WITH CHECK (auth.uid() = user_id);
--
-- CREATE POLICY "Categories are updatable by owner"
--   ON public.categories FOR UPDATE
--   USING (auth.uid() = user_id)
--   WITH CHECK (auth.uid() = user_id);
--
-- CREATE POLICY "Categories are deletable by owner"
--   ON public.categories FOR DELETE
--   USING (auth.uid() = user_id);

-- 3. Optionnel : rendre user_id NOT NULL maintenant que plus aucune ligne
--    n'a user_id IS NULL. Renforce l'invariant côté schéma.
--
-- ALTER TABLE public.categories ALTER COLUMN user_id SET NOT NULL;

COMMIT;
