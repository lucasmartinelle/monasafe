<script setup lang="ts">
import type { CategoryStatistics } from '~/types/models'
import { Doughnut } from 'vue-chartjs'
import { colorStyle } from '~/utils/colors'

interface Props {
  stats: CategoryStatistics[]
}

const props = defineProps<Props>()

const { format: formatMoney } = useCurrency()
const { categoryById } = useCategories()

const hasData = computed(() => props.stats.length > 0)

const chartData = computed(() => {
  const labels = props.stats.map(s => s.categoryName)
  const data = props.stats.map(s => s.total)
  const colors = props.stats.map((s) => {
    const cat = categoryById.value(s.categoryId)
    return cat ? colorStyle(cat.color) : '#9CA3AF'
  })

  return {
    labels,
    datasets: [
      {
        data,
        backgroundColor: colors,
        borderWidth: 0,
        hoverOffset: 4,
      },
    ],
  }
})

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  cutout: '65%',
  plugins: {
    legend: { display: false },
    tooltip: {
      callbacks: {
        label: (ctx: { raw: unknown; dataIndex: number; label: string }) => {
          const value = ctx.raw as number
          const pct = props.stats[ctx.dataIndex]?.percentage ?? 0
          return ` ${ctx.label}: ${formatMoney(value)} (${pct.toFixed(0)}%)`
        },
      },
    },
  },
}
</script>

<template>
  <CommonAppCard>
    <h3 class="text-label-md text-gray-500 dark:text-gray-400 mb-3">
      Répartition des dépenses
    </h3>

    <div v-if="hasData" class="flex flex-col items-center">
      <div class="w-full h-48">
        <ClientOnly>
          <Doughnut :data="chartData" :options="chartOptions" />
        </ClientOnly>
      </div>

      <!-- Légende -->
      <div class="w-full mt-4 space-y-2">
        <div
          v-for="stat in props.stats.slice(0, 5)"
          :key="stat.categoryId"
          class="flex items-center justify-between"
        >
          <div class="flex items-center gap-2 min-w-0">
            <div
              class="w-2.5 h-2.5 rounded-full shrink-0"
              :style="{
                backgroundColor: categoryById(stat.categoryId)
                  ? colorStyle(categoryById(stat.categoryId)!.color)
                  : '#9CA3AF',
              }"
            />
            <span class="text-xs text-gray-600 dark:text-gray-400 truncate">
              {{ stat.categoryName }}
            </span>
          </div>
          <span class="text-xs font-medium text-gray-900 dark:text-white shrink-0 ml-2">
            {{ formatMoney(stat.total) }}
          </span>
        </div>
      </div>
    </div>

    <div
      v-else
      class="text-center py-8 text-sm text-gray-400 dark:text-gray-500"
    >
      Aucune dépense ce mois
    </div>
  </CommonAppCard>
</template>
