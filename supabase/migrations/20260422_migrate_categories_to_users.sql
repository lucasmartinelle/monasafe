-- =============================================================================
-- Migration : appropriation des catégories par utilisateur
-- =============================================================================
-- Pour chaque utilisateur qui n'a pas encore été migré :
--   1. Copie dans son scope perso les catégories globales (user_id IS NULL)
--      qu'il référence via ses transactions / récurrences / budgets.
--   2. Re-pointe ses transactions / récurrences / budgets vers les copies.
--   3. Complète avec les catégories du nouveau set par défaut qui ne sont pas
--      déjà présentes (match insensible à la casse sur (type, name)).
--   4. Marque `categories_migrated = true` dans user_settings.
--
-- Idempotent : un utilisateur déjà flaggé est skippé.
-- Atomique : tout se déroule dans une transaction unique.
-- À exécuter dans le SQL Editor Supabase, AVANT le script de cleanup.
--
-- Source de vérité du set par défaut alignée avec :
--   - web/utils/defaultCategories.ts
--   - mobile/lib/src/data/constants/default_categories.dart
-- =============================================================================

BEGIN;

-- Set par défaut curaté (8 catégories). Couleurs ARGB en décimal :
--   0xFFE87B4D = 4286922061    0xFF1B5E5A = 4279885402
--   0xFF2196F3 = 4280892147    0xFF9C27B0 = 4287384496
--   0xFFF44336 = 4292030262    0xFF607D8B = 4284506507
--   0xFF4CAF50 = 4283215696    0xFF00BCD4 = 4278238420
CREATE TEMP TABLE _default_categories (
  name      text   NOT NULL,
  icon_key  text   NOT NULL,
  color     bigint NOT NULL,
  type      text   NOT NULL
) ON COMMIT DROP;

INSERT INTO _default_categories (name, icon_key, color, type) VALUES
  ('Alimentation',     'shopping-cart',   4286922061, 'expense'),
  ('Logement',         'home',            4279885402, 'expense'),
  ('Transport',        'car',             4280892147, 'expense'),
  ('Loisirs',          'gamepad-2',       4287384496, 'expense'),
  ('Santé',            'heart-pulse',     4292030262, 'expense'),
  ('Autres dépenses',  'ellipsis',        4284506507, 'expense'),
  ('Salaire',          'wallet',          4283215696, 'income'),
  ('Autres revenus',   'arrow-up-circle', 4278238420, 'income');

DO $$
DECLARE
  v_user_id  uuid;
  v_global   record;
  v_new_id   uuid;
  v_now      timestamptz := now();
  v_migrated int := 0;
  v_skipped  int := 0;
BEGIN
  -- Itère sur tous les utilisateurs non encore migrés
  FOR v_user_id IN
    SELECT u.id
    FROM auth.users u
    WHERE NOT EXISTS (
      SELECT 1 FROM public.user_settings s
      WHERE s.user_id = u.id
        AND s.key = 'categories_migrated'
        AND s.value = 'true'
    )
  LOOP
    -- 1+2. Pour chaque catégorie globale référencée par cet utilisateur,
    --      crée une copie perso et re-pointe ses FKs vers la copie.
    FOR v_global IN
      SELECT c.*
      FROM public.categories c
      WHERE c.user_id IS NULL
        AND c.id IN (
          SELECT category_id FROM public.transactions
            WHERE user_id = v_user_id AND category_id IS NOT NULL
          UNION
          SELECT category_id FROM public.recurring_transactions
            WHERE user_id = v_user_id AND category_id IS NOT NULL
          UNION
          SELECT category_id FROM public.user_budgets
            WHERE user_id = v_user_id AND category_id IS NOT NULL
        )
    LOOP
      INSERT INTO public.categories (
        user_id, name, icon_key, color, type, budget_limit,
        is_default, created_at, updated_at
      )
      VALUES (
        v_user_id, v_global.name, v_global.icon_key, v_global.color,
        v_global.type, v_global.budget_limit,
        true, v_now, v_now
      )
      RETURNING id INTO v_new_id;

      UPDATE public.transactions
        SET category_id = v_new_id
        WHERE user_id = v_user_id AND category_id = v_global.id;

      UPDATE public.recurring_transactions
        SET category_id = v_new_id
        WHERE user_id = v_user_id AND category_id = v_global.id;

      UPDATE public.user_budgets
        SET category_id = v_new_id
        WHERE user_id = v_user_id AND category_id = v_global.id;
    END LOOP;

    -- 3. Complète avec les défauts du set curaté qui manquent
    --    (match insensible à la casse sur le couple (type, name))
    INSERT INTO public.categories (
      user_id, name, icon_key, color, type, budget_limit,
      is_default, created_at, updated_at
    )
    SELECT
      v_user_id, d.name, d.icon_key, d.color, d.type, NULL,
      true, v_now, v_now
    FROM _default_categories d
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.categories c
      WHERE c.user_id = v_user_id
        AND c.type = d.type
        AND lower(c.name) = lower(d.name)
    );

    -- 4. Marque l'utilisateur comme migré
    INSERT INTO public.user_settings (user_id, key, value, updated_at)
    VALUES (v_user_id, 'categories_migrated', 'true', v_now)
    ON CONFLICT (user_id, key) DO UPDATE
      SET value = excluded.value,
          updated_at = excluded.updated_at;

    v_migrated := v_migrated + 1;
  END LOOP;

  SELECT count(*) INTO v_skipped
  FROM public.user_settings
  WHERE key = 'categories_migrated' AND value = 'true';
  v_skipped := v_skipped - v_migrated;

  RAISE NOTICE 'Migration catégories : % migré(s), % déjà à jour', v_migrated, v_skipped;
END;
$$;

COMMIT;

-- =============================================================================
-- Vérifications post-migration (à exécuter avant le cleanup)
-- =============================================================================
-- a) Tous les utilisateurs ont bien le flag → doit retourner 0
--    SELECT count(*) FROM auth.users u
--    WHERE NOT EXISTS (
--      SELECT 1 FROM public.user_settings s
--      WHERE s.user_id = u.id AND s.key = 'categories_migrated' AND s.value = 'true'
--    );
--
-- b) Aucune FK ne pointe vers une catégorie globale → doit retourner 0 pour chaque
--    SELECT count(*) FROM public.transactions t
--      JOIN public.categories c ON c.id = t.category_id WHERE c.user_id IS NULL;
--    SELECT count(*) FROM public.recurring_transactions r
--      JOIN public.categories c ON c.id = r.category_id WHERE c.user_id IS NULL;
--    SELECT count(*) FROM public.user_budgets b
--      JOIN public.categories c ON c.id = b.category_id WHERE c.user_id IS NULL;
--
-- c) Combien de catégories globales restent (informatif) :
--    SELECT count(*) FROM public.categories WHERE user_id IS NULL;
