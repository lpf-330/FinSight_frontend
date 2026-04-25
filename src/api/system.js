import request from './index'

export function getUsers(params) {
  return request.get('/system/user', { params })
}

export function createUser(data) {
  return request.post('/system/user', data)
}

export function updateUser(id, data) {
  return request.put(`/system/user/${id}`, data)
}

export function deleteUser(id) {
  return request.delete(`/system/user/${id}`)
}

export function resetPassword(id) {
  return request.put(`/system/user/${id}/reset-password`)
}

export function getRoles(params) {
  return request.get('/system/role', { params })
}

export function createRole(data) {
  return request.post('/system/role', data)
}

export function updateRole(id, data) {
  return request.put(`/system/role/${id}`, data)
}

export function deleteRole(id) {
  return request.delete(`/system/role/${id}`)
}

export function getPermissions() {
  return request.get('/system/permission/tree')
}

export function getAuditLogs(params) {
  return request.get('/system/audit-log', { params })
}

export function exportAuditLogs(params) {
  return request.get('/system/audit-log/export', { params, responseType: 'blob' })
}

export function getEtlMonitorData(params) {
  return request.get('/system/etl-monitor', { params })
}

export function manualTriggerEtl() {
  return request.post('/system/etl-monitor/trigger')
}

export function stopEtlTask(id) {
  return request.put(`/system/etl-monitor/${id}/stop`)
}

export function getSystemParams() {
  return request.get('/system/params')
}

export function updateSystemParams(data) {
  return request.put('/system/params', data)
}
