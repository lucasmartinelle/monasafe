<template>
  <div class="min-h-screen flex items-center justify-center bg-background-light dark:bg-background-dark px-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-h1 text-primary dark:text-primary-light">Monasafe</h1>
        <p class="text-body-md text-gray-500 dark:text-gray-400 mt-2">
          Gestion de finances personnelles
        </p>
      </div>
      <slot />
    </div>
  </div>
</template>
