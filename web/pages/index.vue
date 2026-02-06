<script setup lang="ts">
definePageMeta({
  layout: 'blank',
})

const user = useSupabaseUser()

// Redirect intelligent basé sur l'état d'authentification
// Le middleware onboarding.global s'occupe de vérifier l'onboarding
onMounted(() => {
  watchEffect(() => {
    if (user.value) {
      navigateTo('/dashboard')
    } else {
      navigateTo('/auth')
    }
  })
})
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-background-light dark:bg-background-dark">
    <CommonLoadingState />
  </div>
</template>
