import request from './index'

export function getDashboardData() {
  return request.get('/report/dashboard')
}

export function getChartData(params) {
  return request.get('/report/charts', { params })
}

export function generatePdfReport(data) {
  return request.post('/report/pdf/generate', data, { responseType: 'blob' })
}

export function getPdfReportHistory(params) {
  return request.get('/report/pdf/history', { params })
}

export function uploadIndustryData(data) {
  return request.post('/report/benchmark/upload', data, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function getBenchmarkData(params) {
  return request.get('/report/benchmark/data', { params })
}

export function downloadBenchmarkTemplate() {
  return request.get('/report/benchmark/template', { responseType: 'blob' })
}
