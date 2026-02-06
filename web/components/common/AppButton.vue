<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  disabled?: boolean
  block?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
  block: false,
})

const variantClasses: Record<string, string> = {
  primary: 'bg-primary text-white hover:bg-primary-dark active:bg-primary-dark',
  secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600',
  danger: 'bg-error text-white hover:bg-red-600 active:bg-red-700',
  ghost: 'bg-transparent text-primary hover:bg-primary/10 dark:text-primary-light',
}

const sizeClasses: Record<string, string> = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2.5 text-sm',
  lg: 'px-6 py-3 text-base',
}
</script>

<template>
  <button
    :class="[
      'inline-flex items-center justify-center font-medium rounded-[12px] transition-colors duration-150 focus:outline-none focus:ring-2 focus:ring-primary/50',
      variantClasses[props.variant],
      sizeClasses[props.size],
      props.block ? 'w-full' : '',
      (props.disabled || props.loading) ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer',
    ]"
    :disabled="props.disabled || props.loading"
  >
    <svg
      v-if="props.loading"
      class="animate-spin -ml-1 mr-2 h-4 w-4"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
    </svg>
    <slot />
  </button>
</template>
