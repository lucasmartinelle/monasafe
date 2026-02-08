<script setup lang="ts">
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Filler,
  Tooltip,
  Legend,
} from 'chart.js'
import type { MonthlyStatistics, DailyStatistics } from '~/types/models'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Filler, Tooltip, Legend)

interface Props {
  monthlyData?: MonthlyStatistics[]
  dailyData?: DailyStatistics[]
  mode: 'monthly' | 'daily'
}

const props = defineProps<Props>()

const { format: formatMoney } = useCurrency()

const MONTH_LABELS = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc']

const chartData = computed(() => {
  if (props.mode === 'monthly' && props.monthlyData) {
    // Filtrer les mois avec des données
    const filtered = props.monthlyData.filter(m => m.income > 0 || m.expense > 0)
    if (filtered.length === 0) return { labels: [], datasets: [] }

    return {
      labels: filtered.map(m => MONTH_LABELS[m.month - 1]),
      datasets: [
        {
          label: 'Revenus',
          data: filtered.map(m => m.income),
          borderColor: 'rgba(76, 175, 80, 1)',
          backgroundColor: 'rgba(76, 175, 80, 0.1)',
          pointBackgroundColor: 'rgba(76, 175, 80, 1)',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6,
          borderWidth: 3,
          tension: 0.3,
          fill: true,
        },
        {
          label: 'Dépenses',
          data: filtered.map(m => m.expense),
          borderColor: 'rgba(244, 67, 54, 1)',
          backgroundColor: 'rgba(244, 67, 54, 0.1)',
          pointBackgroundColor: 'rgba(244, 67, 54, 1)',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6,
          borderWidth: 3,
          tension: 0.3,
          fill: true,
        },
      ],
    }
  }

  if (props.mode === 'daily' && props.dailyData) {
    // Filtrer les jours avec des données
    const filtered = props.dailyData.filter(d => d.income > 0 || d.expense > 0)
    if (filtered.length === 0) return { labels: [], datasets: [] }

    return {
      labels: filtered.map(d => String(new Date(d.date).getDate())),
      datasets: [
        {
          label: 'Revenus',
          data: filtered.map(d => d.income),
          borderColor: 'rgba(76, 175, 80, 1)',
          backgroundColor: 'rgba(76, 175, 80, 0.1)',
          pointBackgroundColor: 'rgba(76, 175, 80, 1)',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6,
          borderWidth: 3,
          tension: 0.3,
          fill: true,
        },
        {
          label: 'Dépenses',
          data: filtered.map(d => d.expense),
          borderColor: 'rgba(244, 67, 54, 1)',
          backgroundColor: 'rgba(244, 67, 54, 0.1)',
          pointBackgroundColor: 'rgba(244, 67, 54, 1)',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6,
          borderWidth: 3,
          tension: 0.3,
          fill: true,
        },
      ],
    }
  }

  return { labels: [], datasets: [] }
})

const chartOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  interaction: {
    mode: 'index' as const,
    intersect: false,
  },
  plugins: {
    legend: {
      display: true,
      position: 'bottom' as const,
      labels: {
        usePointStyle: true,
        pointStyle: 'circle',
        padding: 16,
        font: { size: 12 },
      },
    },
    tooltip: {
      callbacks: {
        label: (ctx: any) => `${ctx.dataset.label}: ${formatMoney(ctx.parsed.y)}`,
      },
    },
  },
  scales: {
    x: {
      grid: { display: false },
      ticks: { font: { size: 11 } },
    },
    y: {
      beginAtZero: true,
      grid: { color: 'rgba(0,0,0,0.06)' },
      ticks: {
        font: { size: 11 },
        callback: (value: any) => formatMoney(value),
      },
    },
  },
}))

const hasData = computed(() => {
  if (props.mode === 'monthly' && props.monthlyData) {
    return props.monthlyData.some(m => m.income > 0 || m.expense > 0)
  }
  if (props.mode === 'daily' && props.dailyData) {
    return props.dailyData.some(d => d.income > 0 || d.expense > 0)
  }
  return false
})
</script>

<template>
  <div class="bg-white dark:bg-card-dark rounded-xl p-4">
    <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-4">
      Flux de trésorerie
    </h3>

    <div v-if="hasData" class="h-56">
      <Line :data="chartData" :options="chartOptions" />
    </div>

    <div v-else class="h-56 flex items-center justify-center">
      <p class="text-sm text-gray-400 dark:text-gray-500">
        Aucune donnée pour cette période
      </p>
    </div>
  </div>
</template>
