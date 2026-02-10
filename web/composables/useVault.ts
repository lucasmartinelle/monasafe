import {
  generateSalt,
  generateDEK,
  deriveKEK,
  encryptDEK,
  decryptDEK,
  encryptString,
  decryptString,
  encodeSalt,
  decodeSalt,
  importRawKey,
} from '~/utils/crypto'

/**
 * Composable vault — logique métier du chiffrement E2E.
 *
 * Gère l'activation, le déverrouillage, le changement de mot de passe
 * et le chiffrement/déchiffrement des transactions.
 */
export function useVault() {
  const store = useVaultStore()
  const settings = useSettings()
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  /**
   * Initialise l'état du vault depuis user_settings au démarrage.
   */
  async function init(): Promise<void> {
    const vaultEnabled = await settings.getSetting('vault_enabled')
    store.setEnabled(vaultEnabled === 'true')

    if (store.isEnabled) {
      store.setLocked(true)
    }
  }

  /**
   * Active le vault : génère salt+DEK, dérive KEK, chiffre DEK,
   * stocke dans user_settings, chiffre toutes les transactions existantes.
   */
  async function activate(masterPassword: string): Promise<void> {
    store.setLoading(true)
    store.setError(null)

    try {
      const salt = generateSalt()
      const dek = generateDEK()
      const kek = await deriveKEK(masterPassword, salt)
      const encryptedDek = await encryptDEK(dek, kek)

      await settings.updateSetting('vault_salt', encodeSalt(salt))
      await settings.updateSetting('vault_dek_encrypted', encryptedDek)
      await settings.updateSetting('vault_enabled', 'true')

      store.setDek(dek)
      store.setEnabled(true)
      store.setLocked(false)

      await encryptAllTransactions()
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors de l\'activation du vault')
      throw e
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Déverrouille le vault : récupère salt+DEK chiffrée,
   * dérive KEK, déchiffre DEK → mémoire.
   */
  async function unlock(masterPassword: string): Promise<void> {
    store.setLoading(true)
    store.setError(null)

    try {
      const saltBase64 = await settings.getSetting('vault_salt')
      const encryptedDek = await settings.getSetting('vault_dek_encrypted')

      if (!saltBase64 || !encryptedDek) {
        throw new Error('Données du vault introuvables')
      }

      const salt = decodeSalt(saltBase64)
      const kek = await deriveKEK(masterPassword, salt)
      const dek = await decryptDEK(encryptedDek, kek)

      store.setDek(dek)
      store.setLocked(false)
    } catch (e: unknown) {
      store.setError('Mot de passe incorrect')
      throw e
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Verrouille le vault : efface la DEK de la mémoire.
   */
  function lock(): void {
    store.clearDek()
    store.setLocked(true)
  }

  function clearError(): void {
    store.setError(null)
  }

  /**
   * Change le mot de passe maître : re-dérive KEK, re-chiffre DEK.
   */
  async function changeMasterPassword(currentPassword: string, newPassword: string): Promise<void> {
    store.setLoading(true)
    store.setError(null)

    try {
      const saltBase64 = await settings.getSetting('vault_salt')
      const encryptedDek = await settings.getSetting('vault_dek_encrypted')

      if (!saltBase64 || !encryptedDek) {
        throw new Error('Données du vault introuvables')
      }

      const salt = decodeSalt(saltBase64)

      // Vérifier le mot de passe actuel
      const currentKek = await deriveKEK(currentPassword, salt)
      const dek = await decryptDEK(encryptedDek, currentKek)

      // Nouveau salt + KEK
      const newSalt = generateSalt()
      const newKek = await deriveKEK(newPassword, newSalt)
      const newEncryptedDek = await encryptDEK(dek, newKek)

      await settings.updateSetting('vault_salt', encodeSalt(newSalt))
      await settings.updateSetting('vault_dek_encrypted', newEncryptedDek)

      store.setDek(dek)
    } catch (e: unknown) {
      store.setError('Mot de passe actuel incorrect')
      throw e
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Désactive le vault : déchiffre toutes les transactions,
   * supprime les settings vault.
   */
  async function deactivate(masterPassword: string): Promise<void> {
    store.setLoading(true)
    store.setError(null)

    try {
      // Déverrouiller si nécessaire
      if (store.isLocked) {
        await unlock(masterPassword)
      }

      await decryptAllTransactions()

      await settings.deleteSetting('vault_salt')
      await settings.deleteSetting('vault_dek_encrypted')
      await settings.updateSetting('vault_enabled', 'false')

      store.clearDek()
      store.setEnabled(false)
      store.setLocked(true)
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors de la désactivation du vault')
      throw e
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Chiffre les champs sensibles d'une transaction.
   * Retourne { rawAmount, rawNote, is_encrypted } à insérer dans Supabase.
   */
  async function encryptTransactionData(
    amount: number,
    note: string | null,
  ): Promise<{ rawAmount: string; rawNote: string | null; isEncrypted: boolean }> {
    if (!store.isUnlocked || !store.dek) {
      return { rawAmount: String(amount), rawNote: note, isEncrypted: false }
    }

    const key = await importRawKey(store.dek)
    const rawAmount = await encryptString(String(amount), key)
    const rawNote = note ? await encryptString(note, key) : null

    return { rawAmount, rawNote, isEncrypted: true }
  }

  /**
   * Déchiffre les champs sensibles d'une transaction.
   * Retourne { amount, note } déchiffrés.
   */
  async function decryptTransactionData(
    rawAmount: string,
    rawNote: string | null,
  ): Promise<{ amount: number; note: string | null }> {
    if (!store.isUnlocked || !store.dek) {
      return { amount: parseFloat(rawAmount) || 0, note: rawNote }
    }

    try {
      const key = await importRawKey(store.dek)
      const amountStr = await decryptString(rawAmount, key)
      const note = rawNote ? await decryptString(rawNote, key) : null
      return { amount: parseFloat(amountStr), note }
    } catch {
      return { amount: 0, note: null }
    }
  }

  /**
   * Chiffre toutes les transactions et récurrences non chiffrées.
   */
  async function encryptAllTransactions(): Promise<void> {
    if (!user.value || !store.dek) return

    const key = await importRawKey(store.dek)

    // Chiffrer les transactions
    const { data: transactions } = await supabase
      .from('transactions')
      .select('id, amount, note')
      .eq('user_id', user.value.id)
      .eq('is_encrypted', false)

    if (transactions) {
      for (const tx of transactions) {
        const amount = parseFloat(String(tx.amount)) || 0
        const encryptedAmount = await encryptString(String(amount), key)
        const encryptedNote = tx.note ? await encryptString(tx.note, key) : null

        await supabase
          .from('transactions')
          .update({ amount: encryptedAmount, note: encryptedNote, is_encrypted: true })
          .eq('id', tx.id)
          .eq('user_id', user.value.id)
      }
    }

    // Chiffrer les récurrences
    const { data: recurrings } = await supabase
      .from('recurring_transactions')
      .select('id, amount, note')
      .eq('user_id', user.value.id)
      .eq('is_encrypted', false)

    if (recurrings) {
      for (const rec of recurrings) {
        const amount = parseFloat(String(rec.amount)) || 0
        const encryptedAmount = await encryptString(String(amount), key)
        const encryptedNote = rec.note ? await encryptString(rec.note, key) : null

        await supabase
          .from('recurring_transactions')
          .update({ amount: encryptedAmount, note: encryptedNote, is_encrypted: true })
          .eq('id', rec.id)
          .eq('user_id', user.value.id)
      }
    }
  }

  /**
   * Déchiffre toutes les transactions et récurrences chiffrées.
   */
  async function decryptAllTransactions(): Promise<void> {
    if (!user.value || !store.dek) return

    const key = await importRawKey(store.dek)

    // Déchiffrer les transactions
    const { data: transactions } = await supabase
      .from('transactions')
      .select('id, amount, note')
      .eq('user_id', user.value.id)
      .eq('is_encrypted', true)

    if (transactions) {
      for (const tx of transactions) {
        try {
          const amountStr = await decryptString(String(tx.amount), key)
          const note = tx.note ? await decryptString(tx.note, key) : null

          await supabase
            .from('transactions')
            .update({
              amount: amountStr,
              note,
              is_encrypted: false,
            })
            .eq('id', tx.id)
            .eq('user_id', user.value.id)
        } catch (e: unknown) {
          console.error(`Erreur déchiffrement transaction ${tx.id}:`, e instanceof Error ? e.message : e)
        }
      }
    }

    // Déchiffrer les récurrences
    const { data: recurrings } = await supabase
      .from('recurring_transactions')
      .select('id, amount, note')
      .eq('user_id', user.value.id)
      .eq('is_encrypted', true)

    if (recurrings) {
      for (const rec of recurrings) {
        try {
          const amountStr = await decryptString(String(rec.amount), key)
          const note = rec.note ? await decryptString(rec.note, key) : null

          await supabase
            .from('recurring_transactions')
            .update({
              amount: amountStr,
              note,
              is_encrypted: false,
            })
            .eq('id', rec.id)
            .eq('user_id', user.value.id)
        } catch (e: unknown) {
          console.error(`Erreur déchiffrement récurrence ${rec.id}:`, e instanceof Error ? e.message : e)
        }
      }
    }
  }

  return {
    // State (readonly, depuis le store)
    isEnabled: computed(() => store.isEnabled),
    isLocked: computed(() => store.isLocked),
    isUnlocked: computed(() => store.isUnlocked),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),

    // Actions
    init,
    activate,
    unlock,
    lock,
    clearError,
    changeMasterPassword,
    deactivate,
    encryptTransactionData,
    decryptTransactionData,
  }
}
