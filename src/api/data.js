import request from './index'

export function getEtlTasks(params) {
  return request.get('/data/etl/tasks', { params })
}

export function triggerEtlTask(data) {
  return request.post('/data/etl/trigger', data)
}

export function getEtlTaskDetail(id) {
  return request.get(`/data/etl/tasks/${id}`)
}

export function uploadExcel(data, onProgress) {
  return request.post('/data/import/excel', data, {
    headers: { 'Content-Type': 'multipart/form-data' },
    onUploadProgress: onProgress
  })
}

export function downloadTemplate(type) {
  return request.get('/data/import/template', { params: { type }, responseType: 'blob' })
}

export function getValidationRules(params) {
  return request.get('/data/validation/rules', { params })
}

export function createValidationRule(data) {
  return request.post('/data/validation/rules', data)
}

export function updateValidationRule(id, data) {
  return request.put(`/data/validation/rules/${id}`, data)
}

export function deleteValidationRule(id) {
  return request.delete(`/data/validation/rules/${id}`)
}

export function getSubjectMappings(params) {
  return request.get('/data/mapping', { params })
}

export function createSubjectMapping(data) {
  return request.post('/data/mapping', data)
}

export function updateSubjectMapping(id, data) {
  return request.put(`/data/mapping/${id}`, data)
}

export function deleteSubjectMapping(id) {
  return request.delete(`/data/mapping/${id}`)
}

export function getImportHistory(params) {
  return request.get('/data/import/history', { params })
}
