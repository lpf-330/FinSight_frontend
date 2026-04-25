import request from './index'

export function getFormulas(params) {
  return request.get('/config/formula', { params })
}

export function createFormula(data) {
  return request.post('/config/formula', data)
}

export function updateFormula(id, data) {
  return request.put(`/config/formula/${id}`, data)
}

export function deleteFormula(id) {
  return request.delete(`/config/formula/${id}`)
}

export function validateFormula(data) {
  return request.post('/config/formula/validate', data)
}

export function getThresholds(params) {
  return request.get('/config/threshold', { params })
}

export function createThreshold(data) {
  return request.post('/config/threshold', data)
}

export function updateThreshold(id, data) {
  return request.put(`/config/threshold/${id}`, data)
}

export function getDynamicSuggestion(indicatorId) {
  return request.get(`/config/threshold/dynamic-suggestion/${indicatorId}`)
}

export function getKnowledgeList(params) {
  return request.get('/config/knowledge', { params })
}

export function createKnowledge(data) {
  return request.post('/config/knowledge', data)
}

export function updateKnowledge(id, data) {
  return request.put(`/config/knowledge/${id}`, data)
}

export function deleteKnowledge(id) {
  return request.delete(`/config/knowledge/${id}`)
}

export function exportKnowledge() {
  return request.get('/config/knowledge/export', { responseType: 'blob' })
}

export function importKnowledge(data) {
  return request.post('/config/knowledge/import', data, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function getVersions(params) {
  return request.get('/config/version', { params })
}

export function simulateVersion(data) {
  return request.post('/config/version/simulate', data)
}

export function switchVersion(data) {
  return request.put('/config/version/switch', data)
}
