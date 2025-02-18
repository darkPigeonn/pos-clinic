<template>
    <div v-if="isLoading" class="loading-overlay">
        <div class="spinner"></div>
    </div>
</template>

<script setup>
import { useLoading } from '~/composables/useLoading';

const { isLoading } = useLoading();
</script>

<style scoped>
.loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
}

.spinner {
    width: 50px;
    height: 50px;
    border: 5px solid #fff;
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}
</style>