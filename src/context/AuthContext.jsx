import React, { createContext, useContext, useState, useEffect } from 'react'
import { authAPI } from '../services/api'

const AuthContext = createContext(null)

// Mapeo de roles del backend a permisos del frontend
const ROLES_PERMISOS = {
  super_owner_supremo: {
    id: 'superadmin',
    nombre: 'Super Administrador',
    permisos: { 
      ver_todos: true, ver_propios: true, editar: true, 
      reasignar: true, config: true, usuarios: true, 
      reportes: true, formularios: true, ver_superadmin: true,
      eliminar_keymaster: true, crear_leads: true
    },
    oculto: true
  },
  super_owner: {
    id: 'superadmin',
    nombre: 'Super Owner',
    permisos: { 
      ver_todos: true, ver_propios: true, editar: true, 
      reasignar: true, config: true, usuarios: true, 
      reportes: true, formularios: true, ver_superadmin: true,
      eliminar_keymaster: false, crear_leads: true
    },
    oculto: true
  },
  keymaster: {
    id: 'keymaster',
    nombre: 'Key Master',
    permisos: { 
      ver_todos: true, ver_propios: true, editar: true, 
      reasignar: true, config: true, usuarios: true, 
      reportes: true, formularios: true,
      ver_superadmin: false, eliminar_keymaster: false, crear_leads: true
    }
  },
  encargado: {
    id: 'encargado',
    nombre: 'Encargado de Admisión',
    permisos: { 
      ver_todos: false, ver_propios: true, editar: true, 
      reasignar: false, config: false, usuarios: false, 
      reportes: true, formularios: false, crear_leads: true
    }
  },
  asistente: {
    id: 'asistente',
    nombre: 'Asistente',
    permisos: { 
      ver_todos: false, ver_propios: false, editar: false, 
      reasignar: false, config: false, usuarios: false, 
      reportes: false, formularios: false, crear_leads: true
    }
  }
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [tenant, setTenant] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    // Verificar sesión guardada
    const checkAuth = async () => {
      const token = authAPI.getToken()
      if (token) {
        try {
          const data = await authAPI.me()
          const enrichedUser = enrichUser(data.user)
          setUser(enrichedUser)
          setTenant(data.tenant)
        } catch (err) {
          console.error('Error verificando sesión:', err)
          authAPI.logout()
        }
      }
      setLoading(false)
    }
    
    checkAuth()
  }, [])

  function enrichUser(userData) {
    const rolBackend = userData.rol || userData.rol_id
    const rolConfig = ROLES_PERMISOS[rolBackend] || ROLES_PERMISOS.asistente
    
    return {
      ...userData,
      rol_id: rolConfig.id,
      rol: rolConfig,
      permisos: rolConfig.permisos,
      esSuperOwner: rolBackend === 'super_owner_supremo' || rolBackend === 'super_owner'
    }
  }

  // Login para usuarios de tenant (con código de institución)
  async function signIn(email, password, tenantSlug = null) {
    setError(null)
    
    try {
      // Si hay tenantSlug, es login de usuario normal
      if (tenantSlug) {
        const data = await authAPI.login(tenantSlug, email, password)
        const enrichedUser = enrichUser(data.user)
        setUser(enrichedUser)
        setTenant(data.tenant)
        return { success: true, user: enrichedUser, tenant: data.tenant }
      } else {
        // Login de Super Owner
        const data = await authAPI.adminLogin(email, password)
        const enrichedUser = enrichUser(data.user)
        setUser(enrichedUser)
        setTenant(null)
        return { success: true, user: enrichedUser }
      }
    } catch (err) {
      setError(err.message)
      return { success: false, error: err.message }
    }
  }

  // Login específico para Super Owner
  async function signInAdmin(email, password) {
    return signIn(email, password, null)
  }

  function signOut() {
    authAPI.logout()
    setUser(null)
    setTenant(null)
    setError(null)
  }

  // Helpers de permisos (mantiene compatibilidad con el código existente)
  const isSuperAdmin = user?.rol_id === 'superadmin' || user?.esSuperOwner
  const isKeyMaster = user?.rol_id === 'keymaster' || isSuperAdmin
  const isEncargado = user?.rol_id === 'encargado'
  const isAsistente = user?.rol_id === 'asistente'
  const isRector = user?.rol_id === 'rector'
  
  // Permisos específicos
  const canViewAll = user?.permisos?.ver_todos || isSuperAdmin
  const canViewOwn = user?.permisos?.ver_propios
  const canEdit = user?.permisos?.editar || isSuperAdmin
  const canReasignar = user?.permisos?.reasignar || isSuperAdmin
  const canConfig = user?.permisos?.config || isSuperAdmin
  const canManageUsers = user?.permisos?.usuarios || isSuperAdmin
  const canViewReports = user?.permisos?.reportes || isEncargado || isSuperAdmin
  const canManageForms = user?.permisos?.formularios || isSuperAdmin
  const canCreateLeads = user?.permisos?.crear_leads || canEdit
  const canDeleteKeyMaster = user?.permisos?.eliminar_keymaster || isSuperAdmin

  return (
    <AuthContext.Provider value={{
      user,
      tenant,
      loading,
      error,
      signIn,
      signInAdmin,
      signOut,
      // Roles
      isSuperAdmin,
      isKeyMaster,
      isEncargado,
      isAsistente,
      isRector,
      // Permisos
      canViewAll,
      canViewOwn,
      canEdit,
      canReasignar,
      canConfig,
      canManageUsers,
      canViewReports,
      canManageForms,
      canCreateLeads,
      canDeleteKeyMaster,
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth debe usarse dentro de AuthProvider')
  }
  return context
}

// Exportar ROLES para compatibilidad
export const ROLES = ROLES_PERMISOS
