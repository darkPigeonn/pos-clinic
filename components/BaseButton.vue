<template>
  <button
    :disabled="loading"
    class="px-4 py-2 w-full text-white rounded-lg flex items-center justify-center"
    :class="class"
  >
    <svg
      v-if="loading"
      class="animate-spin h-5 w-5 mr-2 text-white"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path>
    </svg>
    <span>{{ loading ? 'Processing...' : label }}</span>
  </button>
</template>

<script setup>
defineProps({
  label: String,
  loading: Boolean,
  class: String
});
</script>
