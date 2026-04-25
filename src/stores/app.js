import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAppStore = defineStore('app', () => {
  const sidebarCollapsed = ref(false)
  const breadcrumbList = ref([])

  function toggleSidebar() {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  function setBreadcrumb(list) {
    breadcrumbList.value = list
  }

  return { sidebarCollapsed, breadcrumbList, toggleSidebar, setBreadcrumb }
})
