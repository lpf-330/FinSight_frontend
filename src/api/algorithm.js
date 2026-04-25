import request from './index'

export function getRatioResults(params) {
  return request.get('/algorithm/ratio/results', { params })
}

export function triggerRatioCalc(data) {
  return request.post('/algorithm/ratio/calculate', data)
}

export function getRatioCategories() {
  return request.get('/algorithm/ratio/categories')
}

export function getWarningRecords(params) {
  return request.get('/algorithm/warning/records', { params })
}

export function ignoreWarning(id) {
  return request.put(`/algorithm/warning/records/${id}/ignore`)
}

export function getWarningSummary() {
  return request.get('/algorithm/warning/summary')
}

export function calcInvestment(data) {
  return request.post('/algorithm/investment/calculate', data)
}

export function saveInvestmentScheme(data) {
  return request.post('/algorithm/investment/scheme', data)
}

export function getInvestmentSchemes(params) {
  return request.get('/algorithm/investment/schemes', { params })
}

export function calcProfitForecast(data) {
  return request.post('/algorithm/forecast/profit', data)
}

export function getTrendData(params) {
  return request.get('/algorithm/trend/data', { params })
}

export function getDuPontAnalysis(params) {
  return request.get('/algorithm/trend/dupont', { params })
}
